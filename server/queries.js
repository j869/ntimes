import { pool } from "./middleware.js";

//--------------------------------
//----  ts_timesheet_t
//-------------------------------
//#region ts_timesheet_t

// LOCATIONS FUNCTION HERE
const getLocationById = (req, res) => {
  console.log("qj1   ", req.params);
  // Extract username or person_id from request, assuming it's available in req.params
  const personID = req.params.id;

  // Check if a personID is present in the request

  // Construct the SQL query to fetch timesheets for the current year and specific user
  const query = `SELECT "location".* FROM "location" INNER JOIN ts_timesheet_t ON "location".location_id = ts_timesheet_t.location_id WHERE ts_timesheet_t."id" = $1`;

  pool.query(query, [personID], (error, result) => {
    if (error) {
      console.error("Error querying timesheets:", error);
      res.status(500).json({ error: "Error querying timesheets" });
      return;
    }

    res.status(200).json(result.rows);
  });
};

const getAllLocation = (req, res) => {
  console.log("qk1   ")
  const query = `SELECT "location".* FROM "location"`;

  pool.query(query, [], (error, result) => {
    if (error) {
      console.error("Error querying timesheets:", error);
      res.status(500).json({ error: "Error querying timesheets" });
      return;
    }

    res.status(200).json(result.rows);
  });
};

const editLocation = (req, res) => {
  console.log("ql1   ", req.body);
  const { locationId, locationName, roleId } = req.body;

  const query = `
    UPDATE "location"
    SET "location_name" = $1, "role_id" = $2
    WHERE "location_id" = $3
    RETURNING *`;

  pool.query(query, [locationName, roleId, locationId], (error, result) => {
    if (error) {
      console.error("Error updating location:", error);
      res.status(500).json({ error: "Error updating location" });
      return;
    }

    if (result.rows.length === 0) {
      res.status(404).json({ error: "Location not found" });
      return;
    }

    res.status(200).json(result.rows[0]);
  });
};

// Route for editing a location

// GetTimeSheets using the userID
const getTimesheetsById = (req, res) => {
  console.log("qo1   ", req.params);
  const userID = req.params.id;

  const query = `SELECT
	ts_timesheet_t.*, 
	"location".location_name
FROM
	"location"
	INNER JOIN
	ts_timesheet_t
	ON 
		"location".location_id = ts_timesheet_t.location_id
WHERE
	ts_timesheet_t."id" = $1`;

  pool.query(query, [userID], (error, result) => {
    if (error) {
      console.error("Error querying timesheets:", error);
      res.status(500).json({ error: "Error querying timesheets" });
      return;
    }

    res.status(200).json(result.rows);
  });
};

const getCurrentYearTimesheetsForUser = (req, res) => {
  // Extract username or person_id from request, assuming it's available in req.params
  console.log("cyt1   ", req.params);
  const personID = req.params.id;

  // Get the current year
  const currentYear = new Date().getFullYear();
  console.table({ currentYear });

  // Construct the SQL query to fetch timesheets for the current year and specific user
  const query = `
      SELECT dates.date AS work_date, ts_timesheet_t.*
      FROM generate_series(
          DATE '$1-01-01',
          DATE '$1-12-31',
          INTERVAL '1 day'
      ) AS dates(date)
      LEFT JOIN ts_timesheet_t ON ts_timesheet_t.work_date = dates.date AND ts_timesheet_t.person_id = $2
      WHERE EXTRACT(YEAR FROM dates.date) = $1
      ORDER BY dates.date, ts_timesheet_t.id;
  
  `;
  console.log(
    "cyt5   " +
      "SELECT * FROM ts_timesheet_t WHERE EXTRACT(YEAR FROM work_date) = " +
      currentYear +
      " AND person_id = " +
      personID +
      ");"
  );
  // Execute the query with currentYear and username as parameters
  pool.query(query, [currentYear, personID], (error, result) => {
    if (error) {
      console.error("Error querying timesheets:", error);
      res.status(500).json({ error: "Error querying timesheets" });
      return;
    }
    console.log("cyt91    ", result.rows[1]);
    console.log("cyt9   returning " + result.rows.length + " records ");
    res.status(200).json(result.rows);
  });
};

