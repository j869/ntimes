import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import * as db from './queries.js';

const port = 4000
//const db = require('./queries')

//Handling CORS issues
const app = express();
app.use(cors())

// //Dont use CORS
// const express = require('express')
// const app = express()

//bodyParser middleware
app.use(bodyParser.json())
app.use(
bodyParser.urlencoded({
    extended: true,
})
)

// // Error-handling Middleware
// app.use((err, req, res, next) => {
//     console.error('Error:', err.message);
//     res.status(500).send('Internal Server Error');
// });
// example of error handling middleware
// app.use((req, res, next) => {
//     const error = new Error('Something went wrong');
//     next(error);
// });


app.get('/users', db.getUsers)
app.get('/login/:username', db.getUserByUsername)
app.get('/users/:id', db.getUserById)
app.post('/users', db.createUser)
app.put('/users/:id', db.updateUser)
app.put('/verify/:token', db.verifyUserEmail)
app.delete('/users/:id', db.deleteUser)

app.get('/timesheets/:id', db.getCurrentYearTimesheetsForUser)
app.post('/timesheets', db.createTimesheet)





app.listen(port, () => {
console.log(`App running on port ${port}.`)
})