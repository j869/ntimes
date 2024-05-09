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



-- Intermediate Table for Many-to-Many Relationship
CREATE TABLE IF work_schedule (
  "id" serial PRIMARY KEY,
  "schedule_day" varchar(255)[],
  "paid_hours" numeric(5,2),
  "start_date" timestamp,
  "end_date" timestamp
);

INSERT INTO work_schedule ("schedule_day", "paid_hours", "start_date", "end_date")
VALUES ('{Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday}', 7.60, '2023-12-31 18:31:18', '2024-12-31 18:31:28');


CREATE TABLE user_work_schedule (
  "user_id" int4 NOT NULL,
  "schedule_id" int4 NOT NULL DEFAULT 1,
  "next_pay_date" date,
  "payment_status" int2,
  "total_work_hours" int4,
  PRIMARY KEY ("user_id", "schedule_id")
);


