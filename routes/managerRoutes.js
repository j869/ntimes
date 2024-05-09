import { Router } from "express";
import axios from "axios";

const createManagerRoutes = (isAuthenticated) => {
  const router = Router();
  const API_URL = process.env.API_URL;




  router.get("/pending", isAuthenticated, async (req, res) => {
    console.log("mrp1     ")
    const data = await axios.get(`${API_URL}/timesheet/pending/${req.user.id}`);
    const userInfo = req.session.userInfo;

   
   
    console.dir(userInfo)

    res.render("user/manager/pendingTimeSheets.ejs", {
      user: req.user,
      data: data.data,
      userInfo: userInfo,
      messages: req.flash(""),
      title: "Pending Timesheets",
    });
  });

  router.get("/approved", isAuthenticated, async (req, res) => {
    console.log("mra1     ")
    const data = await axios.get(`${API_URL}/timesheet/approved/${req.user.id}`);
    const userInfo = req.session.userInfo;


    res.render("user/manager/approvedTimeSheets.ejs", {
      user: req.user,
      data: data.data,
      userInfo: userInfo,

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


    res.render("user/manager/rejectedTimeSheets.ejs", {
      user: req.user,
      data: data.data,
      userInfo: userInfo,

      messages: req.flash(""),
      title: "Rejected Timesheets",
    });
  });



  return router;
};

export default createManagerRoutes;