const createTimesheet = (req, res) => {
  console.log("ct1   ", req.body);
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

  pool.query(
    "DELETE FROM ts_timesheet_t WHERE work_date = $1",
    [work_date],
    (error, results) => {
      if (error) {
        throw error;
      }
      console.log("ct2    ", req.body);

      //Build SQL
      const query = `INSERT INTO ts_timesheet_t (person_id, username, work_date, time_start, time_finish, time_total, time_flexi, time_til, time_leave, time_overtime, time_comm_svs, t_comment, location_id, activity, notes, time_lunch, time_extra_break, fund_src, variance, variance_type, entry_date, duty_category, "status", on_duty, rwe_day) 
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25) 
    RETURNING id`;
      const values = [
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
        duty_category,
        status,
        on_duty,
        rwe_day,
      ];

      // Log the SQL
      console.log(`ct3      
    INSERT INTO ts_timesheet_t (person_id, username, work_date, time_start, time_finish, time_total, time_flexi, time_til, time_leave, time_overtime, time_comm_svs, t_comment, location_id, activity, notes, time_lunch, time_extra_break, fund_src, variance, variance_type, entry_date, duty_category, "status", on_duty, rwe_day) 
    VALUES (${person_id}, '${username}', '${work_date}', '${time_start}', '${time_finish}', '${time_total}', '${time_flexi}', '${time_til}', '${time_leave}', ${time_overtime}, '${time_comm_svs}', '${t_comment}', ${location_id}, '${activity}', '${notes}', '${time_lunch}', '${time_extra_break}', '${fund_src}', '${variance}', '${variance_type}', '${entry_date}', ${duty_category}, '${status}', ${on_duty}, ${rwe_day})
    RETURNING id`);

      // Execute the query
      pool.query(query, values, (error, result) => {
        if (error) {
          console.error("Error creating timesheet:", error);
          return res.status(500).json({ error: "Error creating timesheet" });
        }
        console.log("ct4");
        const timesheetId = result.rows[0].id;
        console.log("ct9 Successfully created timesheet with ID:", timesheetId);
        return res.status(201).json({
          id: timesheetId,
          message: `Added timesheet with ID ${timesheetId}`,
        });
      });
    }
  );
};

const deleteTimesheet = (req, res) => {
  console.log("qd1  ", req.params);
  const timesheetID = parseInt(req.params.id);

  try {
    pool.query(
      "DELETE FROM ts_timesheet_t WHERE id = $1",
      [timesheetID],
      (error, results) => {
        if (error) {
          throw error;
        }
        res.status(200).send(`Timesheet deleted with ID: ${timesheetID}`);
        console.log("qd5  ");
      }
    );
  } catch (error) {
    console.error("qd8   Error deleting timesheet:", error);
    throw error; // Throw error for handling in upper layers
  }
};

const updateTimesheetStatus = (req, res) => {
  console.log("qud1   " + req.params.id + " ", req.body);
  const timesheetID = parseInt(req.params.id);
  let newStatus = req.body.status;

  try {
    let oldStatus;
    pool.query(
      "SELECT status FROM ts_timesheet_t WHERE id = $1",
      [timesheetID],
      (error, result) => {
        if (error) {
          console.error("qud3   Error querying timesheets:", error);
        }
        console.log("ud4 ", result.rows);
        oldStatus = result.rows[0].status;
        if (newStatus == oldStatus) {
          newStatus = "entered"; // toggle status, if it is already approved
        }
        console.log("qud5   ", newStatus);

        pool.query(
          "UPDATE ts_timesheet_t SET status = $1 WHERE id = $2",
          [newStatus, timesheetID],
          (error, results) => {
            console.log("qud6    ");
            if (error) {
              console.log("qud7    ");
              throw error;
            }
            res
              .status(200)
              .send(`Set Timesheet(${timesheetID}) to status : ${newStatus}`);
            console.log("qud9  ");
          }
        );
      }
    );
  } catch (error) {
    console.error("qud8   Error deleting timesheet:", error);
    throw error; // Throw error for handling in upper layers
  }
};
//#endregion

//--------------------------------
//----  Other
//-------------------------------
const getRdoById = (req, res) => {
  console.log("rdo1    ", req.params.id);
  const id = parseInt(req.params.id);
  pool.query(
    "SELECT * FROM rdo_eligibility WHERE user_id = $1",
    [id],
    (error, results) => {
      if (error) {
        throw error;
      }
      res.status(200).json(results.rows);
    }
  );
};

//------------------------------------
//----  HR Profile (My Information)
//------------------------------------

