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
INSERT INTO users (username, password) VALUES ('admin', 'hashed_password_of_your_choice');


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


