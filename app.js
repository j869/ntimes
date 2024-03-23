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
if (process.env.SESSION_SECRET) {
    console.log('en1    npm middleware loaded ok');
} else {
    console.log('en9    you must run nodemon from Documents/ntimes/  : ', process.cwd());
    console.log('       rm -R node_modules');
    console.log('       npm cache clean --force');
    console.log('       npm i');
}


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
    const username = req.user && req.user.username ? " for " + req.user.username : "[]";
    console.log("z9    Home. User is " + username);
    res.render('home.ejs', { user: req.user, title: 'Home', body: '' }); 
});

//--------------------------------
//----  Authenticated users
//-------------------------------
//#region regular users



app.get('/time', isAuthenticated, async (req, res) => {
    console.log(`t1    ${API_URL}/timesheets/${req.user.id}`)

    const result = await axios.get(`${API_URL}/timesheets/${req.user.id}`);
    console.log("t2    got " +  result.data.length + " timesheets ")

    const flashMessages = req.flash('messages');
    console.log("t3   ", flashMessages)
    // const messages = flashMessages.map(message => message.msg);

    const formatDate = (dateString) => {
        const date = new Date(dateString);
        const options = { day: '2-digit', month: 'short', year: 'numeric' };
        return date.toLocaleDateString('en-US', options);
    };

        // Filter the result.data array to include only the required fields
        const filteredData = result.data.map(entry => ({
            work_date: formatDate(entry['work_date']),
            time_start: entry['time_start'],
            time_finish: entry['time_finish'],
            time_total: entry['time_total'],
            time_accrued: entry['time_accrued'],
            time_til: entry['time_til'],
            time_leave: entry['time_leave'],
            time_overtime: entry['time_overtime'],
            time_comm_svs: entry['time_comm_svs'],
            comment: entry['t_comment'],
            location_id: entry['location_id'],
            activity: entry['activity'],
            notes: entry['notes']
        }));
    res.render('timesheet/main.ejs', { user: req.user, tableData: filteredData, messages: flashMessages });
    console.log("t9  returned users timesheets ")


});

app.get('/timesheetEntry', isAuthenticated, async (req, res) => {
    console.log(`y1`);

    res.render('timesheet/recordHours.ejs', {user : req.user, title : 'Enter Timesheet', messages : req.flash('messages')})

});

app.post('/timesheetEntry', isAuthenticated, async (req, res) => {
    console.log("n1 ", req.body);

    try {
        const { work_date, time_start, time_finish, time_total, location_id, activity, comment, notes } = req.body;

        // Insert a new timesheet 
        console.log(`n2      ${API_URL}/timesheets`)
        const result = await axios.post(`${API_URL}/timesheets`, {
            person_id : req.user.id,
            work_date,
            time_start,
            time_finish,
            time_total,
            location_id,
            activity,
            comment,
            notes
        });
        console.log("n3   res.status: ", result.status)

        console.log("n9    New timesheet created");

        req.flash('messages', 'Thank you for entering your timesheet');
        return res.redirect('/time');
    } catch (error) {
        console.error("n8     Error creating timesheet:", error);
        req.flash('messages', 'An error occurred while creating the timesheet - the timesheet was not saved');
        return res.redirect('/time');
    }
});
//#endregion






//--------------------------------
//---  Admin functions
//-------------------------------
//#region admin

app.get('/users', isAdmin, async (req, res) => {
    console.log("u1    Admin route: Rendering settings page...");
    const result = await axios.get(`${API_URL}/users`);
    // const errors = req.flash('messages');
    // console.log("u2    ", errors)
    // const messages = errors.map(error => error.msg);
    // console.log("u3    ", messages)
    res.render('settings.ejs', { user: req.user, users: result.data, messages: req.flash('messages') });
    console.log("u9  all users displayed on screen ")
});

