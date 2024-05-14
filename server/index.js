import express from "express";
import cors from "cors";
import bodyParser from "body-parser";
import * as db from "./queries.js";

// Import controllers using ES modules syntax
import {
  getLocationById,
  getAllLocation,
  editLocation,
  deleteLocation,
  addLocation,
} from "./controllers/locationControllers.js";

import {
  getActivitiesByUserId,
  createActivity,
  updateActivity,
  deleteActivity,
  getAllActivities,
} from "./controllers/activitiesControllers.js";


import { getApproveTimeSheet, getRejectTimeSheet, getPendingTimeSheet, approveTimesheet, rejectTimesheet } from "./controllers/managerController.js";
import { isManager, getUserInfo, checkUserExist, editProfile, getManager, getMyManager } from "./controllers/userController.js";

import { getAllHolidays } from "./controllers/publicHollidayController.js";

import { 
  checkTimesheetExist,
  getTFR,
  postDayOff
 } from "./controllers/timeSheetsController.js";


import { getFundSources, getFundSourceById, createFundSource, updateFundSource, deleteFundSource } from "./controllers/fundSourcesConstroller.js"
import { getTotalHourByDate, getUserScheduleById } from "./controllers/userWorkingSheduleController.js";


const port = 4000;
const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use(
  bodyParser.urlencoded({
    extended: true,
  })
);

// ROUTES FOR THE TIMESHEETS CONTROLLERS
app.post("/tfr/:userID", getTFR);
app.post("/flexiDayOff/:userID", postDayOff);



// ROUTES FOR THE FUND SOURCE CONTROLLER
app.get("/fundSource", getFundSources);
app.get("/fundSource/:id", getFundSourceById);
app.post("/fundSource/create", createFundSource);
app.post("/fundSource/update", updateFundSource);
app.post("/fundSource/delete", deleteFundSource);


// ROUTES FOR USER WORKING SCHEDULE
app.get("/userSchedule/:userID", getUserScheduleById);
app.post("/totalHours/:userID", getTotalHourByDate);




// ROUTES FOR PUBLIC HOLIDAyS
app.get("/publicHolidays", getAllHolidays);

// ROUTES FOR ACTIVITIES Manager
app.get("/activities/:id", getActivitiesByUserId);
app.get("/activities", getAllActivities);
app.put("/createActivity", createActivity);
app.put("/updateActivity/:id", updateActivity);
app.post("/deleteActivity", deleteActivity);

// Define routes using the imported controllers
app.get("/location/:id", getLocationById);
app.get("/location", getAllLocation);
app.put("/editlocation/:id", editLocation);
app.post("/deletelocation", deleteLocation);
app.put("/addlocation", addLocation);

// Manager timeSheets approval 
app.get("/timesheet/pending/:userID", getPendingTimeSheet);
app.get("/timesheet/approved/:userID", getApproveTimeSheet);
app.get("/timesheet/reject/:userID", getRejectTimeSheet);
app.post("/timesheet/rejectTs/:userID",rejectTimesheet );
app.post("/timesheet/approveTs/:userID", approveTimesheet);


// Define other routes
app.get("/users", db.getUsers);
app.get("/login/:username", db.getUserByUsername);
app.get("/users/:id", db.getUserById);
app.post("/users", db.createUser);
app.put("/users/:id", db.updateUser);
app.put("/verify/:token", db.verifyUserEmail);
app.delete("/users/:id", db.deleteUser);
app.get("/rdo/:id", db.getRdoById);

app.get("/users/userInfo/:userID",getUserInfo);
app.get("/users/isManager/:userID", isManager);
app.post("/users/check", checkUserExist);
app.post("/users/update", editProfile);
app.get("/users/getManager/:userID", getManager );
app.get("/users/getMyManager/:userID", getMyManager);


// FOR TIMESHEETS ROUTES
app.get("/timesheetsbyid/:id", db.getTimesheetsById);
app.get("/timesheets/:id", db.getCurrentYearTimesheetsForUser);
app.put("/timesheets", db.createTimesheet);
app.post("/timesheets/:id/updateStatus", db.updateTimesheetStatus);
app.delete("/timesheets/:id", db.deleteTimesheet);

app.post("/timesheets/checkTimeSheetsExist", checkTimesheetExist);


app.listen(port, () => {
  console.log(`App running on port ${port}.`);
});
