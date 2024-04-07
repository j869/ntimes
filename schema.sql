-- Create the database
CREATE DATABASE ntimes;

-- Create schema
CREATE SCHEMA public;

-- Create users table
drop table ts_user_t;
CREATE TABLE ts_user_t (
    id SERIAL PRIMARY KEY,
    person_id INTEGER,                  -- (NUMBER(10,0))
    advance_entry_days INTEGER,         -- Timesheet!Admin("Advance Entry Days")
    at_agreement VARCHAR(255),          -- Timesheet!Admin("AT Agreement")
    at_balance NUMERIC(6,2),            -- (NUMBER(6,2))
    at_carried INTEGER,                 -- Timesheet!Admin("AT Carried")
    at_limit_hours NUMERIC(6,2),        -- Timesheet!Admin("AT Limit (hours)")
    at_max NUMERIC(6,2),                -- Timesheet!Admin("AT Max")
    at_open NUMERIC(6,2),               -- (NUMBER(6,2))
    auto_calculate_hours BOOLEAN,       -- Timesheet!Admin("Auto Calculate Hours")
    current_period INTEGER,             -- Timesheet!Admin("Current Period")
    default_location VARCHAR(255),      -- Timesheet!Admin("Default Location")
    fire_role VARCHAR(255),             -- Timesheet!Admin("Fire Role")
    fund_source VARCHAR(255),           -- Timesheet!Admin("FundSource (PV)")
    last_update DATE,                   -- (DATE)
    location_id BIGINT,                 -- (NUMBER(15,0))
    normal_start TIME,                  -- Timesheet!Admin("Normal Start")
    rdo_balance NUMERIC(6,2),           -- RDO Balance
    rdo_carried INTEGER,                -- Timesheet!Admin("RDO Carried")
    rdo_minimum NUMERIC(6,2),           -- Timesheet!Admin("RDO Minimum")
    rdo_open INTEGER,                   -- (NUMBER(2,0))
    rostered_days INTEGER,              -- Timesheet!Admin("Rostered Days")
    takes_rdos BOOLEAN,                 -- Timesheet!Admin("Takes RDOs")
    timesheet_mode VARCHAR(255),        -- Timesheet!Admin("Timesheet Mode")
    timesheet_version VARCHAR(255),     -- Timesheet!Admin("Timesheet Version")
    weekends_worked INTEGER,            -- Timesheet!Admin("Weekends Worked")
    workcentre VARCHAR(255),            -- Timesheet!Admin("Workcentre")
    file_location VARCHAR(256)          -- (VARCHAR2(256 BYTE))
);


-- table for login and authentication
drop table users;
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(31),
    email VARCHAR(255),                 -- email VARCHAR(255) NOT NULL UNIQUE, -- email for login
    "password" VARCHAR(64),               -- (VARCHAR2(64 BYTE))
    "role" VARCHAR(15), 
    verification_token VARCHAR(255),     -- crypto.randomBytes generated to validate email address
    verified_email BOOLEAN             --
);

create table personelle (           -- stores more sensitive information for users, ie  names and roles
    person_id INTEGER,                  -- primary key, links to users.person_id
    position VARCHAR(255),              -- Timesheet!Admin("Position")
    first_name VARCHAR(255),            -- Timesheet!Admin("First Name")
    last_name VARCHAR(255)             -- Timesheet!Admin("Last Name")
);


