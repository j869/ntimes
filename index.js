import express from "express";
import bodyParser from "body-parser";
//import axios from "axios";
import pg from "pg";
import bcrypt from "bcrypt";
import passport from "passport";
import { Strategy } from "passport-local";
import session from "express-session";
import env from "dotenv";
import nodemailer from 'nodemailer';
import crypto from 'crypto';


const app = express();
// const API_URL = "http://localhost:4000";
// let baseURL = "";
const saltRounds = 10;
env.config();

app.use(
  session({
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: true,
  })
);
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static("public"));
app.use(passport.initialize());
app.use(passport.session());

const db = new pg.Client({
  user: process.env.PG_USER,
  host: process.env.PG_HOST,
  database: process.env.PG_DATABASE,
  password: process.env.PG_PASSWORD,
  port: process.env.PG_PORT,
});
db.connect();


// Middleware to log connections
app.use((req, res, next) => {
    // Define an inner async function to use await
    const handleRequest = async () => {
        const ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
        const userAgent = req.headers['user-agent'];
        const [browser, os] = parseUserAgent(userAgent);
        const now = new Date().toISOString();
        //    const sessionId = await bcrypt.hash(req.sessionID, 10);    
        const hashedSessionId = await bcrypt.hash(req.sessionID, 10);            //more secure against session hijacking attacks.
        const sessionId = hashedSessionId.substring(0, 8); // Extract a portion of the hash
        const sanitizedBody = { ...req.body };          // Clone the req.body object to avoid modifying the original request
        if (sanitizedBody.hasOwnProperty('password')) {
            sanitizedBody.password = '***';         // dont reveal the unhashed password in the logging table
        } 
        const reqJSON = JSON.stringify({
        endpoint: req.originalUrl,
        params: req.params,
        query: req.query,
        body: sanitizedBody
        });

        // Check if the session ID is valid (recognized by passport)
        if (!req.isAuthenticated()) {
            console.error(`Attempted session hijacking attack detected: Session ID ${sessionId}`);
        }        

        db.query(      // Insert data into the debug table
        'INSERT INTO debug (timestamp, ip_address, session_id, browserOS, agent, request) VALUES ($1, $2, $3, $4, $5, $6)',
        [now, ip, sessionId, browser + " on " + os, userAgent, reqJSON],
        (err, result) => {
            if (err) {
            console.error('Error inserting data into debug table:', err);
            } else {
            //console.log('Data inserted into debug table:', result.rows);
            }
        }
        );

    }

    // Call the async function immediately
    handleRequest().then(() => {
        next();
    }).catch(next);
  });
  
  // Function to parse user agent string and extract browser and OS information
  function parseUserAgent(userAgent) {
    // Use a library like 'useragent' for more accurate parsing
    // This is a basic example
    const browserMatch = userAgent.match(/(Firefox|Chrome|Safari|Opera|MSIE)\/([\d.]+)/);
    const osMatch = userAgent.match(/\((Windows NT [\d.]+|Macintosh|Linux|iPhone|iPad|Android)\)/);
    const browser = browserMatch ? browserMatch[1] : 'Unknown';
    let os = osMatch ? osMatch[1] : 'Unknown';
    if (os.startsWith('Windows')) {
        os = 'Windows NT 10.0'; // or extract the actual version if available
    }
    return [browser, os];
}








//--------------------------------
//----  Define routes
//-------------------------------
app.get('/', (req, res) => {
    res.render('home.ejs', { user: req.user, title: 'Home', body: '' }); 
});


app.get('/profile', isAuthenticated, (req, res) => {
    res.render('profile.ejs', { user: req.user });
});



//--------------------------------
//----  Authorisation
//-------------------------------

app.get('/login', (req, res) => {
    res.render('login.ejs');
});

app.post('/login', passport.authenticate('local', {
    successRedirect: '/profile',
    failureRedirect: '/login'
}));

app.get('/logout', (req, res) => {
    req.logout();
    res.redirect('/');
});

app.get('/register', (req, res) => {
    res.render('register.ejs'); 
});

