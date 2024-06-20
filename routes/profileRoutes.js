import { Router } from "express";
import axios, { all } from "axios";
import bcrypt from "bcrypt";

const createProfileRoutes = (isAuthenticated) => {
  const router = Router();
  const API_URL = process.env.API_URL;

  router.post("/update", isAuthenticated,async (req, res) => {
    const { firstName, lastName, email, username, newPassword, confirmPassword, managerID } = req.body;
    const userId = req.user.id;

    

    if (newPassword !== confirmPassword) {
      return res.status(400).json({ error: 'New password and confirm password must match' });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);

    try {
      await axios.post(`${API_URL}/users/update`, { firstName, lastName, email, username, password: hashedPassword, userId, managerID });
      res.redirect("/profile");
    } catch (error) {
      console.error("Error updating user profile:", error);
      res.status(500).send("Internal Server Error");
    }
  })

  
  router.get("/edit", isAuthenticated, async (req, res) => {
    console.log("rpe1     ")
    const data = await axios.get(`${API_URL}/users/userInfo/${req.user.id}`);
    const userSchedule = await axios.get(`${API_URL}/userSchedule/${req.user.id}`);
    const userInfo = req.session.userInfo;
    const password = 123

 
    // console.log(password)
            res.render("editProfile.ejs", {
                user: req.user,
                password: password,         
                userSchedule: userSchedule.data,
                userData: data.data[0],
                userInfo: userInfo,
                messages: req.flash(""),
                title: "Edit Profile",

                 // Pass the individual total hours to the template
            });

})

  router.get("/check", isAuthenticated, (req, res) => {
            console.log("rpg1     ")
            res.redirect("/profile")
            
  })
  router.post("/check", isAuthenticated, async (req, res) => {
    console.log("rpp1     ")
    const email = req.body.email
    const password = req.body.password 
    const checkUser = await checkUserExists(email, password)
    // console.log("THIS IS THE CHECK " + checkUser)


    const data = await axios.get(`${API_URL}/users/userInfo/${req.user.id}`);
    const userSchedule = await axios.get(`${API_URL}/userSchedule/${req.user.id}`);
    const userInfo = req.session.userInfo;
  

    const myManager = await axios.get(`${API_URL}/users/getMyManager/${req.user.id}`);  
    const managers = await axios.get(`${API_URL}/users/getManager/${req.user.id}`);  

    // console.log("Managers", managers.data)
//    console.log("MyManager" , myManager)

    try {
        if(checkUser == true) { 

            res.render("editProfile.ejs", {
                user: req.user,   
                myManager: myManager.data[0],
                managers: managers.data,
                userSchedule: userSchedule.data,
                userData: data.data[0],
                userInfo: userInfo,
                messages: req.flash(""),
                title: "Edit Profile",

                 // Pass the individual total hours to the template
            });
        } else { 
           
            res.redirect("/profile?status=404")
        }
        

    } catch (error) {
        console.error("Error fetching individual total hours:", error);
        res.status(500).send("Internal Server Error");
    }
  })

  const checkUserExists = async (email, password) => {
    console.log("rpu1     ")
      // Correctly format the data as an object instead of an array
      const response = await axios.post(`${API_URL}/users/check`, { email, password });
    //     console.log("LAKsdja;lksjlkdja;lskdja;klsdjas;lkj")
    //   console.log(response.data.exists)
    
      if (response.data.exists == true ) {
        return true; // The server should return if the password matches
      } else {
        return false; // No user found with the given email
      }
   
  };

  function getPayPeriods(startDate, endDate, scheduleDays) {
    console.log("rpr1     ")
    const allDateSchedules = [];
    const payPeriods = [];

    // Limit the date range to the current year
    const currentYear = new Date().getFullYear();
    const startOfYear = new Date(currentYear, 0, 1);
    const endOfYear = new Date(currentYear, 11, 31);

    // Adjust the start date if it's before the current year
    if (startDate < startOfYear) {
        startDate = startOfYear;
    }

    // Adjust the end date if it's after the current year
    if (endDate > endOfYear) {
        endDate = endOfYear;
    }

    let currentDate = new Date(startDate);
    // Populate allDateSchedules with all scheduled days within the current year date range
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
    while (i > 1) {
        if (i > scheduleDays.length - 1) {
            payPeriods.push(allDateSchedules[payDayIndex]);
            payDayIndex += scheduleDays.length;
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
    // console.log("rpy1     ")
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[dayOfWeek];
}



router.get("/", isAuthenticated, async (req, res) => {
    console.log("rph1     ")
    const data = await axios.get(`${API_URL}/users/userInfo/${req.user.id}`);
    const userScheduleResponse = await axios.get(`${API_URL}/userSchedule/${req.user.id}`);
    const myManager = await axios.get(`${API_URL}/users/getMyManager/${req.user.id}`);

    const userInfo = req.session.userInfo;

    console.log("my manager", myManager.data)

    // Check if userScheduleResponse.data is empty
    if (!userScheduleResponse.data || userScheduleResponse.data.length === 0) {
        res.render("profile.ejs", {
            status: req.query.status,
            user: req.user,
            payPeriods: [],
            userSchedule: [],
            totalHours: 0,
            myManager: [],
            userData: data.data[0],
            myManager: myManager.data[0],
            userInfo: userInfo,
            messages: req.flash(""),
            title: "Pending Timesheets",
        });

        return;
    }

    let totalHours = 0;
    const paidHours = Number(userScheduleResponse.data[0].paid_hours);

    const scheduleDays = userScheduleResponse.data[0].schedule_day;
    const startDate = new Date(userScheduleResponse.data[0].start_date);
    const endDate = new Date(userScheduleResponse.data[0].end_date);
    const payPeriods = getPayPeriods(startDate, endDate, scheduleDays);

    console.log("userChedule",userScheduleResponse.data[0])

    userScheduleResponse.data[0].paid_hours.forEach(paidHour=> {
       totalHours += parseFloat(paidHour)
    });
    let initiateStartDate = false;

    const individaulSchedTotalHoursPromises = payPeriods.map(async (date, index) => {
        
        let start_date;
        let end_date;

        if (initiateStartDate == false) {

            start_date = startDate ? startDate.toISOString().split('T')[0] : null;
            end_date = payPeriods[index] ? payPeriods[index].toISOString().split('T')[0] : null;
            initiateStartDate = true

        } else {
            start_date = payPeriods[index - 1] ? payPeriods[index -1].toISOString().split('T')[0] : null;
            end_date = payPeriods[index ] ? payPeriods[index ].toISOString().split('T')[0] : null;
        }
        

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
       
        res.render("profile.ejs", {
            user: req.user,
            status: req.query.status,
            payPeriods: payPeriods,
            userSchedule: userScheduleResponse.data,
            totalHours: totalHours,
            userData: data.data[0],
            myManager: myManager.data[0],
            userInfo: userInfo,
            messages: req.flash(""),
            title: "Pending Timesheets",
            individaulSchedTotalHours: individaulSchedTotalHours,
        });
    } catch (error) {
        console.error("Error fetching individual total hours:", error);
        res.status(500).send("Internal Server Error");
    }
});




  return router;
};

export default createProfileRoutes;