const updateProfile = (req, res) => {
  console.log("up1   ", req.body);

  // Extract the data from the request
  const {
    advance_entry_days,
    at_agreement,
    at_balance,
    at_carried,
    at_limit_hours,
    at_max,
    at_open,
    auto_calculate_hours,
    current_period,
    default_location,
    fire_role,
    fund_source,
    last_update,
    location_id,
    normal_start,
    rdo_balance,
    rdo_carried,
    rdo_minimum,
    rdo_open,
    rostered_days,
    takes_rdos,
    timesheet_mode,
    timesheet_version,
    weekends_worked,
    workcentre,
    file_location
  } = req.body; // Assuming data is sent in the request body

  // Extract the ID from the request parameters
  const id = parseInt(req.params.id);

  // SQL query to update the users table
  const query = `
    UPDATE ts_user_t
    SET
      advance_entry_days = $1,
      at_agreement = $2,
      at_balance = $3,
      at_carried = $4,
      at_limit_hours = $5,
      at_max = $6,
      at_open = $7,
      auto_calculate_hours = $8,
      current_period = $9,
      default_location = $10,
      fire_role = $11,
      fund_source = $12,
      last_update = $13,
      location_id = $14,
      normal_start = $15,
      rdo_balance = $16,
      rdo_carried = $17,
      rdo_minimum = $18,
      rdo_open = $19,
      rostered_days = $20,
      takes_rdos = $21,
      timesheet_mode = $22,
      timesheet_version = $23,
      weekends_worked = $24,
      workcentre = $25,
      file_location = $26
    WHERE id = $27
  `;

  // Array containing the values to be inserted into the query
  const values = [
    advance_entry_days,
    at_agreement,
    at_balance,
    at_carried,
    at_limit_hours,
    at_max,
    at_open,
    auto_calculate_hours,
    current_period,
    default_location,
    fire_role,
    fund_source,
    last_update,
    location_id,
    normal_start,
    rdo_balance,
    rdo_carried,
    rdo_minimum,
    rdo_open,
    rostered_days,
    takes_rdos,
    timesheet_mode,
    timesheet_version,
    weekends_worked,
    workcentre,
    file_location,
    id
  ];

  // Execute the query using the database connection pool
  pool.query(query, values, (error, results) => {
    if (error) {
      // Log and handle any errors that occur during the query execution
      console.error('Error updating users table:', error);
      res.status(500).json({ error: 'Internal server error' }); // Send an error response
    } else {
      // Send a success response
      res.status(200).json({ message: 'Users table updated successfully' });
    }
  });
};



const getProfile = (req,res) => {
  console.log("qf1   ", req.params.id);
  const id = parseInt(req.params.id);
  pool.query("SELECT * FROM ts_user_t WHERE id = $1", [id], (error, results) => {
    if (error) {
      throw error;
    }
    console.log("up8    ");
    res.status(200).json(results.rows);
  });

}




//--------------------------------
//----  users
//-------------------------------
//#region users table

const getUsers = (req, res) => {
  console.log("qg1   ")
  pool.query(`SELECT *
              FROM users LEFT JOIN leave_balances ON users.id = leave_balances.person_id
              ORDER BY users.id ASC;`, (error, results) => {
    if (error) {
      console.log(error);
      throw error;
    }
    //console.log("SELECT * FROM users ORDER BY id ASC", results.rows)
    res.status(200).json(results.rows);
  });
  console.log("qg9   ")
};

const getUserById = (req, res) => {
  console.log("qh1   ", req.params.id);
  const id = parseInt(req.params.id);
  pool.query("SELECT * FROM users WHERE id = $1", [id], (error, results) => {
    if (error) {
      throw error;
    }
    res.status(200).json(results.rows);
  });
};

const getUserByUsername = (req, res) => {
  console.log("qi1   ", req.params.username);
  console.log(
    "h1 SELECT * FROM users WHERE username = '" + req.params.username + "';"
  );

  pool.query(
    "SELECT * FROM users WHERE username = '" + req.params.username + "';",
    (error, result) => {
      console.log("h2");
      if (error) {
        console.log("h3 db error");
        throw error;
      }
      if (result.rows.length === 0) {
        console.log("h4 No user found");
        //throw new Error('No user found');
        res.status(404).json({ messages: ["No user found"] });
        return;
      }
      if (result.rows.length > 1) {
        console.log("h5 several users with matching usernames");
        //test if result returns more than one row and throw an error
        throw new Error("Multiple users found");
        //the above will crash the server... instead use...
        res.status(500).json({ error: "Multiple users found" });
        return;
      }
      //success case. return data
      console.log("h9 user returned ok ");
      res.status(200).json(result.rows);
    }
  );
};

