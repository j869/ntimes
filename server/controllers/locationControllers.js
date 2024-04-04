import pg from "pg";
import env from "dotenv";
//#region middleware
env.config();
const { Pool } = pg;
export const pool = new Pool({
  //const pool = new Pool({
  user: process.env.PG_USER || "me",
  host: process.env.PG_HOST || "localhost",
  database: process.env.PG_DATABASE || "api",
  password: process.env.PG_PASSWORD || "password",
  port: process.env.PG_PORT || 5432,
});

// LOCATIONS FUNCTION HERE
const getLocationById = (req, res) => {
  // Extract username or person_id from request, assuming it's available in req.params
  const personID = req.params.id;

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

const deleteLocation = (req, res) => {
  const { locationId } = req.body;

  const query = `DELETE FROM Location WHERE location_id = $1`;

  pool.query(query, [locationId], (error, result) => {
    if (error) {
      res.status(500).json({ error: error });
    } else {
      res.status(200).json(result.rows);
    }
  });
};

const getAllLocation = (req, res) => {
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

const addLocation = (req, res) => {
  const { locationName, location_role, location_id } = req.body;

  const query = `
        INSERT INTO "location" ("location_name", "role_id", "location_id")
        VALUES ($1, $2, $3)`;

  pool.query(
    query,
    [locationName, location_role, location_id],
    (error, result) => {
      if (error) {
        console.error("Error adding location:", error);
        res.status(500).json({ error: "Error adding location" });
        return;
      }

      res.status(200).json({ success: true });
    }
  );
};

const editLocation = (req, res) => {
  const { locationName, location_role, location_id } = req.body;

  const locationId = req.params.id;

  const query = `
      UPDATE "location"
      SET "location_name" = $1, "role_id" = $2, "location_id" = $4
      WHERE "id" = $3`;

  pool.query(
    query,
    [locationName, location_role, locationId, location_id],
    (error, result) => {
      if (error) {
        console.error("Error updating location:", error);
        res.status(500).json({ error: "Error updating location" });
        return;
      }

      res.status(200).json({ success: true });
    }
  );
};

export {
  editLocation,
  getLocationById,
  getAllLocation,
  deleteLocation,
  addLocation,
};
