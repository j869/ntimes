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

    const formatDate = (dateString) => {
        const date = new Date(dateString);
        const options = { day: '2-digit', month: 'short', year: 'numeric' };
        return date.toLocaleDateString('en-US', options);
    };

        // Filter the result.data array to include only the required fields
        const filteredData = result.data.map(entry => ({
            id: entry['id'],
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
            notes: entry['notes'],
            status: entry['status']
        }));
    res.render('timesheet/main.ejs', { title : 'Numbat Timekeeper', user: req.user, tableData: filteredData, messages: req.flash('messages') });
    console.log("t9  returned users timesheets ")


});

app.get('/timesheetEntry', isAuthenticated, async (req, res) => {
    console.log(`y1   `, req.query.date);
    
    const date = req.query.date; // Pick up the date from the URL parameter
    res.render('timesheet/recordHours.ejs', {forDate : date, user : req.user, title : 'Enter Timesheet', messages : req.flash('messages')})

});


const isValidTimeFormat = (value) => {
    return /^(?:[01]\d|2[0-3]):[0-5]\d$/.test(value);  // Custom validation function for time format (hh:mm)
};

app.post('/timesheetEntry', isAuthenticated, [
    // Validate request body
    body('work_date').optional().isISO8601().toDate().withMessage('Invalid date format'),
    body('time_start').optional().custom(isValidTimeFormat).withMessage('Invalid time format for time_start (hh:mm)'),
    body('time_finish').optional().custom(isValidTimeFormat).withMessage('Invalid time format for time_finish (hh:mm)'),
    body('time_lunch').optional().custom(isValidTimeFormat).withMessage('Invalid time format for time_lunch (hh:mm)'),
    body('time_extra_break').optional().custom(isValidTimeFormat).withMessage('Invalid time format for time_extra_break (hh:mm)'),
    //body('time_total').optional().custom(isValidTimeFormat).withMessage('Invalid time format for time_total (hh:mm)'),      //calculated field
    body('location_id').optional().isInt().withMessage('Invalid entry for location_id'),
    body('fund_src').optional().isString().withMessage('Invalid string format for fund_src'),
    body('activity').optional().isString().isLength({ max: 30 }).withMessage('Activity must be less than 31 characters'),
    body('comment').optional().isString().withMessage('Invalid string format for comment'),
    body('variance').optional().isString().withMessage('Invalid string format for variance'),
    body('notes').optional().isString().withMessage('Invalid string format for notes'),
    // body('flexi_accrued').optional().isNumeric().withMessage('Invalid numeric format for flexi_accrued'),
    // body('flexi_taken').optional().isNumeric().withMessage('Invalid numeric format for flexi_taken'),
    // body('til_accrued').optional().isNumeric().withMessage('Invalid numeric format for til_accrued'),
    // body('til_taken').optional().isNumeric().withMessage('Invalid numeric format for til_taken')
], async (req, res) => {
    console.log("n10 ", req.body);
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        req.flash('messages', errors.array().map(error => error.msg));
        return res.redirect('/time');
    }

    try {
        const { work_date, time_start, time_finish, time_lunch, time_extra_break, time_total, location_id, fund_src, activity, comment, variance, notes, flexi_accrued, flexi_taken, til_accrued, til_taken } = req.body;
        let { variance_type, time_leave, time_overtime } =  req.body;   

        console.log('n15   variance', variance)
        if (variance === '') {
            variance_type = '';    // timesheet has no variance, tidy up data set
            console.log('n16   variance_type', variance_type)
        } 
        const currentDate = new Date();
        
        //set calculated fields
        let time_total_numeric = parseFloat(time_total);
        let flexi_accrued_numeric = flexi_accrued.trim() !== '' ? parseFloat(flexi_accrued) : 0;
        let flexi_taken_numeric = flexi_taken.trim() !== '' ? parseFloat(flexi_taken) : 0;
        let til_accrued_numeric = til_accrued.trim() !== '' ? parseFloat(til_accrued) : 0;
        let til_taken_numeric = til_taken.trim() !== '' ? parseFloat(til_taken) : 0;
        let time_leave_numeric = time_leave.trim() !== '' ? parseFloat(time_leave) : 0;
        let time_overtime_numeric = time_overtime.trim() !== '' ? parseFloat(time_overtime) : 0;
        const on_duty = activity.startsWith("Rest Day") ? 0 : 1;

        let time_flexi = null;
        let time_til = null;
        time_leave = null;
        time_overtime = null;
        if (variance_type === 'flexi') {
            time_flexi = flexi_accrued_numeric - flexi_taken_numeric;
            console.log('n21 ' + time_flexi + ' ' + flexi_accrued_numeric + ' ' + flexi_taken_numeric)
        } else if (variance_type === 'til') {
            time_til = til_accrued_numeric - til_taken_numeric;
            console.log('n22  ', time_til )
        } else if (variance_type === 'leave') {
            time_leave = time_leave_numeric;
            console.log('n23  ', time_leave )
        } else if (variance_type === 'overtime') {
            time_overtime = time_overtime_numeric;
            console.log('n24  ', time_overtime )
        }    else {
            console.log('n25   mixed not working' )   // mixed is not completed
        }

        // Insert a new timesheet 
        console.log('n26  ', req.user);
        console.log(`n27      ${API_URL}/timesheets`)
        const result = await axios.put(`${API_URL}/timesheets`, {
            person_id: req.user.id,
            username : req.user.username,
            work_date,
            time_start,
            time_finish,
            time_lunch,
            time_extra_break,
            time_total,
            location_id,
            fund_src,
            activity,
            t_comment : comment,
            entry_date : currentDate,
            variance,
            variance_type,
            notes,
            time_flexi,
            time_til,
            time_leave,
            time_overtime,
            on_duty,       // 1 for work day, 0 if activity name begins with "Rest Day", ie. "Rest Day (Planned Burning)".
            duty_category : null,
            'status' : 'entered',
            rwe_day : null     //
        });
        console.log("n30   res.status: ", result.status)

        console.log("n90    New timesheet created");

        req.flash('messages', 'Thank you for entering your timesheet');
        return res.redirect('/time');
    } catch (error) {
        console.error("n80     Error creating timesheet:", error);
        req.flash('messages', 'An error occurred while creating the timesheet - the timesheet was not saved');
        return res.redirect('/time');
    }
});

