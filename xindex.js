import express from "express";
import bodyParser from "body-parser";

const app = express();
const port = 3000;
const API_URL = "http://localhost:3000";

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static("public"));

import pg from "pg";
const db = new pg.Client({
    user : "postgres",
    host : "localhost",
    database : "nTimesSandbox",
    password : "Beowulf12",
    port : 5432,
});

db.connect();
let formData = {};
db.query("Select id, person_id, work_date, activity, notes, time_start, time_finish  from pv_ts_timesheet_t", (err, res) => {
    if (err) {
        console.error("help something went wrong!");
    } else {
        formData = res.rows;
    }
    console.log(formData);
   // db.end();
});

app.get("/edit", (req, res) => {
    //console.log(formData[0])
    res.render("index.ejs", {
        heading: "Edit a record",
        submit: "Update",
        userData: formData[0],
      });    
});

app.post("/rec/:id", async (req, res) => {
    console.log(req.params.id, req.body)
    const recID = req.params.id;
    let result = {}
    result = await db.query("UPDATE PV_TS_TIMESHEET_T SET Person_ID = "+ req.body.author +" ;");
    result = await db.query("COMMIT;");
    //console.log(result);
    res.redirect("/edit");
});

app.listen(port, () => {
    console.log('running on port ' + port + ".");
});



