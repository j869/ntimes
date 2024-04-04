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
} from "./controllers/locationControllers.js"; // Make sure to add the file extension

const port = 4000;
const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use(
  bodyParser.urlencoded({
    extended: true,
  })
);

// Define routes using the imported controllers
app.get("/location/:id", getLocationById);
app.get("/location", getAllLocation);
app.put("/editlocation/:id", editLocation);
app.post("/deletelocation", deleteLocation);
app.put("/addlocation", addLocation);

// Define other routes
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
