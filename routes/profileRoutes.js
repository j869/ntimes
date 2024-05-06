import { Router } from "express";
import axios, { all } from "axios";

const createProfileRoutes = (isAuthenticated) => {

  const router = Router();
  const API_URL = process.env.API_URL;


  function getPayPeriods(startDate, endDate, scheduleDays) {
    const allDateSchedules = [];
    const payPeriods = [];

    let currentDate = new Date(startDate);

    // Populate allDateSchedules with all scheduled days within the date range
    while (currentDate <= endDate) {
        const dayOfWeek = currentDate.getDay();
        if (scheduleDays.includes(getDayOfWeekName(dayOfWeek))) {
            allDateSchedules.push(new Date(currentDate));
        }
        currentDate.setDate(currentDate.getDate() + 1);
    }


    let i = allDateSchedules.length - 1;
    let payDayIndex = scheduleDays.length;
    let startDay = getDayOfWeekName(allDateSchedules[0].getDay());

    // Determine pay periods based on the last scheduled day within each pay period
    while (i > 0) {
        if (i > scheduleDays.length - 1) {



            payPeriods.push(allDateSchedules[payDayIndex]);
            payDayIndex += scheduleDays.length
            i -= scheduleDays.length;
        } else {
            payPeriods.push(allDateSchedules[allDateSchedules.length - 1]);
            i = 0;
        }
    }

    return payPeriods;
}

// Function to get the name of the day of the week
function getDayOfWeekName(dayOfWeek) {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[dayOfWeek];
}


router.get("/", isAuthenticated, async (req, res) => {
    const data = await axios.get(`${API_URL}/users/userInfo/${req.user.id}`);
    const userSchedule = await axios.get(`${API_URL}/userSchedule/${req.user.id}`);
    const userInfo = req.session.userInfo;

    let totalHours = 0;
    const paidHours = Number(userSchedule.data[0].paid_hours);

    const scheduleDays = userSchedule.data[0].schedule_day;
    const startDate = new Date(userSchedule.data[0].start_date);
    const endDate = new Date(userSchedule.data[0].end_date);
    const payPeriods = getPayPeriods(startDate, endDate, scheduleDays);

    userSchedule.data[0].schedule_day.forEach(day => {
        if (day !== "Saturday" && day !== "Sunday") {
            totalHours += paidHours;
        }
    });

    const individaulSchedTotalHoursPromises = payPeriods.map(async (date, index) => {
        let start_date = payPeriods[index] ? payPeriods[index].toISOString().split('T')[0] : null;
        let end_date = payPeriods[index + 1] ? payPeriods[index + 1].toISOString().split('T')[0] : null;

        try {
            const totalTimeResponse = await axios.post(`${API_URL}/totalHours/${req.user.id}`, {
                startDate: start_date,
                endDate: end_date
            });

            let totalTime = totalTimeResponse.data.data[0].totalhours;
            return totalTime == null || totalTime == "" ? 0 : totalTime;   
        } catch (error) {
            console.error("Error fetching total hours:", error);

            return 0;
        }
    });

    try {
        const individaulSchedTotalHours = await Promise.all(individaulSchedTotalHoursPromises);

        // console.table(individaulSchedTotalHours);
        

        res.render("profile.ejs", {
            user: req.user,   
            individaulSchedTotalHours: individaulSchedTotalHours,         
            payPeriods: payPeriods,
            userSchedule: userSchedule.data,
            totalHours: totalHours,
            userData: data.data,
            userInfo: userInfo,
            messages: req.flash(""),
            title: "Pending Timesheets",
            individaulSchedTotalHours: individaulSchedTotalHours, // Pass the individual total hours to the template
        });
    } catch (error) {
        console.error("Error fetching individual total hours:", error);
        res.status(500).send("Internal Server Error");
    }
});



  return router;
};

export default createProfileRoutes;
