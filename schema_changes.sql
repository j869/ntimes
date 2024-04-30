-- CREATE VIEW leave_balances AS
-- SELECT
--     person_id,
--     SUM(time_flexi) AS flexi_balance,
--     SUM(time_til) AS til_balance,
--     SUM(rwe_day) AS rdo_balance,
--     SUM(time_leave) AS total_leave,
--     SUM(time_overtime) AS total_overtime
-- FROM
--     ts_timesheet_t
-- GROUP BY
--      person_id,
-- 	 username;




-- Create a table for user metadata
-- Create a table for user metadataxx`
CREATE TABLE ts_user_t (
    user_id INT PRIMARY KEY,
    role_id INT,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    middle_name VARCHAR(255),
    birth_date TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Create a table for staff hierarchy
CREATE TABLE staff_hierarchy (
    user_id INT,
    manager_id INT,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (manager_id) REFERENCES users(id),
    PRIMARY KEY (user_id, manager_id)
);