app.get("/users/:id", isAuthenticated, async (req, res) => {
    console.log("v1      Protected route: Fetching user data...", req.params);
    // if (req.isAuthenticated()) {
        try {
            console.log(`v2      ${API_URL}/users/${req.params.id}`)
            const response = await axios.get(`${API_URL}/users/${req.params.id}`);
            const q = response.data[0];
            const { password, ...userData } = q;     //remove password from being sent
            console.log("v3    ", userData);
            //res.send(response.data);
            const errors = req.flash('messages');
            const messages = errors.map(error => error.msg);
            res.render("profile.ejs", { title : 'Edit Profile', user : req.user, userData, messages})
            console.log("v4 ")
        } catch (error) {
            console.error("Error fetching user data:", error);
            res.status(500).send("Error fetching user data");
            console.log("v7 ")
        }
    // } else {
    //     res.redirect("/login");
    // }
    console.log("v9 user " + req.params.id + " returned ok")
});

// Custom validation middleware to limit character count
const characterLimit = (field, limit) => {
    return body(field).custom((value) => {
        if (value.length > limit) {
            throw new Error(`${field} is too long`);
        }
        return true;
    });
};

app.post('/addUser', isAdmin, [
    // Validate request body
    characterLimit('username', 31).withMessage('Username must be less than 31 characters'),
    body('username').notEmpty().withMessage('Username is required'),
    body('email').isEmail().withMessage('Invalid email format'),
    body('password').notEmpty().withMessage('Password is required'),
    body('role').notEmpty().withMessage('Role is required'),
], async (req, res) => {
    try {
        console.log("pau1   add user ", req.body)
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            console.log("pau2")
            //req.flash('messages', errors.array());
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
        console.log("pau3")

        // Register the user using the registerUser function
        const userID = await registerUser(userData);
        console.log("pau4")

        req.flash('messages', 'User added successfully');
        console.log("pau9")
        return res.redirect('/users');
    } catch (error) {
        console.error("pau8    Error adding user:", error);
        res.status(500).send("Error adding user");
    }
});

app.post("/editUser", isAdmin, async (req, res) => {
    console.log('p1     Request Body:', req.body);

    try {

        const { userID, username, email, password, role } = req.body;
        let userData = {
            userID, 
            username,
            email,
            password,
            role,
            verificationToken: 'updated by ' + req.user.username,
            verified_email: true,
        };
        console.log("p2   ", userData);

        if (password === '') {
            const { password, ...rest } = userData;     //remove password from being sent
            userData = rest;
        }
        console.log(`p3      ${API_URL}/users/${userID}`, userData);

       // const userID = await registerUser(userData);   // Register the user using the registerUser function
        const result = await axios.put(`${API_URL}/users/${userID}`, userData);
        console.log("p4")

        console.log('p9 Updated user:', result.data);

        req.flash('messages', 'User updated. Skipped email verification. Ensure that the correct email was used.');
        res.status(200).send('User information updated successfully');
    } catch (error) {
        console.error('Error updating user information:', error);
        res.status(500).send('Internal server error');
    }
});



//#endregion







//-------------------------------------------------
//---  Passport code and authorisation middleware
//-------------------------------------------------
//#region Authorisation

app.get('/login', (req, res) => {
    console.log("li1     get login route");
    // const errors = req.flash('messages');
    // console.log("li2     messages : ", errors);
    // res.render('login.ejs', { user: req.user, title: 'numbat', body: '', messages: errors });
    console.log("li9     ");
    res.render('login.ejs', { user: req.user, title: 'numbat', body: '', messages: req.flash('messages') });

});

app.post('/login', function(req, res, next) {
    passport.authenticate('local', function(err, user, info) {
        if (err) { return next(err); }
        if (!user) {
            req.flash('messages', 'Invalid username or password. Please try again.');
            return res.redirect('/login');
        }
        req.logIn(user, function(err) {
            if (err) { return next(err); }
            return res.redirect('/');
        });
    })(req, res, next);
});

app.get('/logout', (req, res) => {
    console.log("lo1")
    req.logout(() => {
        res.redirect('/');
    });
});

