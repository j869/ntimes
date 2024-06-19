import { queryDatabase, pool } from "../middleware.js";



const getUserScheduleById = (req, res) => {
    console.log("sc1");
    const userId = req.params.userID;


    const query = `SELECT
	work_schedule.*
FROM
	work_schedule
	INNER JOIN
	user_work_schedule
	ON 
		work_schedule."id" = user_work_schedule.schedule_id
WHERE
	user_work_schedule.user_id = $1
    
    
	`   

    

queryDatabase(query, [userId], res, "User fetched successfully");

}

const getTotalHourByDate = (req, res) => { 
    console.log("to1");
    const { startDate, endDate } = req.body;
    const userId = req.params.userID
    console.log("to2     ", startDate,  endDate, userId)

    // console.log("START DATE " + startDate)
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
    pool.query(query, [startDate, endDate, userId], (error, results) => {
        if (error) {
            res.status(500).json({ error: error.message });
        } else {
            console.log("to9       ", results.rows); // Logging the results before sending the response
            res.status(200).json({ message: "User fetched successfully", data: results.rows });
        }
    });
    
}


export {
  getUserScheduleById,
  getTotalHourByDate
};
