import express from "express";
import cors from "cors";
import bodyParser from "body-parser";
import * as db from "./queries.js";
//#region middleware
const port = 4000;
const app = express();
app.use(cors()); //Handling CORS issues
app.use(bodyParser.json());
app.use(
  bodyParser.urlencoded({
    extended: true,
  })
);
//#endregion

app.get("/users", db.getUsers);
app.get("/login/:username", db.getUserByUsername);
app.get("/users/:id", db.getUserById);
app.post("/users", db.createUser);
app.put("/users/:id", db.updateUser);
app.put("/verify/:token", db.verifyUserEmail);
app.delete("/users/:id", db.deleteUser);

app.get("/rdo/:id", db.getRdoById);

app.get("/location/:id", db.getLocation);

app.get("/timesheets/:id", db.getCurrentYearTimesheetsForUser);
app.put("/timesheets", db.createTimesheet);
app.post("/timesheets/:id/updateStatus", db.updateTimesheetStatus);
app.delete("/timesheets/:id", db.deleteTimesheet);

app.listen(port, () => {
  console.log(`App running on port ${port}.`);
});