-- Create timesheets table
CREATE TABLE timesheets (
    timesheet_id SERIAL PRIMARY KEY,
    user_id INT,                          -- user_id INT REFERENCES public.users(user_id),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create a default admin user
INSERT INTO users (username, email, password, verified_email) VALUES ('john@buildingbb.com.au', 'john@buildingbb.com.au', '$2b$10$go9kjxt5Vr.QhenMQoexDeRfKwQjLs.2ZfnhmXuCp.gKp8cda2ahu', true);


DROP TABLE IF EXISTS public.debug;
CREATE TABLE debug (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP,
    ip_address VARCHAR(45),
	session_id VARCHAR(255),
	screen_size VARCHAR(127),
    browserOS VARCHAR(255),
    agent TEXT,
	request text
);



drop table ts_user_t;
CREATE TABLE ts_user_t (
    id SERIAL PRIMARY KEY,
    person_id INTEGER,                  -- (NUMBER(10,0))
    advance_entry_days INTEGER,         -- Timesheet!Admin("Advance Entry Days")
    at_agreement VARCHAR(255),          -- Timesheet!Admin("AT Agreement")
    at_balance NUMERIC(6,2),            -- (NUMBER(6,2))
    at_carried INTEGER,                 -- Timesheet!Admin("AT Carried")
    at_limit_hours NUMERIC(6,2),        -- Timesheet!Admin("AT Limit (hours)")
    at_max NUMERIC(6,2),                -- Timesheet!Admin("AT Max")
    at_open NUMERIC(6,2),               -- (NUMBER(6,2))
    auto_calculate_hours BOOLEAN,       -- Timesheet!Admin("Auto Calculate Hours")
    current_period INTEGER,             -- Timesheet!Admin("Current Period")
    default_location VARCHAR(255),      -- Timesheet!Admin("Default Location")
    fire_role VARCHAR(255),             -- Timesheet!Admin("Fire Role")
    fund_source VARCHAR(255),           -- Timesheet!Admin("FundSource (PV)")
    last_update DATE,                   -- (DATE)
    location_id BIGINT,                 -- (NUMBER(15,0))
    normal_start TIME,                  -- Timesheet!Admin("Normal Start")
    rdo_balance NUMERIC(6,2),           -- RDO Balance
    rdo_carried INTEGER,                -- Timesheet!Admin("RDO Carried")
    rdo_minimum NUMERIC(6,2),           -- Timesheet!Admin("RDO Minimum")
    rdo_open INTEGER,                   -- (NUMBER(2,0))
    rostered_days INTEGER,              -- Timesheet!Admin("Rostered Days")
    takes_rdos BOOLEAN,                 -- Timesheet!Admin("Takes RDOs")
    timesheet_mode VARCHAR(255),        -- Timesheet!Admin("Timesheet Mode")
    timesheet_version VARCHAR(255),     -- Timesheet!Admin("Timesheet Version")
    weekends_worked INTEGER,            -- Timesheet!Admin("Weekends Worked")
    workcentre VARCHAR(255),            -- Timesheet!Admin("Workcentre")
    file_location VARCHAR(256)          -- (VARCHAR2(256 BYTE))
);



drop table ts_timesheet_t;
CREATE TABLE ts_timesheet_t (
    id SERIAL PRIMARY KEY,
    person_id INTEGER,
	username VARCHAR(31),
    work_date DATE,
    time_start VARCHAR(8),
    time_finish VARCHAR(8),
    time_lunch VARCHAR(8),
    time_extra_break VARCHAR(8),
    time_total VARCHAR(8),
    time_flexi numeric(12, 4) ,
    time_til numeric(12, 4) ,
    time_leave numeric(12, 4) ,
    time_overtime numeric(12, 4) ,
    time_comm_svs numeric(12, 4) ,
    t_comment TEXT,
    location_id INTEGER,
    activity VARCHAR(255),
    notes TEXT,
    entry_date DATE,
    on_duty SMALLINT,
    duty_category SMALLINT,       -- 2:fire, 
    "status" VARCHAR(10),
    rwe_day SMALLINT,           -- will be 1 in the following circumstances: (i) if it was a normal work day, and you got called to a fire, 
    fund_src VARCHAR(10),
    variance VARCHAR(255),
    variance_type VARCHAR(255)
);

INSERT INTO ts_timesheet_t ("person_id", "work_date", "time_start", "time_finish", "time_lunch", "time_extra_break", "time_total", "time_accrued", "time_til", "time_leave", "time_overtime", "time_comm_svs", "t_comment", "location_id", "activity", "notes", "entry_date", "on_duty", "duty_catagory", "status", "rwe_day", "fund_src") 
VALUES (1, '2024-03-01', '09:00', '17:00', '01:00', '00:00', '08:00', '08:00', '00:00', '00:00', '00:00', '00:00', 'Regular work hours', 1, 'Coding', 'Meeting with team lead', '2024-03-01', 1, 1, 'Submitted', 0, 'Internal');
INSERT INTO ts_timesheet_t ("person_id", "work_date", "time_start", "time_finish", "time_lunch", "time_extra_break", "time_total", "time_accrued", "time_til", "time_leave", "time_overtime", "time_comm_svs", "t_comment", "location_id", "activity", "notes", "entry_date", "on_duty", "duty_catagory", "status", "rwe_day", "fund_src") 
VALUES (1, '2024-03-01', '08:30', '16:30', '00:30', '00:00', '08:00', '08:00', '00:00', '00:00', '00:00', '00:00', 'Development tasks completed', 2, 'Testing', 'Code review session', '2024-03-01', 1, 1, 'Submitted', 0, 'Internal');
INSERT INTO ts_timesheet_t ("person_id", "work_date", "time_start", "time_finish", "time_lunch", "time_extra_break", "time_total", "time_accrued", "time_til", "time_leave", "time_overtime", "time_comm_svs", "t_comment", "location_id", "activity", "notes", "entry_date", "on_duty", "duty_catagory", "status", "rwe_day", "fund_src") 
VALUES (2, '2024-03-01', '09:30', '17:30', '01:00', '00:00', '08:00', '08:00', '00:00', '00:00', '00:00', '00:00', 'Client meeting', 3, 'Client Communication', 'Discuss project progress', '2024-03-01', 1, 1, 'Submitted', 0, 'External');



CREATE TABLE public_holidays (
    id SERIAL PRIMARY KEY,
    holiday_name VARCHAR(255) NOT NULL,
    holiday_date DATE NOT NULL
);



INSERT INTO public_holidays (holiday_name, holiday_date) VALUES
('New Year''s Day', '2024-01-01'),
('Australia Day', '2024-01-26'),
('Labour Day', '2024-03-11'),
('Good Friday', '2024-03-29'),
('Saturday before Easter Sunday', '2024-03-30'),
('Easter Sunday', '2024-03-31'),
('Easter Monday', '2024-04-01'),
('ANZAC Day', '2024-04-25'),
('King''s Birthday', '2024-06-10'),
('Friday before the AFL Grand Final', '2024-09-27'),
('Melbourne Cup', '2024-11-05'),
('Christmas Day', '2024-12-25'),
('Boxing Day', '2024-12-26');



CREATE TABLE rdo_eligibility (
    user_id INT NOT NULL,
    is_eligible BOOLEAN NOT NULL,
    PRIMARY KEY (user_id)
);