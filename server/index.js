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
import { isManager, getUserInfo, checkUserExist, editProfile, getManager, getMyManager, assignManager, checkMyManger } from "./controllers/userController.js";

import { getAllHolidays } from "./controllers/publicHollidayController.js";

import { 
  checkTimesheetExist,
  editTimesheet,
  getIndividualTimesheetsById,
  getPendingIndividualTimesheet,
  getTFR,
  postDayOff
 } from "./controllers/timeSheetsController.js";


import { getFundSources, getFundSourceById, createFundSource, updateFundSource, deleteFundSource } from "./controllers/fundSourcesConstroller.js"
import { getTotalHourByDate, getUserScheduleById } from "./controllers/userWorkingSheduleController.js";
import { createNotification, deleteNotification, getAllNotificationsByUserId, getCountUnseenNotifications, getRecentNotifications, markAsSeen } from "./controllers/notificationController.js";
import { getAllIssues, scanIssues } from "./controllers/issuesController.js";


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

app.get("/timesheet/getAllIssues", getAllIssues);
app.put("/timesheet/scanIssues", scanIssues);



// NOTIFICATION ROUTES
app.get("/notification/getByUserId", getAllNotificationsByUserId);
app.post("/notification/add", createNotification);
app.get("/notification/recent", getRecentNotifications)
app.get("/notification/unseen/:userID", getCountUnseenNotifications)
app.get("/notification/seen/:userID", markAsSeen)
app.get("/notification/delete/:notificationID", deleteNotification);




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
app.post("/users/assignManager/:managerID", assignManager)
app.get("/users/checkMyManger/:id" , checkMyManger);


// FOR TIMESHEETS ROUTES
app.get("/timesheetsbyid/:id", db.getTimesheetsById);
app.get("/timesheets/:id", db.getCurrentYearTimesheetsForUser);
app.put("/timesheets", db.createTimesheet);
app.post("/timesheets/:id/updateStatus", db.updateTimesheetStatus);
app.delete("/timesheets/:id", db.deleteTimesheet);


app.post("/timesheets/checkTimeSheetsExist", checkTimesheetExist);
app.post("/timesheets/getTimesheetById/:id", getIndividualTimesheetsById);
app.get("/timesheets/getPendingTimesheetById/:id", getPendingIndividualTimesheet);
app.put("/timesheets/edit/:id", editTimesheet);


app.listen(port, () => {
  console.log(`App running on port ${port}.`);
});