app.get('/emergencyEntry', isAuthenticated, async (req, res) => {
    console.log(`yg1   `);

    let formData = {}; // Declare formData before assigning values to it

    try {
        const result = await axios.get(`${API_URL}/rdo/${req.user.id}`);
        console.log("yg2    user RDO ",  result.data);
        
        formData = {
            RDO: result.data[0].is_eligible,
        };
    } catch (error) {
        console.error("Error fetching RDO:", error);
        // Handle error appropriately, e.g., set formData.RDO to some default value
        formData = {
            RDO: null, // Set RDO to some default value or handle error case appropriately
        };
    }

    res.render('timesheet/emergencyResponse.ejs', {
        formData,
        user: req.user,
        title: 'Enter Timesheet',
        messages: req.flash('messages')
    });
});

app.post('/emergencyEntry', isAuthenticated, [
    // Validate request body
    body('work_date').optional().isISO8601().toDate().withMessage('Invalid date format'),
    body('activity').optional().isString().isLength({ max: 30 }).withMessage('Activity must be less than 31 characters'),
    body('comment').optional().isString().withMessage('Invalid string format for comment'),    
    body('notes').optional().isString().withMessage('Invalid string format for notes'),   
], async (req, res) => {
    console.log("eg1 ", req.body);     
    const errors = validationResult(req);
    const currentDate = new Date();
    if (!errors.isEmpty()) {
        req.flash('messages', errors.array().map(error => error.msg));
        return res.redirect('/time');
    }

    try {
        let { work_date, time_start, time_finish, time_lunch, time_extra_break, time_total, location_id, fund_src, activity, comment, variance, notes, flexi_accrued, flexi_taken, til_accrued, til_taken, pvWorkDay, commencedWork } = req.body;
        const onDuty = activity.startsWith("Rest Day") ? 0 : 1;
        let rweCol;
        console.log('eg22   ')
        
        if (pvWorkDay && commencedWork) {
            rweCol = 1;
            comment = "Rostered Workday";
            console.log('eg25   ' + rweCol)
        }
        if (comment == "no IRIS entry" && !activity.startsWith("Rest Day")) {
            console.log('eg28   ')
            req.flash('messages', 'We redirected you because you nominated that the timekeeper did not record the work day. Choose an activity like "Bushfire Readiness" from the activity column');
            return res.redirect("/timesheetEntry")
        }
        console.log(`eg50      ${API_URL}/timesheets`)
        const result = await axios.put(`${API_URL}/timesheets`, {
            person_id: req.user.id,
            username : req.user.username,
            work_date,
            location_id : null,     //set to the users home location, but add 'Emergency Readiness / Response' to the description
            fund_src : '000',    //always find 000 for emergency
            activity,
            t_comment : comment,
            entry_date : currentDate,
            notes,
            on_duty :  onDuty,       // 1 for work day, 0 if activity name begins with "Rest Day", ie. "Rest Day (Planned Burning)".
            duty_category : 2,      // Cells(CurRow, categoryCol) = 2  'Emergency Response
            'status' : 'entered',
            rwe_day : rweCol          //  If CheckBox1 And CheckBox2 Then Cells(CurRow, RWECol) = 1
        });
        console.log("eg70   res.status: ", result.status)

        console.log("eg90    New timesheet created");
        req.flash('messages', 'Thank you for entering your timesheet');
        return res.redirect('/time');    
    } catch {
        console.error("eg80     Error creating timesheet:", error);
        req.flash('messages', 'An error occurred while creating the timesheet - the timesheet was not saved');
        return res.redirect('/time');
    }
});

