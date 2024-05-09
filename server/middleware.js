import pg from "pg";
import env from "dotenv";

env.config();
const { Pool } = pg;
export const pool = new Pool({
  user: process.env.PG_USER || "me",
  host: process.env.PG_HOST || "localhost",
  database: process.env.PG_DATABASE || "api",
  password: process.env.PG_PASSWORD || "password",
  port: process.env.PG_PORT || 5432,
});

export const  queryDatabase = (query, params, res, successMessage) => {
  pool.query(query, params, (error, result) => {
    if (error) {
      console.error("Database error:", error);
      res.status(500).json(error);
      return;
    }

    res.status(200).json(result.rows);
  });
};

