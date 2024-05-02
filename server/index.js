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

import { getAllHolidays } from "./controllers/publicHollidayController.js";

import { 
  getTFR,
  postDayOff
 } from "./controllers/timeSheetsController.js";


import { getFundSources, getFundSourceById, createFundSource, updateFundSource, deleteFundSource } from "./controllers/fundSourcesConstroller.js"


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

// Define other routes
app.get("/profile/:id", db.getProfile);
app.put("/updateProfile/:id", db.updateProfile);
app.get("/users", db.getUsers);
app.get("/login/:username", db.getUserByUsername);
app.get("/users/:id", db.getUserById);
app.post("/users", db.createUser);
app.put("/users/:id", db.updateUser);
app.put("/verify/:token", db.verifyUserEmail);
app.delete("/users/:id", db.deleteUser);
app.get("/rdo/:id", db.getRdoById);

// Locations CRUD ENDS
app.get("/timesheetsbyid/:id", db.getTimesheetsById);
app.get("/timesheets/:id", db.getCurrentYearTimesheetsForUser);
app.put("/timesheets", db.createTimesheet);
app.post("/timesheets/:id/updateStatus", db.updateTimesheetStatus);
app.delete("/timesheets/:id", db.deleteTimesheet);

app.listen(port, () => {
  console.log(`App running on port ${port}.`);
});
