import { queryDatabase } from "../middleware.js";


  const getAllHolidays = (req, res) => {
    const query = `SELECT * FROM "public_holidays"`

    queryDatabase(query, [], res, "Public Holidays fetched Successfully")

  };

export { 
    getAllHolidays
}
  