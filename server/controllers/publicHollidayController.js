import { queryDatabase } from "../middleware.js";


  const getAllHolidays = (req, res) => {
    console.log("ph1");
    const query = `SELECT * FROM "public_holidays"`

    queryDatabase(query, [], res, "Public Holidays fetched Successfully")

  };

export { 
    getAllHolidays
}
  