app.get('/register', (req, res) => {
    console.log("r1");
    res.render('register.ejs',  {title : 'Register', user: req.user,  messages: req.flash('messages') }); 
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
        if (verified_email !== true ) {
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
            console.log("ru6 user registered. check your email ");
        }

        return userID;
    } catch (error) {
        if (error.response && error.response.status === 400) {
            // Email already registered
            console.log("ru7 ")
            throw new Error('Email already registered');
        } else if (error.response && error.response.status === 500) {
            console.log("ru8 ")
        } else {
            console.log("ru9 ")
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
        //req.flash('messages', 'User registered successfully. Please check your email for verification.');
        req.flash('messages', 'Registration successful. Please check your email for verification.');
        console.log("gp9 registered user ok");
        res.redirect('/login');
    } catch (error) {
        if (error.message === 'Email already registered') {
            console.log("gp8 already reg'd");
            return res.render("register.ejs", { user : req.user, messages: ['This email is already registered'], title: 'Register' });
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
            req.flash('messages', 'Email verified successfully. You can now log in');
            console.log("ve5 Email verified successfully. You can now log in");
            return res.redirect("/login");
        } else if (result.status === 409) {
            console.log("ve6 Email has already been verified");
            req.flash('messages', 'Email has already been verified');
            return res.redirect("/login"); // Redirect to the login page or handle as appropriate
        } else {
            console.log("ve7 unknown error");
            req.flash('messages', 'Error verifying email');
            return res.redirect("/login"); // Redirect to the login page or handle as appropriate
        }
    } catch (error) {
        console.log("ve9");
        console.error('Error verifying email:', error);
        req.flash('messages', 'Error verifying email');
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
    console.log("ps0    LocalStrategy: Authenticating user...");

        try {
            //const result = await db.query("SELECT password, verified_email FROM users WHERE email = $1 ", [                username,            ]);
            console.log(`ps1     Fetching user: ${API_URL}/login/${username}`);
            const result = await axios.get(`${API_URL}/login/${username}`);
            //console.log("ps2     result: ", result);



            const user = result.data[0];
            
            // Check if user exists
            // if (!user) {
            //     console.log("ps3")
            //     return cb(null, false, { messages: 'Incorrect username.' });
            // }

            //check if user is verified
            const emailVerified = user.verified_email;
            console.log("ps4")
            if (!emailVerified) {
                console.log("ps5     email has not been verified - login failed");
                return cb(null, false, { messages: 'Email has not been verified.' });                
            }

            // Compare passwords
            console.log("ps6");
            const storedHashedPassword = user.password;
            bcrypt.compare(password, storedHashedPassword, (err, valid) => {
                console.log("ps7");
                if (err) {
                    console.log("ps8");
                    return cb(null, false, { messages: ['Error comparing passwords.'] });   
                } else {
                    console.log("ps9");
                    if (valid) {
                        console.log("ps10 password correct");
                        return cb(null, user, { messages: ['Success.'] });
                    } else {
                        console.log("ps11");
                        return cb(null, false, { messages: ['Incorrect password.'] });
                    }
                }
            });
            console.log("ps12");
                // known issue: page should redirect to the register screen.  To reproduce this error enter an unknown username into the login screen
        } catch (err) {
            console.log("ps13");

            // Check for status 404 User not found
            if (err.response.status === 404) {
                console.log("ps14    Cannot find this username in the user table.");
                return cb(null, false, { messages: ['User not found.'] });
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
    console.log("iau1");
    if (req.isAuthenticated()) {
        console.log("iau2    user is authenticated");
        return next();
    }
    console.log("iau9    user is not authenticated");
    res.redirect('/login');
}

function isAdmin(req, res, next) {
    console.log("iad1")
    if (req.user && req.user.role === 'admin') {
        console.log("iad2    user is not admin")
        return next();
    } else {
        console.log("iad3   user is admin")
        return res.status(403).json({ messages: ['Permission denied'] });
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







