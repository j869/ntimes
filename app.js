import express from "express";
import session from "express-session";
import passport from "passport";
import { Strategy } from "passport-local";   //import { Strategy as LocalStrategy } from 'passport-local';
import bodyParser from "body-parser";
import { body, validationResult } from 'express-validator';
import helmet from 'helmet';
import axios from "axios";
import bcrypt from "bcrypt";
import env from "dotenv";
import nodemailer from 'nodemailer';
import crypto from 'crypto';
import flash from 'express-flash';

const app = express();
const API_URL = "http://localhost:4000";
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
app.use(flash());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static("public"));
app.use(passport.initialize());
app.use(passport.session());

// const db = new pg.Client({
//   user: process.env.PG_USER,
//   host: process.env.PG_HOST,
//   database: process.env.PG_DATABASE,
//   password: process.env.PG_PASSWORD,
//   port: process.env.PG_PORT,
// });
// db.connect();


// // Middleware to log connections
// app.use((req, res, next) => {
//     // Define an inner async function to use await
//     const handleRequest = async () => {
//         const ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
//         const userAgent = req.headers['user-agent'];
//         const [browser, os] = parseUserAgent(userAgent);
//         const now = new Date().toISOString();
//         //    const sessionId = await bcrypt.hash(req.sessionID, 10);    
//         const hashedSessionId = await bcrypt.hash(req.sessionID, 10);            //more secure against session hijacking attacks.
//         const sessionId = hashedSessionId.substring(0, 8); // Extract a portion of the hash
//         const sanitizedBody = { ...req.body };          // Clone the req.body object to avoid modifying the original request
//         if (sanitizedBody.hasOwnProperty('password')) {
//             sanitizedBody.password = '***';         // dont reveal the unhashed password in the logging table
//         } 
//         const reqJSON = JSON.stringify({
//         endpoint: req.originalUrl,
//         params: req.params,
//         query: req.query,
//         body: sanitizedBody
//         });

//         // Check if the session ID is valid (recognized by passport)
//         if (!req.isAuthenticated()) {
//             console.error(`Attempted session hijacking attack detected: Session ID ${sessionId}`);
//         }        

//         db.query(      // Insert data into the debug table
//         'INSERT INTO debug (timestamp, ip_address, session_id, browserOS, agent, request) VALUES ($1, $2, $3, $4, $5, $6)',
//         [now, ip, sessionId, browser + " on " + os, userAgent, reqJSON],
//         (err, result) => {
//             if (err) {
//             console.error('Error inserting data into debug table:', err);
//             } else {
//             //console.log('Data inserted into debug table:', result.rows);
//             }
//         }
//         );

//     }

//     // Call the async function immediately
//     handleRequest().then(() => {
//         next();
//     }).catch(next);
//   });
  
//   // Function to parse user agent string and extract browser and OS information
//   function parseUserAgent(userAgent) {
//     // Use a library like 'useragent' for more accurate parsing
//     // This is a basic example
//     const browserMatch = userAgent.match(/(Firefox|Chrome|Safari|Opera|MSIE)\/([\d.]+)/);
//     const osMatch = userAgent.match(/\((Windows NT [\d.]+|Macintosh|Linux|iPhone|iPad|Android)\)/);
//     const browser = browserMatch ? browserMatch[1] : 'Unknown';
//     let os = osMatch ? osMatch[1] : 'Unknown';
//     if (os.startsWith('Windows')) {
//         os = 'Windows NT 10.0'; // or extract the actual version if available
//     }
//     return [browser, os];
// }








//--------------------------------
//----  Define routes
//-------------------------------
// app.get('/', (req, res) => {
//     res.render('home.ejs', { user: req.user, title: 'Home', body: '' }); 
// });
app.get('/', (req, res) => {
    console.log("Default route: Rendering login page...");
    res.render('home.ejs', { user: req.user, title: 'Home', body: '' }); 
});



app.get("/users/:id", isAuthenticated, async (req, res) => {
    console.log("v1      Protected route: Fetching user data...", req.params);
    if (req.isAuthenticated()) {
        try {
            console.log(`v2      ${API_URL}/users/${req.params.id}`)
            const response = await axios.get(`${API_URL}/users/${req.params.id}`);
            console.log("v3    ", response.data[0]);
            //res.send(response.data);
            const errors = req.flash('error');
            const messages = errors.map(error => error.msg);
            res.render("profile.ejs", { title : 'Edit Profile', currentUser : req.user, userData : response.data[0], messages})
            console.log("v4 ")
        } catch (error) {
            console.error("Error fetching user data:", error);
            res.status(500).send("Error fetching user data");
            console.log("v7 ")
        }
    } else {
        res.redirect("/login");
    }
    console.log("v9 ")
});

