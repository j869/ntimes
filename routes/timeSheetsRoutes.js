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
    
    const timesheetResult = await axios.get(`${API_URL}/timesheets/getTimesheetById/${ts_id}`)

    if(timesheetResult.data.length == 0 ) { 
      return res.redirect(req.get('referer') || '/time'); // If this is true then it should go back to the page before coming to this page
    } else { 
      
      console.log("Timesheet data", timesheetResult.data)

      if(timesheetResult.data[0].manager_id != req.user.id && timesheetResult.data[0].user_id != req.user.id) {
        return res.redirect(req.get('referer') || '/time');  // If this is true then it should go back to the page before coming to this page
      }
    }

    


    try {
      const userInfo = req.session.userInfo;
      const data = timesheetResult
      // console.log("GWPO KO");
      // console.log(data.data.timesheets);

      // if (data.data.timesheets == "") {
      //   res.redirect("/time");
      // }

      console.log("CT1", data.data[0])

      res.render("timesheet/individualTimeSheet.ejs", {
        title: "Timesheet",
        user: req.user,
        userInfo: userInfo,
        data: data.data[0],
        messages: req.flash("messages"),
      });
    } catch (error) {
      res.redirect("/time");
    }
  });

  router.get("/edit/:id", isAuthenticated, async (req, res) => {
    const ts_id = req.params.id;
    const work_date = req.query.work_date;


    
    const myManager = await axios.get(`${API_URL}/users/checkMyManger/${req.user.id}`)

    if(myManager.data.length == 0) { 
     return res.redirect("/profile?status=noManager") // Use return to stop further execution
    }



    const tsData = await axios.get(
      `${API_URL}/timesheets/getPendingTimesheetById/${ts_id}?work_date=${work_date}`
    );



    console.log("tsDaat", tsData.data);

    if (tsData.data.length == 0) {
      res.redirect("/time");
      res.end();
    } else {
      const userId = req.user.id; // Use req.user.id instead of req.query.userId
      const date = req.query.work_date;

      console.log("The DATE ", date);

      const locationResponse = await axios.get(`${API_URL}/location`);
      const userScheduleResponse = await axios.get(
        `${API_URL}/userSchedule/${req.user.id}`
      );

      console.log("workSchedule", userScheduleResponse.data);
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

            if (date == new Date(currentDate).toISOString().split("T")[0]) {
              allDateSchedules.push({
                date: new Date(currentDate).toISOString().split("T")[0],
                paidHour: paidHour,
                start_date: userScheduleResponse.data[0].start_date,
              end_date: userScheduleResponse.data[0].end_date,
              user_id: userScheduleResponse.data[0].user_id,
              schedule_id: userScheduleResponse.data[0].schedule_id,
              disable_til: userScheduleResponse.data[0].disable_til,
              disable_flexi: userScheduleResponse.data[0].disable_flexi,
              disable_rdo: userScheduleResponse.data[0].disable_rdo
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
        if (userSchedules.length == 0) {
          // console.log(true);
          res.redirect("/time?m=noSchedule");
        } else {
          console.log("selectedDate", selectedDate);
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

  // router.post("/edit/:id", isAuthenticated, async (req, res) => {
  //   const ts_id = req.params.id;
  //   const {
  //     work_date,
  //     time_start,
  //     time_finish,
  //     time_lunch,
  //     time_extra_break,
  //     location_id,
  //     fund_src,
  //     activity,
  //     comment,
  //     variance,
  //     notes,
  //   } = req.body;
    

  //   try {
  //     const result = await axios.put(`${API_URL}/timesheets/${ts_id}`, {
  //       work_date,
  //       time_start,
  //       time_finish,
  //       time_lunch,
  //       time_extra_break,
  //       location_id,
  //       fund_src,
  //       activity,
  //       comment,
  //       variance,
  //       notes,
  //     });

  //     console.log("Timesheet updated", result.data);
  //     req.flash("messages", "Timesheet updated successfully");
  //     res.redirect("/time");
  //   } catch (error) {
  //     console.error("Error updating timesheet:", error);
  //     req.flash(
  //       "messages",
  //       "An error occurred while updating the timesheet - the timesheet was not saved"
  //     );
  //     res.redirect("/time");
  //   }
  // });

  // router.post(
  //   "/edit/:id",
  //   isAuthenticated,
  //   [
  //     // Validate request body
  //     body("work_date")
  //       .optional()
  //       .isISO8601()
  //       .toDate()
  //       .withMessage("Timesheet not saved.  Invalid date format"),
  //     body("time_start")
  //       .optional()
  //       .custom(isValidTimeFormat)
  //       .withMessage(
  //         "Timesheet not saved.  Invalid time format for time_start (hh:mm)"
  //       ),
  //     body("time_finish")
  //       .optional()
  //       .custom(isValidTimeFormat)
  //       .withMessage(
  //         "Timesheet not saved.  Invalid time format for time_finish (hh:mm)"
  //       ),
  //     body("time_lunch")
  //       .optional()
  //       .isInt({ min: 0, max: 360 })
  //       .withMessage(
  //         "Timesheet not saved.  Please enter the number of minutes taken for lunch (eg. 90)"
  //       ),
  //     body("time_extra_break")
  //       .optional()
  //       .isInt({ min: 0, max: 360 })
  //       .withMessage(
  //         "Timesheet not saved.  Please enter the number of minutes taken for break (eg. 45)"
  //       ),
  //     //body('time_total').optional().custom(isValidTimeFormat).withMessage('Invalid time format for time_total (hh:mm)'),      //calculated field
  //     body("location_id")
  //       .optional()
  //       .isInt()
  //       .withMessage("Invalid entry for location_id"),
  //     body("fund_src")
  //       .optional()
  //       .isString()
  //       .withMessage("Invalid string format for fund_src"),
  //     body("activity")
  //       .optional()
  //       .isString()
  //       .isLength({ max: 30 })
  //       .withMessage("Activity must be less than 31 characters"),
  //     body("comment")
  //       .optional()
  //       .isString()
  //       .withMessage("Invalid string format for comment"),
  //     body("variance")
  //       .optional()
  //       .isString()
  //       .withMessage("Invalid string format for variance"),
  //     body("notes")
  //       .optional()
  //       .isString()
  //       .withMessage("Invalid string format for notes"),
  //     // body('flexi_accrued').optional().isNumeric().withMessage('Invalid numeric format for flexi_accrued'),
  //     // body('flexi_taken').optional().isNumeric().withMessage('Invalid numeric format for flexi_taken'),
  //     // body('til_accrued').optional().isNumeric().withMessage('Invalid numeric format for til_accrued'),
  //     // body('til_taken').optional().isNumeric().withMessage('Invalid numeric format for til_taken')
  //   ],
  //   async (req, res) => {
  //     console.log("n10 ", req.body);
  //     const errors = validationResult(req);
  //     if (!errors.isEmpty()) {
  //       req.flash(
  //         "messages",
  //         errors.array().map((error) => error.msg)
  //       );
  //       return res.redirect("/time");
  //     }
  
  //     try {
  //       const {
  //         work_date,
  //         time_start,
  //         time_finish,
  //         time_lunch,
  //         time_extra_break,
  //         time_total,
  //         location_id,
  //         fund_src,
  //         activity,
  //         comment,
  //         variance,
  //         notes,
  //         flexi_accrued,
  //         flexi_taken,
  //         til_accrued,
  //         til_taken,
  //       } = req.body;
  //       let { variance_type, time_leave, time_overtime } = req.body;

  //       const ts_id = req.params.id;
  
  //       console.log("n15   variance", variance);
  //       if (variance === "") {
  //         variance_type = ""; // timesheet has no variance, tidy up data set
  //         console.log("n16   variance_type", variance_type);
  //       }
  //       const currentDate = new Date();
  
  //       //set calculated fields
  //       let time_total_numeric = parseFloat(time_total);
  //       let flexi_accrued_numeric =
  //         flexi_accrued.trim() !== "" ? parseFloat(flexi_accrued) : 0;
  //       let flexi_taken_numeric =
  //         flexi_taken.trim() !== "" ? parseFloat(flexi_taken) : 0;
  //       let til_accrued_numeric =
  //         til_accrued.trim() !== "" ? parseFloat(til_accrued) : 0;
  //       let til_taken_numeric =
  //         til_taken.trim() !== "" ? parseFloat(til_taken) : 0;
  //       let time_leave_numeric =
  //         time_leave.trim() !== "" ? parseFloat(time_leave) : 0;
  //       let time_overtime_numeric =
  //         time_overtime.trim() !== "" ? parseFloat(time_overtime) : 0;
  //       const on_duty = 0; //activity.startsWith("Rest Day") ? 0 : 1;       //deleted 14May2024
  
  //       let time_flexi = null;
  //       let time_til = null;
  //       time_leave = null;
  //       time_overtime = null;
  //       if (variance_type === "flexi") {
  //         time_flexi = flexi_accrued_numeric - flexi_taken_numeric;
  //         console.log(
  //           "n21 " +
  //             time_flexi +
  //             " " +
  //             flexi_accrued_numeric +
  //             " " +
  //             flexi_taken_numeric
  //         );
  //       } else if (variance_type === "til") {
  //         time_til = til_accrued_numeric - til_taken_numeric;
  //         console.log("n22  ", time_til);
  //       } else if (variance_type === "leave") {
  //         time_leave = time_leave_numeric;
  //         console.log("n23  ", time_leave);
  //       } else if (variance_type === "overtime") {
  //         time_overtime = time_overtime_numeric;
  //         console.log("n24  ", time_overtime);
  //       } else {
  //         console.log("n25   mixed not working"); // mixed is not completed
  //       }
  
   
  //       const result = await axios.put(`${API_URL}/timesheets/edit/${ts_id}`, {
  //         person_id: req.user.id,
  //         username: req.user.username,
  //         work_date,
  //         time_start,
  //         time_finish,
  //         time_lunch,
  //         time_extra_break,
  //         time_total,
  //         location_id,
  //         fund_src,
  //         activity,
  //         t_comment: comment,
  //         entry_date: currentDate,
  //         variance,
  //         variance_type,
  //         notes,
  //         time_flexi,
  //         time_til,
  //         time_leave,
  //         time_overtime,
  //         on_duty, // 1 for work day, 0 if activity name begins with "Rest Day", ie. "Rest Day (Planned Burning)".
  //         duty_category: null,
  //         status: "entered",
  //         rwe_day: null, //
  //       });
  //       console.log("n30   res.status: ", result.status);
  
  //       const scanIssueResult = await axios.put(`${API_URL}/timesheet/scanIssues`, {
  //         person_id: req.user.id,
  //         username: req.user.username,
  //         work_date,
  //         time_start,
  //         time_finish,
  //         time_lunch,
  //         time_extra_break,
  //         time_total,
  //         location_id,
  //         fund_src,
  //         activity,
  //         t_comment: comment,
  //         entry_date: currentDate,
  //         variance,
  //         variance_type,
  //         notes,
  //         time_flexi,
  //         time_til,
  //         time_leave,
  //         time_overtime,
  //         on_duty, // 1 for work day, 0 if activity name begins with "Rest Day", ie. "Rest Day (Planned Burning)".
  //         duty_category: null,
  //         status: "entered",
  //         rwe_day: null, //
  //       });
  //       console.log("n90    New timesheet created");
  
  //       console.log("n30   res.status: ", scanIssueResult.status);
  
  
  //       req.flash("messages", "Thank you for entering your timesheet");
  //       return res.redirect("/time");
  //     } catch (error) {
  //       console.error("n80     Error creating timesheet:", error);
  //       req.flash(
  //         "messages",
  //         "An error occurred while creating the timesheet - the timesheet was not saved"
  //       );
  //       return res.redirect("/time");
  //     }
  //   }
  // );
  

  return router;
};



export default createTimesheetRoutes;
