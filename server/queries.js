//#region middleware

//import { Pool } from 'pg';
import pg from "pg";
import env from "dotenv";
env.config();

const { Pool } = pg;
export const pool = new Pool({         //const pool = new Pool({
  user: process.env.PG_USER || 'me',
  host: process.env.PG_HOST || 'localhost',
  database: process.env.PG_DATABASE || 'api',
  password: process.env.PG_PASSWORD || 'password',
  port: process.env.PG_PORT || 5432,
})

//#endregion

const getUsers = (request, response) => {
    pool.query('SELECT * FROM users ORDER BY id ASC', (error, results) => {
        if (error) {
          console.log(error);
        throw error
        }
        //console.log("SELECT * FROM users ORDER BY id ASC", results.rows)
        response.status(200).json(results.rows)
    })
}

const getUserById = (request, response) => {
    const id = parseInt(request.params.id)
    pool.query('SELECT * FROM users WHERE id = $1', [id], (error, results) => {
        if (error) {
        throw error
        }
        response.status(200).json(results.rows)
})
}
    
const getUserByUsername = (req, res) => {
    console.log("h1     SELECT * FROM users WHERE username = '"+ req.params.username + "';");
    pool.query("SELECT * FROM users WHERE username = '"+ req.params.username + "';", (error, result) => {
        console.log("h2")
        if (error) {
            console.log("h3 db error")
            throw error
        }
        if (result.rows.length === 0) {
          console.log("h4 No user found")
          //throw new Error('No user found');
          res.status(404).json({ message: 'No user found' });
          return;
        }
        if (result.rows.length > 1) {
          console.log("h5 several users with matching usernames")
          //test if result returns more than one row and throw an error
          throw new Error('Multiple users found');
          //the above will crash the server... instead use...
          res.status(500).json({ error: 'Multiple users found' });
          return;
        }
        //success case. return data
        console.log("h6 success")
        res.status(200).json(result.rows);
    });
};


const createUser = (req, res) => {
  console.log("k1 ");
  const { username, email, password, role, verificationToken, verified_email } = req.body;
  console.log("k2", req.body);

  pool.query('SELECT * FROM users WHERE email = $1', [email], (error, result) => {
      if (error) {
          console.log("k3 error");
          console.error('Error checking email:', error);
          return res.status(500).json({ message: 'Internal Server Error' });
      }
      if (result.rows.length !== 0) {
          console.error('k4     email already exists:', email);
          return res.status(400).json({ message: `Email ${email} already exists` });
      }

      console.log("k5");
      const query = 'INSERT INTO users (username, email, password, role, verification_token, verified_email) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id';
      const values = [username, email, password, role, verificationToken, verified_email];
      pool.query(query, values, (error, result) => {

          if (error) {
              console.error('k6 Error inserting user:', error);
              return res.status(500).json({ message: 'Error adding user to the database' });
          }
          console.log("k7");
          const userId = result.rows[0].id;
          console.log("k9 success");
          return res.status(201).json({ id: userId, message: `Added user with ID: ${userId}` });
      });
  });
};


const updateUser = (request, response) => {
  const id = parseInt(request.params.id);
  const { username, email, role, verified_email, password } = request.body;
  const updateFields = [];
  const values = [];

  if (username) {
      updateFields.push('username = $1');
      values.push(username);
  }
  if (email) {
      updateFields.push('email = $2');
      values.push(email);
  }
  if (password) {
    updateFields.push('password = $3');
    values.push(password);
  }
    if (role) {
      updateFields.push('role = $4');
      values.push(role);
  }
  if (verified_email !== undefined) {
      updateFields.push('verified_email = $5');
      values.push(verified_email);
  }

  values.push(id); // Add id to the end of the values array

  const setClause = updateFields.join(', '); // Join update fields with comma
  console.log(`uu6     UPDATE users SET ${setClause} WHERE id = $${values.length}`);
  console.log("uu7     ", values);
  pool.query(
      `UPDATE users SET ${setClause} WHERE id = $${values.length}`, // Dynamic SET clause
      values,
      (error, results) => {
          if (error) {
              console.log("uu8   ")
              throw error;
          }
          response.status(200).send(`User(${id}) modified successfully`);
      }
  );
  console.log("uu9   ")
};



const verifyUserEmail = (req, res) => {
  console.log("vue1    ", req.params)
  const token = req.params.token
  // const { name, email } = request.body

  console.log("vue2     ", token)
  pool.query(
    'SELECT id, verified_email FROM users WHERE verification_token = $1 ',
    [token],
    (error, results) => {
      if (error) {
        console.error("vue3   Error executing query:", error);
        return res.status(500).send('Error verifying token');
      }
      if (results.rows[0].verified_email === true) {
        console.log("vue4    email has already been verified");
        return res.status(409).send('Email has already been verified');
      }

      if (results.rows.length === 0) {
        console.log("vue5  No unverified token found");
        return res.status(404).send('Could not find an unverified token');
      }

      const userId = results.rows[0].id;

      // Now that we've confirmed the token is valid and the email is not yet verified,
      // proceed with updating the database to mark the email as verified
      pool.query(
        'UPDATE users SET verified_email = true WHERE id = $1',
        [userId],
        (error, updateResult) => {
          if (error) {
            console.error("Error executing update query:", error);
            return res.status(500).send('Error updating user email verification status');
          }

          console.log(`vue9    User(${userId}) activated with verified email.`);
          res.status(200).send(`User(${userId}) activated with verified email.`);
        }
      );
    }
  );
}



const deleteUser = (request, response) => {
    const id = parseInt(request.params.id)
  
    pool.query('DELETE FROM users WHERE id = $1', [id], (error, results) => {
      if (error) {
        throw error
      }
      response.status(200).send(`User deleted with ID: ${id}`)
    })
}




export {
  getUsers,
  getUserById,
  getUserByUsername,
  createUser,
  updateUser,
  verifyUserEmail, 
  deleteUser,
};
