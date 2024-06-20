import { Router } from "express";
import axios from "axios";
import axiosRetry from 'axios-retry';

axiosRetry(axios, { retries: 3, retryDelay: axiosRetry.exponentialDelay });

const createManagerRoutes = (isAuthenticated) => {
  const router = Router();
  const API_URL = process.env.API_URL;


  // Set a timeout for all axios requests
  const axiosInstance = axios.create({
    timeout: 5000, // 5 seconds timeout
  });


  router.get("/pending", isAuthenticated, async (req, res) => {
    console.log("mrp1     ")
    const data = await axios.get(`${API_URL}/timesheet/pending/${req.user.id}`);
    const timesheetIssues = await axios.get(`${API_URL}/timesheet/getAllIssues`);
    const userInfo = req.session.userInfo;

    console.log("timesheetIssues" , timesheetIssues.data)

    const status = req.query.status;
    let statusMessage = "";

    if (status == 202) {
      statusMessage = "Update Successfully!"
    } else if (status == 500) {
      statusMessage = "Something went wrong. Try Again!"
    }

    res.render("user/manager/pendingTimeSheets.ejs", {
      user: req.user,
      data: data.data,
      timesheetIssues: timesheetIssues.data,
      userInfo: userInfo,
      messages: req.flash(""),
      statusMessage: statusMessage,
      title: "Pending Timesheets",
    });
  });

  router.get("/approved", isAuthenticated, async (req, res) => {
    console.log("mra1     ")
    const data = await axios.get(`${API_URL}/timesheet/approved/${req.user.id}`);
    const userInfo = req.session.userInfo;

    const status = req.query.status;
    let statusMessage = "";

    if (status == 202) {
      statusMessage = "Update Successfully!"
    } else if (status == 500) {
      statusMessage = "Something went wrong. Try Again!"
    }


    res.render("user/manager/approvedTimeSheets.ejs", {
      user: req.user,
      data: data.data,
      userInfo: userInfo,
      statusMessage: statusMessage,
      messages: req.flash(""),
      title: "Approved Timesheets",
    });
  });


  router.post("/approveTs", isAuthenticated, async (req ,res) => {
    console.log("mrp1     ")
    const ts_id = req.body.ts_id
    const back_page = req.query.page
  try {
    await axios.post(`${API_URL}/timesheet/approveTs/${req.user.id}`, {ts_id});

    res.redirect(`/timesheet/${back_page}?status=202`);

    
  } catch (error) {
    console.error("Error updating location:", error);
    res.redirect(`/timesheet/${back_page}?status=500`);

    res
      .status(500)
      .json({ success: false, error: "Error updating location" });
  }





  })

  
  router.post("/multipleApproveTs", isAuthenticated, async(req,res) => {
    const ts_ids = JSON.parse(req.body.ids)
    const back_page = req.query.page

    // console.log("gwawad", ts_ids)


  try {

    await Promise.all(ts_ids.map(ts_id => 
      axios.post(`${API_URL}/timesheet/approveTs/${req.user.id}`, {ts_id})
    ));

    res.redirect(`/timesheet/${back_page}?status=202`);

    
  } catch (error) {
    console.error("Error updating location:", error);
    res
      .status(500)
      .json({ success: false, error: "Error updating location" });
  }

  })

  router.post("/multipleRejectTs", isAuthenticated, async(req,res) => {
    const ts_ids = JSON.parse(req.body.ids)
    const back_page = req.query.page

    // console.log("gwawad", ts_ids)


  try {

    await Promise.all(ts_ids.map(ts_id => 
      axios.post(`${API_URL}/timesheet/rejectTs/${req.user.id}`, {ts_id})
    ));

    res.redirect(`/timesheet/${back_page}?status=202`);

    
  } catch (error) {
    console.error("Error updating location:", error);
    res
      .status(500)
      .json({ success: false, error: "Error updating location" });
  }

  })

  router.post("/rejectTs", isAuthenticated, async (req ,res) => {
    console.log("mrj1     ")
    const ts_id = req.body.ts_id
    const back_page = req.query.page
  try {
    await axios.post(`${API_URL}/timesheet/rejectTs/${req.user.id}`, {ts_id});

    res.redirect(`/timesheet/${back_page}?status=202`);
    
  } catch (error) {
    console.error("Error updating location:", error);
    res
      .status(500)
      .json({ success: false, error: "Error updating location" });
  }


  })


  router.get("/rejected", isAuthenticated, async (req, res) => {
    console.log("mrr1     ")
    const data = await axios.get(`${API_URL}/timesheet/reject/${req.user.id}`);
    const userInfo = req.session.userInfo;


    const status = req.query.status;
    let statusMessage = "";

    if (status == 202) {
      statusMessage = "Update Successfully!"
    } else if (status == 500) {
      statusMessage = "Something went wrong. Try Again!"
    }



    res.render("user/manager/rejectedTimeSheets.ejs", {
      user: req.user,
      data: data.data,
      userInfo: userInfo,
      statusMessage: statusMessage,
      messages: req.flash(""),
      title: "Rejected Timesheets",
    });
  });


  router.post("/approveManager", isAuthenticated, async (req, res) => {
    const managerID = req.body.managerID;
    const userID = req.body.userID;
    const notificationID = req.body.notificationID;

    console.log("userID: " + userID);
    console.log("managerID: " + managerID);
    console.log("notificationID: " + notificationID);

    try {
        await axios.post(`${API_URL}/users/assignManager/${managerID}?userID=${userID}&notificationID=${notificationID}`);
        res.redirect("/notification");
    } catch (err) {
        console.log("ASSIGNing Manager error: ", err);
        res.status(500).send("Error assigning manager");
    }
});






  return router;
};

export default createManagerRoutes;
