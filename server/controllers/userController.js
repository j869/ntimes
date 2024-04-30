import { queryDatabase, pool } from "../middleware.js";



const getUserInfo= (req, res) => {
    
    const userId = req.params.userID

    const query = `SELECT
	users.email, 
	ts_user_t.*, 
	users."id"
FROM
	ts_user_t
	INNER JOIN
	users
	ON 
		ts_user_t.user_id = users."id"
WHERE
users."id" = $1`

queryDatabase(query, [userId], res, "User fetched successfully");



}

const isManager = async (req, res) => {
    try {
        const userId = req.params.userID;
        const query = `SELECT
            users.email, 
            ts_user_t.*, 
            users."id"
        FROM
            ts_user_t
            INNER JOIN
            users
            ON 
                ts_user_t.user_id = users."id"
        WHERE
            ts_user_t.role_id = 2 AND users."id" = $1`;

        // const result = await pool.query(query, [userId]);
		const result = await queryDatabase(query, [userId], res, "fetched Successfully")

        return result.rows.length > 0 ? true : false;
    } catch (error) {
        console.error("Error in isManager function:", error);
        return false;
    }
}





export {
  
  getUserInfo,
  isManager,

};