app.get('/plannedLeave', isAuthenticated, async (req, res) => {

    const result = await axios.get(`${API_URL}/timesheets/${req.user.id}`);
    console.log("t2    got " +  result.data.length + " timesheets ")

    // const flashMessages = req.flash('messages');
    // console.log("t3   ", flashMessages)
    // // const messages = flashMessages.map(message => message.msg);

    const formatDate = (dateString) => {
        const date = new Date(dateString);
        const options = { day: '2-digit', month: 'short', year: 'numeric' };
        return date.toLocaleDateString('en-US', options);
    };

    // Filter the result.data array to exclude entries where id === null
    const filteredData = result.data.filter(entry => entry['id'] !== null)
                                    .map(entry => ({
                                        work_date: formatDate(entry['work_date']),
                                        id: entry['id']
                                    }));

    
    // Render the leavePlanned.ejs file
    res.render('timesheet/leavePlanned.ejs', { workDays: filteredData, title: 'Leave Request', user: req.user, messages: req.flash('messages') });
});

app.post('/plannedLeave', isAuthenticated, [
    // Validate request body
    body('work_date').optional().isISO8601().toDate().withMessage('Invalid date format'),
    body('num_days').isInt({ min: 1 }).withMessage('Number of days must be a positive integer'),
    body('leave_approved').isIn(['true', 'false']).withMessage('Is your leave approved?'),
    body('notes').optional().isString().withMessage('Invalid string format for notes'),   
], async (req, res) => {
    console.log("pl1   ", req.body);
    const errors = validationResult(req);
    const currentDate = new Date();
    if (!errors.isEmpty()) {
        req.flash('messages', errors.array().map(error => error.msg));
        return res.redirect('/time');
    }

    try {    
        const { num_days, leave_approved, notes } =  req.body;   
        let workDate = new Date(req.body.work_date); // Start date for leave

        console.log(`pl4      ${API_URL}/timesheets`)
        for (let i = 0; i < num_days; i++) {
            //console.log(`pl5    Adding record for ${workDate.toLocaleDateString()}`);
            const result = await axios.put(`${API_URL}/timesheets`, {
                person_id: req.user.id,
                username: req.user.username,
                work_date: workDate.toISOString(), // Convert to ISO string
                activity: 'Approved Leave',
                entry_date: currentDate.toISOString(), // Convert to ISO string
                notes,
                on_duty: 0, // Off duty
                duty_category: 3, // Approved leave
                status: 'entered',
            });
            console.log(`pl6     Date=${workDate.toLocaleDateString()}: Status=${result.status === 201 ? 'success(201)' : 'error(' + result.status + ')'}`);

            // Increment work_date for the next day
            workDate.setDate(workDate.getDate() + 1);
        }

        console.log("pl9   ");
        res.redirect('/time');
    } catch {
        console.error("pl8     Error creating timesheet:", error);
        req.flash('messages', 'An error occurred while creating the timesheet - the timesheet was not saved');
        return res.redirect('/time');
    }
});

app.get('/deleteTimesheet/:id', async (req, res) => {
    console.log('de1  ');
    const timesheetId = req.params.id;
    try {
        console.log(`de3    ${API_URL}/timesheets/${timesheetId}`);
        const response = await axios.delete(`${API_URL}/timesheets/${timesheetId}`);
        
        console.log('de9  Timesheet deleted successfully:', response.data);
        return res.redirect('/time');
    } catch (error) {
        console.error('de8  Error deleting timesheet:', error.response ? error.response.data : error.message);
    }    
});

app.get('/approveTimesheet/:id', async (req, res) => {
    console.log('ap1  ', req.body);
    const timesheetId = req.params.id;
    const newStatus = 'approved';
    try {
        //const scrollY = req.query.scrollY || 0; // Store the current scroll position

        //const response = await axios.post(`${API_URL}/timesheets/${timesheetId}`);
        console.log(`ap3       ${API_URL}/timesheets/${timesheetId}/updateStatus`);
        const response = await axios.post(`${API_URL}/timesheets/${timesheetId}/updateStatus`, { status: newStatus });
        
        console.log('ap9     Timesheet updated successfully:', response.data);
        //return res.redirect(`/time?scrollY=${scrollY}`);
        return res.redirect(`/time`);
    } catch (error) {
        console.error('ap8      Error updating timesheet:', error.response ? error.response.data : error.message);
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
    const defaultEmail = process.env.DEFAULT_USER || "";
    res.render('login.ejs', { defaultEmail, user: req.user, title: 'numbat', body: '', messages: req.flash('messages') });

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
            return res.redirect('/time');
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







