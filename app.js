//--------------------------------------
//----  Program setup and dependancies
//--------------------------------------
//#region imports
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
import { error } from "console";

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

// Pass the config object to all EJS templates
const config = {
    baseUrl: process.env.BASE_URL    // 'http://localhost:3000'
};
app.use((req, res, next) => {
    res.locals.config = config;
    next();
});

//#region logging not used any more
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
//#endregion

//#endregion
app.get('/', (req, res) => {
    const username = req.user && req.user.username ? " for " + req.user.username : "";
    console.log("z9    Default route: Rendering login page" + username);
    res.render('home.ejs', { user: req.user, title: 'Home', body: '' }); 
});



//--------------------------------
//----  Authenticated users
//-------------------------------

app.get("/users/:id", isAuthenticated, async (req, res) => {
    console.log("v1      Protected route: Fetching user data...", req.params);
    // if (req.isAuthenticated()) {
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
    // } else {
    //     res.redirect("/login");
    // }
    console.log("v9 ")
});

app.get('/profile', isAuthenticated, (req, res) => {
    console.log("p1    ", req.user)
    res.render('profile.ejs', { user: req.user });
});

app.get('/timesheets', isAuthenticated, (req, res) => {
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
    // Validate request body
    body('username').notEmpty().withMessage('Username is required'),
    body('email').isEmail().withMessage('Invalid email format'),
    body('password').notEmpty().withMessage('Password is required'),
    body('role').notEmpty().withMessage('Role is required'),
], async (req, res) => {
    try {
        console.log("addUser.post.1")
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            console.log("addUser.post.2")
            req.flash('error', errors.array());
            return res.redirect('/users');
        }

        const { username, email, password, role } = req.body;
        const userData = {
            username,
            email,
            password,
            role,
            verificationToken: 'added by ' + req.user.username,
            verified_email: true,
        };
        console.log("addUser.post.3")

        // Register the user using the registerUser function
        const userID = await registerUser(userData);
        console.log("addUser.post.4")

        req.flash('success', 'User added successfully');
        console.log("addUser.post.9")
        return res.redirect('/users');
    } catch (error) {
        console.error("addUser.post.8    Error adding user:", error);
        res.status(500).send("Error adding user");
    }
});


//#endregion



//-------------------------------------------------
//---  Passport code and authorisation middleware
//-------------------------------------------------
//#region Authorisation

app.get('/login', (req, res) => {
    console.log("li1");
    const errors = req.flash('error');
    console.log("li2     ", errors);
    res.render('login.ejs', { user: req.user, title: 'numbat', body: '', messages: errors });
});

// app.post('/login', passport.authenticate('local', {
//     successRedirect: '/profile',
//     failureRedirect: '/login'
// }));
app.post('/login', passport.authenticate('local', {
    successRedirect: '/',
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
    res.render('register.ejs',  {title : 'Register', user: req.user,  messages: req.flash('error') }); 
});

const registerUser = async (userData) => {
    try {
        let { username, email, password, role, verificationToken, verified_email } = userData;
        console.log("ru1 ", userData)
        const hashedPassword = await bcrypt.hash(password, saltRounds);
        console.log("ru2 ", hashedPassword);

        // Generate a verification token
        if (!verificationToken) {
            verificationToken = generateToken();
            console.log("ru3 ", verificationToken)
        }
        if (verified_email !== true ) {
            verified_email = null;
            console.log("ru4   verified_email=null");
        }
        if (!username && !email) {
            throw new Error("Must have username or email");
        }
        if (!email) {
            email = username;
        }
        if (!username) {
            username = email;
        }
        // if (!role) {
        //     role = "user"
        // }
        if (!email || !password) {
            throw new Error("Email and password are required.");
        }

        // Insert a new user record into the users table with the verification token
        const result = await axios.post(`${API_URL}/users`, {
            username,
            email,
            'password': hashedPassword,
            role,
            verificationToken,
            verified_email
        });
        
        // Extract the newly inserted user_id from the result
        const userID = result.data.id;
        console.log("ru5 ", userID)

        // Send verification email
        const transporter = nodemailer.createTransport({
            host: 'cp-wc64.per01.ds.network',
            port: 587,
            secure: false,
            requireTLS: true,
            auth: {
                user: process.env.SMTP_EMAIL,
                pass: process.env.SMTP_PASSWORD
            }
        });

        await transporter.sendMail({
            from: 'john@buildingbb.com.au',
            to: email,
            subject: 'Please verify your email address',
            text: `Click the following link to verify your email address: ${process.env.BASE_URL}/verify?token=${verificationToken}`
        });
        console.log("ru9 success ");

        return userID;
    } catch (error) {
        if (error.response && error.response.status === 400) {
            // Email already registered
            console.log("ru7 ")
            throw new Error('Email already registered');
        } else {
            console.log("ru8 ")
            throw error; // Other errors
        }
    }
};

// Handler for registration form submission
app.post('/register', async (req, res) => {
    try {
        let { email, password } = req.body;
        console.log("gp1   ", req.body);
        await registerUser({ email, password, role: 'user' });
        req.flash('success', 'User registered successfully. Please check your email for verification.');
        console.log("gp9 success");
        return res.redirect('/login');
    } catch (error) {
        if (error.message === 'Email already registered') {
            console.log("gp8 already reg'd");
            return res.render("register.ejs", { messages: ['This email is already registered'], title: 'Register' });
        } else {
            console.log("gp7 db error");
            console.error('Error during registration:', error);
            return res.status(500).send('Error registering user');
        }
    }
});


// Route for handling email verification
app.get('/verify', async (req, res) => {
    console.log("ve1");
    try {
        const { token } = req.query;
        console.log("ve2");

        // Update the user's email verification status in the database
        console.log(`ve3    Fetching user: ${API_URL}/verify/${token}`);
        const result = await axios.put(`${API_URL}/verify/${token}`);

        // Check if the email verification was successful
        if (result.status === 200) {
            console.log("ve4");
            req.flash('success', 'Email verified successfully. You can now log in');
            console.log("ve5 success");
            return res.redirect("/login");
        } else if (result.status === 409) {
            console.log("ve6 Email has already been verified");
            req.flash('error', 'Email has already been verified');
            return res.redirect("/login"); // Redirect to the login page or handle as appropriate
        } else {
            console.log("ve7 unknown error");
            req.flash('error', 'Error verifying email');
            return res.redirect("/login"); // Redirect to the login page or handle as appropriate
        }
    } catch (error) {
        console.log("ve9");
        console.error('Error verifying email:', error);
        req.flash('error', 'Error verifying email');
        return res.redirect("/login"); // Redirect to the login page or handle as appropriate
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
                console.log("ps5     email has not been verified - login failed");
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
    console.log("iauth1");
    if (req.isAuthenticated()) {
        console.log("iauth1");
        return next();
    }
    res.redirect('/login');
}


function isAdmin(req, res, next) {
    console.log("iad1")
    if (req.user && req.user.role === 'admin') {
        console.log("iad2")
        return next();
    } else {
        console.log("iad3")
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







