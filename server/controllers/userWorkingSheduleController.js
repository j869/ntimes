import { queryDatabase, pool } from "../middleware.js";



const getUserScheduleById = (req, res) => {
    
    const userId = req.params.userID

    const query = `SELECT
	work_schedule.*
FROM
	work_schedule
	INNER JOIN
	ts_user_t
	ON 
		work_schedule."id" = ts_user_t.schedule_id
WHERE
	ts_user_t.user_id = $1
    
	`   

queryDatabase(query, [userId], res, "User fetched successfully");

}

const getTotalHourByDate = (req, res) => { 

    const { startDate, endDate } = req.body;
    const userId = req.params.userID

    


    console.log("START DATE " + startDate)

    const query = `
    SELECT
    ts_timesheet_t.person_id,
    ROUND(SUM(SPLIT_PART(ts_timesheet_t.time_total, ':', 1)::numeric + SPLIT_PART(ts_timesheet_t.time_total, ':', 2)::numeric / 60), 2) AS totalHours
FROM
    ts_timesheet_t
WHERE
    ts_timesheet_t.work_date BETWEEN $1 AND $2 AND person_id = $3
GROUP BY
    ts_timesheet_t.person_id;


    `
    pool.query(query, [startDate, endDate, 1], (error, results) => {
        if (error) {
            res.status(500).json({ error: error.message });
        } else {
            console.log(results.rows); // Logging the results before sending the response
            res.status(200).json({ message: "User fetched successfully", data: results.rows });
        }
    });
    
}


const userNextPay = async  (req, res) => { 
    const userId = req.params.userID
    const newScheduleId = 2

    const query = `SELECT
	work_schedule.*
FROM
	work_schedule
	INNER JOIN
	ts_user_t
	ON 
		work_schedule."id" = ts_user_t.schedule_id
WHERE
	ts_user_t.user_id = $1
	` 


    const userSchedule = await queryDatabase(query, [userId],  res, "User fetched successfully")
    userSchedule 
    


    
    const query2 = `
   
    
    UPDATE ts_users_t SET schedule_id = $1;
    

    `
}

export {
  
  getUserScheduleById,
  getTotalHourByDate
 

};