// Handler for registration form submission
app.post('/register', async (req, res) => {
    try {
        const { email, password } = req.body;
        const hashedPassword = await bcrypt.hash(password, saltRounds);

        // Generate a verification token
        const verificationToken = generateToken();

        // Insert a new user record into the users table with the verification token
        const result = await db.query(
            "INSERT INTO users (email, password, verification_token) VALUES ($1, $2, $3) RETURNING *",
            [email, hashedPassword, verificationToken]
        );

        try {
            // Send verification email
            const transporter = nodemailer.createTransport({
                host: 'cp-wc64.per01.ds.network', // alternate host server is required instead of mail.buildingbb.com.au
                port: 587, // Port for secure SMTP
                secure: false, // Set to true if your SMTP server requires TLS
                requireTLS: true, 
                auth: {
                    user: process.env.SMTP_EMAIL, // Your email username
                    pass: process.env.SMTP_PASSWORD // Your email password or application-specific password
                }
                    // Set SSL/TLS protocol version and options
                // secureOptions: {
                //     secureProtocol: 'TLSv1_2_method',
                // }
            });
        
            await transporter.sendMail({
                from: 'john@buildingbb.com.au',
                to: email, 
                subject: 'Please verify your email address',
                text: `Click the following link to verify your email address: ${process.env.BASE_URL}/verify?token=${verificationToken}`
                //text: `Click the following link to verify your email address: http://yourwebsite.com/verify?token=${verificationToken}`
            });
        
        } catch (error) {
            console.error('Error sending email:', error);
        }
        

        // Extract the newly inserted user_id from the result
        const newUser = result.rows[0];
        const userID = newUser.id;
        
        res.send(`User registered successfully. Please check your email for verification.`);
        return userID;
    } catch (error) {
        console.error('Error during registration:', error);
        res.status(500).send('Error registering user');
    }
});

// Route for handling email verification
app.get('/verify', async (req, res) => {
    try {
        const { token } = req.query;

        // Update the user's email verification status in the database
        const result = await db.query(
            "UPDATE users SET verified_email = true WHERE verification_token = $1 AND verified_email IS NULL",
            [token]
        );
        
        if (result.rowCount = 0) {
            // Email has already been verified
            await db.query(
                "INSERT INTO debug (message) VALUES ($1)",
                ["Email verification successful for token: " + token]
            );
        } else {
            // Email was not verified or token does not exist
            // Handle the error or do nothing
        }
        

        res.send('Email verified successfully. You can now log in.');
    } catch (error) {
        console.error('Error verifying email:', error);
        res.status(500).send('Error verifying email');
    }
});

// varify email on user registration
function generateToken() {
    // generate a random token
    return crypto.randomBytes(20).toString('hex');
}

// Passport configuration
passport.use(
    "local",
    new Strategy(async function verify(username, password, cb) {
        try {
        const result = await db.query("SELECT password, verified_email FROM users WHERE email = $1 ", [
            username,
        ]);
        if (result.rows.length > 0) {
            const user = result.rows[0];
            const storedHashedPassword = user.password;
            const emailVerified = user.verified_email;
            if (emailVerified) {
                bcrypt.compare(password, storedHashedPassword, (err, valid) => {
                if (err) {
                    console.error("Error comparing passwords:", err);
                    return cb(err);
                } else {
                    if (valid) {
                    return cb(null, user);
                    } else {
                    return cb(null, false);
                    }
                }
                });
            } else {
                return cb("Sorry, you have not completed email varification.  Please retry the registration process.");
            }
        } else {
            return cb("Sorry, we do not recognise you as an active user of our system.");
            // known issue: page should redirect to the register screen.  To reproduce this error enter an unknown username into the login screen
        }
        } catch (err) {
        console.error(err);
        }
    })
);

passport.serializeUser((user, cb) => {
cb(null, user);
});

passport.deserializeUser((user, cb) => {
cb(null, user);
});
  
// Middleware to check if user is authenticated
function isAuthenticated(req, res, next) {
    if (req.isAuthenticated()) {
        return next();
    }
    res.redirect('/login');
}






//------------------------------------
//---- Start the server
//-----------------------------------
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});


