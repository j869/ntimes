import { queryDatabase, pool } from "../middleware.js";


const getAllIssues = (req, res) => { 

    const query = `
    SELECT
	issues.*, 
	ts_issue.ts_id
FROM
	ts_issue
	INNER JOIN
	ts_timesheet_t
	ON 
		ts_issue.ts_id = ts_timesheet_t."id"
	INNER JOIN
	issues
	ON 
		ts_issue.issue_code = issues.issue_code
    `

    queryDatabase(query, [], res, "Timesheet Issues Fetch Successfully!")

}

const scanIssues = async (req, res) => { 
	const {
		person_id,
		username,
		work_date,
		time_start,
		time_finish,
		time_total,
		time_flexi,
		time_til,
		time_leave,
		time_overtime,
		time_comm_svs,
		t_comment,
		location_id,
		activity,
		notes,
		time_lunch,
		time_extra_break,
		fund_src,
		variance,
		variance_type,
		entry_date,
		rwe_day,
		duty_category,
		status,
		on_duty,
	  } = req.body;

	  await pool.query(
		`SELECT
		ts_timesheet_t."id"
	FROM
		ts_timesheet_t
	WHERE
		ts_timesheet_t.person_id = $1
	 AND
		ts_timesheet_t.work_date  = $2`
	  , [person_id, work_date] , async (err , result) => {
		if (!err) {

			const ts_id = result.rows[0].id;

			// await console.log("THISISHSSIHIH ", ts_id)
			
			const totalHours = parseFloat(time_total.split(':')[0]) + parseFloat(time_total.split(':')[1]) / 60;
			// await console.log("total TIme ", totalHours)
			// console.log("variance: ", variance)
			
			
			const issueCode = {
				issue1: "issue1",
				issue2: "issue2", 
				issue3: "issue3", 
				issue4: "issue4",
				issue5: "issue5",
			  }


			//   DELETE THE ISSUES 
			pool.query(
				"DELETE FROM ts_issue WHERE ts_id = $1",
				[ts_id],
				(error, results) => {
				  if (error) {
					throw error;
				  }
			})
			//   FOR ISSUE 1
			  if(variance > 2) {
				scanIssueQueryHelper(
					`INSERT INTO ts_issue (ts_id, issue_code) VALUES ($1 , $2)`
					, [ts_id, issueCode.issue1], )
			  } 

			//   FOR ISSUE 2

			if(totalHours < 4) {

				scanIssueQueryHelper(
					`INSERT INTO ts_issue (ts_id, issue_code) VALUES ($1 , $2)`
					, [ts_id, issueCode.issue2] )
			}

			// FOR ISSUE 3
			if(totalHours > 11) {
				scanIssueQueryHelper(
					`INSERT INTO ts_issue (ts_id, issue_code) VALUES ($1 , $2)`
					, [ts_id, issueCode.issue3] )
			}

 			 // FOR ISSUE 4 and 5
			  // SCANNING AND COUNTING THE LATEST CONSECUTIVE DAYS
			  let consecutiveDaysCount = 0;
			  await pool.query(`SELECT work_date FROM ts_timesheet_t WHERE person_id = $1 ORDER BY work_date DESC`, [person_id], async (err, result) => {
				  if (!err && result) {
					  const workDates = result.rows.map(row => new Date(row.work_date));
					  // Iterate through workDates backwards
					  for (let i = 0; i < workDates.length - 1; i++) {
						  // Calculate the difference in milliseconds between the current and next work_date
						  const diffInMilliseconds = workDates[i] - workDates[i + 1];
						  
						  // Convert the difference to days
						  const diffInDays = Math.floor(diffInMilliseconds / (1000 * 60 * 60 * 24));
						  console.log("diffInDays", diffInDays);
			  
						  // Increment consecutiveDaysCount if the difference is exactly 1 day
						  if (diffInDays === 1) {
							  consecutiveDaysCount++;
						  } else {
							  consecutiveDaysCount++;
							  
							  // Corrected: Only increment consecutiveDaysCount if the difference is exactly 1 day
							  break;
						  }
					  }
			  
					  console.log("Consecutive days count:", consecutiveDaysCount);
  
					  // FOR ISSUE 4 and 5
					  if(consecutiveDaysCount > 10) {
						  scanIssueQueryHelper(
							  `INSERT INTO ts_issue (ts_id, issue_code) VALUES ($1 , $2)`
							  , [ts_id, issueCode.issue4] )
					  } else if(consecutiveDaysCount > 7) {
						  scanIssueQueryHelper(
							  `INSERT INTO ts_issue (ts_id, issue_code) VALUES ($1 , $2)`
							  , [ts_id, issueCode.issue5] )
					  }
  
					  
				  } else {
					  console.log("Scanning issue Error: ", err);
				  }
			  });

			
			
			
			
			


		} else { 
			console.log("scanning issue Error: ", error)
		}
	  })

	  res.end();
	   // End the response to prevent loading

	 
}

const scanIssueQueryHelper = (query, params) => {

  pool.query(query, params, (err)  => {
	if(err){
		console.log("scanning issue Error: ", err)
	}
  })
}

export {getAllIssues, scanIssues} 