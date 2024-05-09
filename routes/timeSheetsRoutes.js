import { Router } from "express";
import axios from "axios";

const createTimesheetRoutes = (isAuthenticated) => {
    console.log("tsr1     ")
    const router = Router();
    const API_URL = process.env.API_URL;

    

    router.post("/flexiDayOff", isAuthenticated, async (req, res) => {
        
        const userID = req.user.id;
        const dayOffOption = req.body.dayOffOption;
        const workDate = req.body.workDate
        const flexiInput = req.body.flexiInput
        const tilInput = req.body.tilInput

        // console.log("this is the most gwapo: " + dayOffOption)

        try {
            await axios.post(`${API_URL}/flexiDayOff/${userID}`, { dayOffOption, workDate, flexiInput, tilInput });
            res.redirect("/time")
   
        } catch (error) {
            res.status(500).json({ error: error });
        }
    });

    return router;
};

export default createTimesheetRoutes;
