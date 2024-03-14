
//#region sources and documentation
//  this app was developed with the help of 
//      https://blog.logrocket.com/crud-rest-api-node-js-express-postgresql/
//#endregion


//#region middleware
const express = require('express')
const session = require("express-session");
const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;
const bodyParser = require('body-parser');
const { body, validationResult } = require('express-validator');
const helmet = require('helmet');
const axios = require("axios");

const app = express();
const port = 3000;
const API_URL = "http://localhost:4000";

// Set view engine to EJS
app.set('view engine', 'ejs');

// Middleware
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static("public"));
app.use(helmet());    //Configuring HTTP headers with Helmet helps protect your app from security issues like XSS attacks

// Session setup
app.use(session({
    secret: process.env.SESSION_SECRET || "mysecret", // Set your own secret
    resave: false,
    saveUninitialized: true,
}));



//#endregion

//#region Passport initialization
app.use(passport.initialize());
app.use(passport.session());

// Passport LocalStrategy configuration
passport.use(new LocalStrategy(
    async (username, password, done) => {
        console.log("LocalStrategy: Authenticating user...");

        try {
            // Fetch user credentials from the database
            console.log(`Fetching user: ${API_URL}/login/${username}`);
            const response = await axios.get(`${API_URL}/login/${username}`);
            const user = response.data[0];

            // Check if user exists
            if (!user) {
                return done(null, false, { message: 'Incorrect username.' });
            }

            // Compare passwords
            //const passwordMatch = await bcrypt.compare(password, user.password);
            const passwordMatch = (password === user.password && username === user.username);
            if (!passwordMatch) {
                return done(null, false, { message: 'Incorrect password.' });
            }

            // Authentication successful
            return done(null, user);

        } catch (error) {
            console.error("Error during authentication:", error);
            return done(error);
        }
    }
));
//#endregion




// Default route - render login page
app.get('/', (request, response) => {
    console.log("Default route: Rendering login page...");
    response.render("login");
});

// Login route - authenticate user
app.post('/login', passport.authenticate('local', {
    successRedirect: '/users/1',
    failureRedirect: '/',
    failureFlash: true // Show flash messages if configured
}));

// Login route - authenticate user
app.get('/users', isAdmin, async (req, res) => {
    console.log("Admin route: Rendering settings page...");
    const result = await axios.get(`${API_URL}/users`);
    res.render('settings', { users: result.data });
});


// Protected route - only accessible to authenticated users
app.get("/users/:id", async (req, res) => {
    console.log("Protected route: Fetching user data...");
    if (req.isAuthenticated()) {
        try {
            const response = await axios.get(`${API_URL}/users/${req.params.id}`);
            res.send(response.data);
        } catch (error) {
            console.error("Error fetching user data:", error);
            res.status(500).send("Error fetching user data");
        }
    } else {
        res.redirect("/login"); // Redirect unauthenticated users to login page
    }
});

// Route to handle form submission and add user to the database
app.post('/addUser', [
    // Define validation rules for each field
    body('username').notEmpty().withMessage('Username is required'),
    body('email').isEmail().withMessage('Invalid email format'),
    body('password').notEmpty().withMessage('Password is required'),
    body('role').notEmpty().withMessage('Role is required'),
], async (req, res) => {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    if (req.isAuthenticated()) {
        try {
            const response = await axios.post(`${API_URL}/users`, req.body);
            console.log("added user.  returned this: ", response.data);
            res.redirect('/users'); // Redirect to the page displaying all users
        } catch (error) {
            console.error("Error fetching user data:", error);
            res.status(500).send("Error fetching user data");
        }
    } else {
        res.redirect("/login"); // Redirect unauthenticated users to login page
    }
});

//#region authorisation for passport

function isAdmin(req, res, next) {
    if (req.user && req.user.role === 'admin') {
        return next();
    } else {
        return res.status(403).json({ message: 'Permission denied' });
    }
}

// Serialize and deserialize user
passport.serializeUser((user, cb) => {
    cb(null, user);
});

passport.deserializeUser((user, cb) => {
    cb(null, user);
});

// Start server
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});


//#endregion