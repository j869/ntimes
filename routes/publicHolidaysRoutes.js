import { Router } from "express";
import axios from "axios";


const publicHolidaysRoutes = (isAuthenticated) => { 
    const router = Router();
    const API_URL = process.env.API_URL;

    // router.get("/plannedLeave", isAuthenticated, async (req, res) => {
    //     const publicHolidays = await axios.get(`${API_URL}/publicHolidays`);
        
    //     res.render("user/location/locationManager.ejs", {
    //       user: req.user,
    //       publicHolidays: publicHolidays.data,
    //       messages: req.flash("messages"),
    //       title: "Location Manager"
    //     });
    //   });

};

export default publicHolidaysRoutes;