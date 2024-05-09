import { queryDatabase } from "../middleware.js";

// Get all fund sources
const getFundSources = (req, res) => {
    console.log("fsg1");
    const query = `SELECT * FROM fund`;
    queryDatabase(query, [], res, "Fund fetched successfully");
};

// Get a single fund source by id
const getFundSourceById = (req, res) => {
    console.log("fsbi1    params, ", req.params);
    const id = req.params.id;
    const query = `SELECT * FROM fund WHERE id = $1`;
    queryDatabase(query, [id], res, "Fund source fetched successfully");
};

// Create a new fund source
const createFundSource = (req, res) => {
    console.log("cf1    body, ", req.body);
    const { fund_source_num, fund_source_name } = req.body;
    const query = `INSERT INTO fund (fund_source_num, fund_source_name) VALUES ($1, $2) RETURNING *`;
    queryDatabase(query, [fund_source_num, fund_source_name], res, "Fund source created successfully");
};

// Update an existing fund source
const updateFundSource = (req, res) => {
    console.log("uf1    body, ", req.body);
    const { id, fund_source_num, fund_source_name } = req.body;
    const query = `UPDATE fund SET fund_source_num = $1, fund_source_name = $2 WHERE id = $3 RETURNING *`;
    queryDatabase(query, [fund_source_num, fund_source_name, id], res, "Fund source updated successfully");
};

// Delete a fund source
const deleteFundSource = (req, res) => {
    console.log("df1    body, ", req.body);
    const id = req.body.id;
    const query = `DELETE FROM fund WHERE id = $1`;
    queryDatabase(query, [id], res, "Fund source deleted successfully");
};

export { getFundSources, getFundSourceById, createFundSource, updateFundSource, deleteFundSource };
