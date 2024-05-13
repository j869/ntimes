import { queryDatabase } from "../middleware.js"; 
import { pool } from "../middleware.js";


const getTFR = (req, res) => { 
    
    const userID = req.params.userID;
    const query = `SELECT
    COUNT(id) AS totalrdo,
    (SELECT SUM(time_til) FROM ts_timesheet_t WHERE person_id = $1) AS totalTil,
    (SELECT SUM(time_flexi) FROM ts_timesheet_t WHERE person_id = $1) AS totalFlexi
FROM
    ts_timesheet_t
WHERE
    EXTRACT(DOW FROM work_date) IN (0, 6) AND person_id = $1 AND activity != 'RDO Used' ;
`

    queryDatabase(query,[userID], res, "TFR fetched Successfully!")

}


const updateTimesheet = async (userID, hoursType, remainingHours, dayOffOption, flexiInput, tilInput) => {
    let query;
    let flexiQuery;
    let tilQuery;

    if (dayOffOption === "rdo") {
        // Deduct RDO from weekend timesheets
        query = `SELECT id, activity, EXTRACT(DOW FROM work_date) AS dayOfWeek FROM ts_timesheet_t WHERE person_id = $1 AND EXTRACT(DOW FROM work_date) IN (0, 6) ORDER BY id ASC`;
    } else if (dayOffOption == "mix") {

       

        query = `SELECT SUM(time_til) AS totalTil, SUM(time_flexi) AS totalFlexi FROM ts_timesheet_t WHERE person_id = $1`;

        
        try {
            flexiQuery = await pool.query(`SELECT id, time_flexi FROM ts_timesheet_t WHERE time_flexi > 0 AND person_id = $1`, [userID]);
            tilQuery = await pool.query(`SELECT id, time_til FROM ts_timesheet_t WHERE time_til > 0 AND person_id = $1`, [userID]);
        } catch (error) {
            console.error("Error fetching flexi and til timesheets:", error);
            return remainingHours;
        }
    } else {
        query = `SELECT id, ${hoursType} FROM ts_timesheet_t WHERE person_id = $1 AND ${hoursType} > 0 ORDER BY id ASC`;
    }
    

    const result = await pool.query(query, [userID]);
    const rows = result.rows;
    // console.log(rows[0])
try{
    for (let i = 0; i < rows.length; i++) {
        let id = rows[i].id;
        let activity = rows[i].activity;

        if (dayOffOption == "rdo" && activity != "RDO Used") {
            // Deduct RDO day and mark the timesheet as "RDO Used"
            await pool.query(`UPDATE ts_timesheet_t SET activity = 'RDO Used' WHERE id = $1`, [id]);
            remainingHours = 0;
            
        } else if (dayOffOption == "mix") {
            const totalFlexi = rows[0].totalflexi;
            const totalTil = rows[0].totaltil;

            const flexi = flexiQuery.rows;
            const til = tilQuery.rows;

            // console.log(flexi);
            // console.log(til);
            // console.log(totalFlexi)
            // console.log(totalTil)

            if (totalFlexi < 4) {
                remainingHours = remainingHours - totalFlexi;

                for (let i = 0; i < flexi.length; i++) {
                    await pool.query(`UPDATE ts_timesheet_t SET time_flexi = $1 WHERE id = $2`, [0, flexi[i].id]);
                    
                }
            
                for (let i = 0; i < til.length; i++) {
                    await pool.query(`UPDATE ts_timesheet_t SET time_til = $1 WHERE id = $2`, 
                    [remainingHours < til[i].time_til ? til[i].time_til - remainingHours : remainingHours - til[i].time_til , remainingHours - til[i].time_til, til[i].id]);

                    remainingHours = remainingHours < til[i].time_til ? 0 : remainingHours - til[i].time_til;

                    if (remainingHours == 0) {
                        break;
                    }
                }
            } else if (totalTil < 4) {
                remainingHours = remainingHours - totalTil;

                for (let i = 0; i < til.length; i++) {
                    await pool.query(`UPDATE ts_timesheet_t SET time_til = $1 WHERE id = $2`, [0, til[i].id]);
                }

                for (let i = 0; i < flexi.length; i++) {
                    await pool.query(`UPDATE ts_timesheet_t SET time_flexi = $1 WHERE id = $2`, 
                    [ remainingHours < flexi[i].time_flexi ? flexi[i].time_flexi - remainingHours : remainingHours - flexi[i].time_flexi, flexi[i].id]);
                    remainingHours = remainingHours < flexi[i].time_flexi ? 0 : remainingHours - flexi[i].time_flexi;

                    if (remainingHours == 0) {
                        break;
                    }
                }
            } else {
               
                for (let i = 0; i < til.length; i++) {
                    let remainingTil = 4;
                  
                    if(til[i].time_til < remainingTil) {
                        await pool.query(`UPDATE ts_timesheet_t SET time_til = $1 WHERE id = $2`, [0, til[i].id]);
                        remainingTil = remainingTil - til[i].time_til
                    } else { 
                        await pool.query(`UPDATE ts_timesheet_t SET time_til = $1 WHERE id = $2`, [til[i].time_til - remainingTil, til[i].id]);
                        remainingTil = 0
                    }

                    if(remainingTil == 0) {
                        
                        break
                    }

                }

                for (let i = 0; i < flexi.length; i++) {

                    let remainingFlexi = 4;
                  
                    if(flexi[i].time_flexi < remainingFlexi) {
                        await pool.query(`UPDATE ts_timesheet_t SET time_flexi = $1 WHERE id = $2`, [0, flexi[i].id]);
                        remainingFlexi = remainingFlexi - flexi[i].time_flexi
                    } else { 
                        await pool.query(`UPDATE ts_timesheet_t SET time_flexi = $1 WHERE id = $2`, [flexi[i].time_flexi - remainingFlexi, flexi[i].id]);
                        remainingFlexi = 0
                    }

                    if(remainingFlexi == 0) {
                        
                        break
                    }
                   
                }
                
                remainingHours = 0

                if (remainingHours == 0) {
                    break;
                }

            }
        } else if (hoursType) {
            let time = rows[i][hoursType];
            let updatedTime = 0;

            if (time <= remainingHours) {
                updatedTime = 0;
                remainingHours -= time;
            } else {
                updatedTime = time - remainingHours;
                remainingHours = 0;
            }

            await pool.query(`UPDATE ts_timesheet_t SET ${hoursType} = $1 WHERE id = $2`, [updatedTime, id]);
        }

        if (remainingHours === 0) {
            break;
        }
    }
}catch (error) {
    console.error("Error updating timesheet:", error);
    throw { message: error.message }; // Throw the error message as JSON
}

    return remainingHours;
};



