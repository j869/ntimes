import { queryDatabase } from "../middleware.js";

const getLocationById = (req, res) => {
  const personID = req.params.id;

  const query = `SELECT "location".* FROM "location" INNER JOIN ts_timesheet_t ON "location".location_id = ts_timesheet_t.location_id WHERE ts_timesheet_t."id" = $1`;

  queryDatabase(query, [personID], res, "Location fetched successfully");
};

const deleteLocation = (req, res) => {
  const { locationId } = req.body;

  const query = `DELETE FROM Location WHERE id = $1`;

  queryDatabase(query, [locationId], res, "Location deleted successfully");
};

const getAllLocation = (req, res) => {
  const query = `SELECT "location".* FROM "location" ORDER BY "location".location_name ASC`;

  queryDatabase(query, [], res, "All locations fetched successfully");
};

const addLocation = (req, res) => {
  const { locationName, location_role, location_id } = req.body;

  const query = `INSERT INTO "location" ("location_name", "role_id", "location_id") VALUES ($1, $2, $3)`;

  queryDatabase(
    query,
    [locationName, location_role, location_id],
    res,
    "Location added successfully"
  );
};

const editLocation = (req, res) => {
  const { locationName, location_role, location_id } = req.body;
  const locationId = req.params.id;

  const query = `UPDATE "location" SET "location_name" = $1, "role_id" = $2, "location_id" = $4 WHERE "id" = $3`;

  queryDatabase(
    query,
    [locationName, location_role, locationId, location_id],
    res,
    "Location updated successfully"
  );
};

export {
  editLocation,
  getLocationById,
  getAllLocation,
  deleteLocation,
  addLocation,
};