app.get('/profile', isAuthenticated, (req, res) => {
    console.log("p1    ", req.user)
    res.render('profile.ejs', { user: req.user });
});




//--------------------------------
//---  Admin functions
//-------------------------------
//#region admin

app.get('/users', isAdmin, async (req, res) => {
    console.log("u1    Admin route: Rendering settings page...");
    const result = await axios.get(`${API_URL}/users`);
    const errors = req.flash('error');
    console.log("u2    ", errors)
    const messages = errors.map(error => error.msg);
    console.log("u3    ", messages)
    res.render('settings.ejs', { user: req.user, users: result.data, messages: messages });
    console.log("u9")
});

// add new user with admin rights
// app.get('/users', async (req, res) => {
//     console.log("Admin route: Rendering settings page...");
//     const result = await axios.get(`${API_URL}/users`);
//     res.render('settings', { users: result.data });
// });

app.post('/addUser', isAdmin, [
    //body('username').notEmpty().withMessage('Username is required'),
    body('email').isEmail().withMessage('Invalid email format'),
    body('password').notEmpty().withMessage('Password is required'),
    //body('role').notEmpty().withMessage('Role is required'),
], async (req, res) => {
    console.log("au01    ", req.user);
    const errors = validationResult(req);
    console.log("au03    ");
    if (!errors.isEmpty()) {
        //req.flash('messages', errors.array()); 
        //req.flash('message', 'test()'); 
        //return res.status(400).json({ errors: errors.array() });
        console.log("au04 ", errors)
        req.flash('error', errors.array());
        return res.redirect('/users');
//        return res.render("settings.ejs", {user:req.user, messages : errors.array()});        
    }

    const { username, email, password, role } = req.body;
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    console.log('au05    hashedPassword',hashedPassword);

    // Generate a verification token
    const verificationToken = generateToken();
    console.log("au07    ", verificationToken);


    console.log("au09    ");

    try {
        // Insert a new user record into the users table with the verification token
        const result = await axios.post(`${API_URL}/users`, {username, email, hashedPassword, verificationToken : "created by " + req.user.username, "role" : "user" });
        // const result = await db.query(
        //     "INSERT INTO users (email, password, verification_token) VALUES ($1, $2, $3) RETURNING *",
        //     [email, hashedPassword, verificationToken]
        // );
        //const response = await axios.post(`${API_URL}/users`, req.body);
        console.log("added user.  returned this: ", result.data);
        res.redirect('/users');
    } catch (error) {
        console.error("Error fetching user data:", error);
        res.status(500).send("Error fetching user data");
    }

});
//#endregion



//--------------------------------
//---  Authorisation
//-------------------------------
//#region Authorisation

app.get('/login', (req, res) => {
    console.log("li1");
    const errors = req.flash('error');
    console.log("li2     ", errors);
    res.render('login.ejs', { messages: errors });
});

// app.post('/login', passport.authenticate('local', {
//     successRedirect: '/profile',
//     failureRedirect: '/login'
// }));
app.post('/login', passport.authenticate('local', {
    successRedirect: '/users',
    failureRedirect: '/',
    failureFlash: true
}));


app.get('/logout', (req, res) => {
    console.log("lo1")
    req.logout(() => {
        res.redirect('/');
    });
});


app.get('/register', (req, res) => {
    console.log("r1")
    res.render('register.ejs',  { messages: req.flash('error') }); 
});