const updateUser = (req, res) => {
  console.log("uu1  " + req.params.id + "  ", req.body);
  const id = parseInt(req.params.id);
  const { username, email, role, verified_email, password } = req.body;
  const updateFields = [];
  const values = [];

  let paramIndex = 1; // Start indexing from 1

  if (username) {
    updateFields.push(`username = $${paramIndex}`);
    values.push(username);
    paramIndex++;
  }
  if (email) {
    updateFields.push(`email = $${paramIndex}`);
    values.push(email);
    paramIndex++;
  }
  if (password) {
    updateFields.push(`password = $${paramIndex}`);
    values.push(password);
    paramIndex++;
  }
  if (role) {
    updateFields.push(`role = $${paramIndex}`);
    values.push(role);
    paramIndex++;
  }
  if (verified_email !== undefined) {
    updateFields.push(`verified_email = $${paramIndex}`);
    values.push(verified_email);
    paramIndex++;
  }
  values.push(id); // Add id to the end of the values array

  const setClause = updateFields.join(", "); // Join update fields with comma
  const nonParamQuery = `UPDATE users SET ${setClause} WHERE id = ${id}`;
  console.log("Non-parametized SQL Query:", nonParamQuery);
  // Replace $1 through $5 with actual values
  const valuesString = values.join(", "); // Join values with comma
  const replacedQuery = nonParamQuery.replace(/\$\d+/g, (match) => {
    return valuesString.split(",")[parseInt(match.slice(1)) - 1];
  });
  console.log("Replaced SQL Query:", replacedQuery);

  console.log(
    `uu6     UPDATE users SET ${setClause} WHERE id = $${values.length}`
  );
  console.log("uu7     ", values);
  pool.query(
    `UPDATE users SET ${setClause} WHERE id = $${values.length}`, // Dynamic SET clause
    values,
    (error, results) => {
      if (error) {
        console.log("uu8   ");
        throw error;
      }
      res.status(200).send(`User(${id}) modified successfully`);
    }
  );
  console.log("uu9   ");
};

const createUser = (req, res) => {
  console.log("k1 ");
  const { username, email, password, role, verificationToken, verified_email } =
    req.body;
  console.log("k2", req.body);

  pool.query(
    "SELECT * FROM users WHERE email = $1",
    [email],
    (error, result) => {
      if (error) {
        console.log("k3 error");
        console.error("Error checking email:", error);
        return res.status(500).json({ messages: ["Internal Server Error"] });
      }
      if (result.rows.length !== 0) {
        console.error("k4     email already exists:", email);
        return res
          .status(400)
          .json({ messages: [`Email ${email} already exists`] });
      }

      console.log("k5");
      const query =
        "INSERT INTO users (username, email, password, role, verification_token, verified_email) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id";
      const values = [
        username,
        email,
        password,
        role,
        verificationToken,
        verified_email,
      ];
      pool.query(query, values, (error, result) => {
        if (error) {
          console.error("k6 Error inserting user:", error);
          return res
            .status(500)
            .json({ messages: ["Error adding user to the database"] });
        }
        console.log("k7");
        const userId = result.rows[0].id;
        console.log("k9 successfully created user");
        return res
          .status(201)
          .json({ id: userId, messages: [`Added user with ID: ${userId}`] });
      });
    }
  );
};

const verifyUserEmail = (req, res) => {
  console.log("vue1    ", req.params);
  const token = req.params.token;
  // const { name, email } = req.body

  console.log("vue2     ", token);
  pool.query(
    "SELECT id, verified_email FROM users WHERE verification_token = $1 ",
    [token],
    (error, results) => {
      if (error) {
        console.error("vue3   Error executing query:", error);
        return res.status(500).send("Error verifying token");
      }

      if (results.rows.length === 0) {
        console.log("vue5  No unverified token found");
        return res.status(404).send("Could not find an unverified token");
      }

      if (results.rows[0].verified_email === true) {
        console.log("vue4    email has already been verified");
        return res.status(409).send("Email has already been verified");
      }
      const userId = results.rows[0].id;

      // Now that we've confirmed the token is valid and the email is not yet verified,
      // proceed with updating the database to mark the email as verified
      pool.query(
        "UPDATE users SET verified_email = true WHERE id = $1",
        [userId],
        (error, updateResult) => {
          if (error) {
            console.error("Error executing update query:", error);
            return res
              .status(500)
              .send("Error updating user email verification status");
          }

          console.log(`vue9    User(${userId}) activated with verified email.`);
          res
            .status(200)
            .send(`User(${userId}) activated with verified email.`);
        }
      );
    }
  );
};

const deleteUser = (req, res) => {
  console.log("qde1   ", req.params);
  const id = parseInt(req.params.id);

  pool.query("DELETE FROM users WHERE id = $1", [id], (error, results) => {
    if (error) {
      throw error;
    }
    res.status(200).send(`User deleted with ID: ${id}`);
  });
}; //unused. no delete route as ov 20Mar

//#endregion
export {
  getUsers,
  getUserById,
  getUserByUsername,
  getProfile,
  updateProfile,
  getLocationById,
  getAllLocation,
  getCurrentYearTimesheetsForUser,
  createUser,
  updateUser,
  verifyUserEmail,
  deleteUser,
  createTimesheet,
  deleteTimesheet,
  updateTimesheetStatus,
  getRdoById,
  getTimesheetsById,
};