const postDayOff = async (req, res) => {
    const userID = req.params.userID;
    const dayOffOption = req.body.dayOffOption;
    const workDate = req.body.workDate;
    const flexiInput = req.body.flexiInput
    const tilInput = req.body.tilInput

    console.log("USERid: " + userID)
    console.log("OffOption :" + dayOffOption)
    console.log("workDate: " + workDate)

    let workActivity;
    let remainingHours = 8;

    if (dayOffOption === "flexi") {
        workActivity = "Day Off Using Flexi Time";
        remainingHours = await updateTimesheet(userID, "time_flexi", remainingHours, dayOffOption);
    } else if (dayOffOption === "til") {
        workActivity = "Day Off Using TIL Time";
        remainingHours = await updateTimesheet(userID, "time_til", remainingHours, dayOffOption);
    } else if (dayOffOption === "rdo") {
        workActivity = "Day Off Using RDO";
        remainingHours = await updateTimesheet(userID, null, remainingHours, dayOffOption);
    }  else if (dayOffOption === "mix") {
        workActivity = "Day Off Using Mix Time";
        remainingHours = await updateTimesheet(userID, null, remainingHours, dayOffOption, flexiInput, tilInput );
        
    }

    if (remainingHours === 0) {
        let timesheetQuery = "INSERT INTO ts_timesheet_t (work_date, activity, person_id) VALUES ($1, $2, $3)";

        try {
            await pool.query(timesheetQuery, [workDate, workActivity, userID]);
            res.status(200).json({ message: "Updates Successfully" });
        } catch (error) {
            console.error("Database error:", error);
            return res.status(500).json({ message: error.message });
        }
    } else {
        res.status(400).json({ message: "Not enough balance for day off" });
    }
};




export {getTFR , postDayOff}