// Handler for registration form submission
app.post('/register', async (req, res) => {
    try {
        console.log("reg1     ", req.body)
        const { email, password } = req.body;
        const hashedPassword = await bcrypt.hash(password, saltRounds);

        // Generate a verification token
        const verificationToken = generateToken();
        console.log("reg2")

        // Insert a new user record into the users table with the verification token
        const result = await axios.post(`${API_URL}/users`, {'username' : email, email, 'password' : hashedPassword, verificationToken, "role" : "user" });
        // const result = await db.query(
        //     "INSERT INTO users (email, password, verification_token) VALUES ($1, $2, $3) RETURNING *",
        //     [email, hashedPassword, verificationToken]
        // );
        if (result.status === 201) { 
            console.log("reg2.1    User added successfully")
        }
        console.log("reg2.2    ")
        // Extract the newly inserted user_id from the result
        const userID = result.data.id;
        console.log("reg2.5    ", userID)
        
        console.log("reg3")
        try {
            // Send verification email
            console.log("reg4")
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
            console.log("reg5")
            await transporter.sendMail({
                from: 'john@buildingbb.com.au',
                to: email, 
                subject: 'Please verify your email address',
                text: `Click the following link to verify your email address: ${process.env.BASE_URL}/verify?token=${verificationToken}`
                //text: `Click the following link to verify your email address: http://yourwebsite.com/verify?token=${verificationToken}`
            });
            console.log("reg6")
        } catch (error) {
            console.log("reg7")
            console.error('Error sending email:', error);
        }
        

        
        res.send(`User registered successfully. Please check your email for verification.`);
        console.log("reg9   ", userID)
        return userID;
    } catch (error) {
        if (error.response.status === 400 ) {
            console.log("reg91")
            return res.render("register.ejs", {messages : ['this email is already registered']});
        }
        
        console.log("reg99")
        console.error('Error during registration:', error);
        res.status(500).send('Error registering user');
    }
});

// Route for handling email verification
app.get('/verify', async (req, res) => {
    console.log("ve1")
    try {
        const { token } = req.query;
        console.log("ve2")

        // Update the user's email verification status in the database
        console.log(`ve3    Fetching user: ${API_URL}/verify/${token}`);
        const result = await axios.put(`${API_URL}/verify/${token}`);
        console.log("ve8");
        req.flash('error', 'Email verified successfully. You can now log in');
        console.log("ve9");
        return res.redirect("/login");
    } catch (error) {
        console.log("ve99")
        console.error('Error verifying email:', error);
        return res.status(500).send('Error verifying email');
    }
});

// varify email on user registration
function generateToken() {
    // generate a random token
    return crypto.randomBytes(20).toString('hex');
}

// Passport configuration
passport.use("local", new Strategy(async function verify(username, password, cb) {
    console.log("LocalStrategy: Authenticating user...");

        try {
            //const result = await db.query("SELECT password, verified_email FROM users WHERE email = $1 ", [                username,            ]);
            console.log(`ps1     Fetching user: ${API_URL}/login/${username}`);
            const result = await axios.get(`${API_URL}/login/${username}`);
            //console.log("ps2     result: ", result);



            const user = result.data[0];
            
            // Check if user exists
            // if (!user) {
            //     console.log("ps3")
            //     return cb(null, false, { message: 'Incorrect username.' });
            // }

            //check if user is verified
            const emailVerified = user.verified_email;
            console.log("ps4")
            if (!emailVerified) {
                console.log("ps5");
                return cb(null, false, { message: 'Email has not been verified.' });                
            }

            // Compare passwords
            console.log("ps6");
            const storedHashedPassword = user.password;
            bcrypt.compare(password, storedHashedPassword, (err, valid) => {
                console.log("ps7");
                if (err) {
                    console.log("ps8");
                    return cb(null, false, { message: 'Error comparing passwords.' });   
                } else {
                    console.log("ps9");
                    if (valid) {
                        console.log("ps10");
                        return cb(null, user, { message: 'Success.' });
                    } else {
                        console.log("ps11");
                        return cb(null, false, { message: 'Incorrect password.' });
                    }
                }
            });
            console.log("ps12");
                // known issue: page should redirect to the register screen.  To reproduce this error enter an unknown username into the login screen
        } catch (err) {
            console.log("ps13");

            // Check for status 404 User not found
            if (err.response.status === 404) {
                console.log("ps14")
                console.log("Cannot find this username in the user table.");
                return cb(null, false, { message: 'User not found.' });
            } else {
                console.log("ps15")
                console.error("Error during authentication:", err);
                return cb(err)
            }

        }
        console.log("ps16")
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


function isAdmin(req, res, next) {
    if (req.user && req.user.role === 'admin') {
        return next();
    } else {
        return res.status(403).json({ message: 'Permission denied' });
    }
}


//#endregion



//------------------------------------
//---- Start the server
//-----------------------------------
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});







