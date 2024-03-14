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
            console.log("h3")
            throw error
        }
        if (result.rows.length === 0) {
          console.log("h4")
          //throw new Error('No user found');
          res.status(404).json({ message: 'No user found' });
          return;
        }
        if (result.rows.length > 1) {
          console.log("h5")
          //test if result returns more than one row and throw an error
          throw new Error('Multiple users found');
          //the above will crash the server... instead use...
          res.status(500).json({ error: 'Multiple users found' });
          return;
        }
        console.log("h6")
        res.status(200).json(result.rows);
    });
};


const createUser = (req, res) => {
  console.log("k1 ");
  const { username, email, password, role, verificationToken } = req.body;
  console.log("k2");

  pool.query('SELECT * FROM users WHERE email = $1', [email], (error, result) => {
      if (error) {
          console.log("k3");
          console.error('Error checking email:', error);
          return res.status(500).json({ message: 'Internal Server Error' });
      }
      if (result.rows.length !== 0) {
          console.error('k4     email already exists:', email);
          return res.status(400).json({ message: `Email ${email} already exists` });
      }

      console.log("k5");
      const query = 'INSERT INTO users (username, email, password, role, verification_token) VALUES ($1, $2, $3, $4, $5) RETURNING id';
      const values = [username, email, password, role, verificationToken];
      pool.query(query, values, (error, result) => {

          if (error) {
              console.log("k6");
              console.error('Error inserting user:', error);
              return res.status(500).json({ message: 'Error adding user to the database' });
          }
          console.log("k7");
          const userId = result.rows[0].id;
          console.log("k9");
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
    'UPDATE users SET verified_email = true WHERE verification_token = $1 AND verified_email IS NULL RETURNING id',
    [token],
    (error, results) => {
      if (error) {
        console.log("vue3");
        console.error("Error executing query:", error);
        return res.status(500).send('Error verifying token');
      }
      
      if (results.rows.length === 0) {
        console.log("vue4");
        console.log("No rows updated");
        return res.status(404).send('could not find an un-verified token');
      }
      const userId = results.rows[0].id; 
      console.log(`vue9      User(${userId}) activated with verified email.`);
      res.status(200).send(`User(${userId}) activated with verified email.`);
    }
  )
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
