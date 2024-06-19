import { Router } from "express";
import axios from "axios";

const createTimesheetRoutes = (isAuthenticated) => {
  console.log("tsr1     ");
  const router = Router();
  const API_URL = process.env.API_URL;

  router.post("/flexiDayOff", isAuthenticated, async (req, res) => {
    const userID = req.user.id;
    const dayOffOption = req.body.dayOffOption;
    const workDate = req.body.workDate;
    const flexiInput = req.body.flexiInput;
    const tilInput = req.body.tilInput;

    // console.log("this is the most gwapo: " + dayOffOption)

    try {
      await axios.post(`${API_URL}/flexiDayOff/${userID}`, {
        dayOffOption,
        workDate,
        flexiInput,
        tilInput,
      });
      res.redirect("/time");
    } catch (error) {
      res.status(500).json({ error: error });
    }
  });

  router.get("/:id", isAuthenticated, async (req, res) => {
    const ts_id = req.params.id;

    try {
      const data = await axios.post(
        `${API_URL}/timesheets/getTimesheetById/${ts_id}`,
        { userID: req.user.id }
      );
      console.log("GWPO KO");
      console.log(data.data.timesheets);

      if (data.data.timesheets == "") {
        res.redirect("/time");
      }

      res.render("timesheet/individualTimeSheet.ejs", {
        title: "Timesheet",
        user: req.user,
        data: data.data.timesheets[0],
        messages: req.flash("messages"),
      });
    } catch (error) {
      res.redirect("/time");
    }
  });

  router.get("/edit/:id", isAuthenticated, async (req, res) => {
    const ts_id = req.params.id;
    const work_date = req.query.work_date

    
    const tsData = await axios.get(
      `${API_URL}/timesheets/getPendingTimesheetById/${ts_id}?work_date=${work_date}`
    );

    console.log("tsDaat", tsData.data);

    if(tsData.data.length == 0) {
      res.redirect("/time");
      res.end();



    }else {

      const userId = req.user.id; // Use req.user.id instead of req.query.userId
      const date = req.query.work_date;

      console.log("The DATE ", date)
    
  
      const locationResponse = await axios.get(`${API_URL}/location`);
      const userScheduleResponse = await axios.get(
        `${API_URL}/userSchedule/${req.user.id}`
      );

      console.log("workSchedule" , userScheduleResponse.data);
      let userSchedules = [];
  
      if (!userScheduleResponse.data.length == 0) {
        const scheduleDays = userScheduleResponse.data[0].schedule_day;
        const paidHours = userScheduleResponse.data[0].paid_hours;
        const startDate = new Date(userScheduleResponse.data[0].start_date);
        const endDate = new Date(userScheduleResponse.data[0].end_date);
  
        userSchedules = getPayPeriods(
          startDate,
          endDate,
          scheduleDays,
          paidHours
        );
        console.log("user schedules: ", userSchedules);
      }
  
      function getDayOfWeekName(dayOfWeek) {
        // console.log("rpy1     ");
        const days = [
          "Sunday",
          "Monday",
          "Tuesday",
          "Wednesday",
          "Thursday",
          "Friday",
          "Saturday",
        ];
        return days[dayOfWeek];
      }
  
      function getPayPeriods(startDate, endDate, scheduleDays, paidHours) {
        console.log("rpr1     ");
        const allDateSchedules = [];
  
        let currentDate = new Date(startDate);
        // Populate allDateSchedules with all scheduled days within the date range
        let i = 0;
        let paidHour = 0;
        while (currentDate <= endDate) {
          const dayOfWeek = currentDate.getDay();
          if (scheduleDays.includes(getDayOfWeekName(dayOfWeek))) {
            if (i <= paidHours.length - 1) {
              paidHour = paidHours[i];
  
              if (i == paidHours.length - 1) {
                i = 0;
              } else {
                i += 1;
              }
            }
  
            // console.log("date", date )
            // console.log("Currentdate", new Date(currentDate) )
  
    
            if (date == new Date(currentDate).toISOString().split("T")[0]) {
              allDateSchedules.push({
                date:  new Date(currentDate).toISOString().split("T")[0], 
                paidHour: paidHour
              });
            }

               console.log("PaidHour", paidHour);
         
          }
          currentDate.setDate(currentDate.getDate() + 1);
        }
  
        return allDateSchedules;
      }
  
      const location = locationResponse.data; // Extract the data from the Axios response
  
      const selectedDate = date;
  
  
  
      if (false) {
       
      } else {
        // console.log("userSchedule", userSchedules)
        if (userSchedules.length == 0) {
          console.log(true);
          res.redirect("/time?m=noSchedule");
        } else {

          console.log("selectedDate",selectedDate);
          res.render("timesheet/editTimesheet.ejs", {
            tsData: tsData.data[0],
            forDate: date,
            user: req.user,
            userWorkSchedule: userSchedules,
            selectedDate: selectedDate,
            location: location, // Pass the extracted location data
            title: "Enter Timesheet",
            messages: req.flash("messages"),
            
          });
        }
      }
    }


    
  });

  return router;
};

export default createTimesheetRoutes;
