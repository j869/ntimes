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




CREATE TABLE location (
    id SERIAL PRIMARY KEY,
    location_id INT,
    location_name VARCHAR(255),
    role_id INT NULL
);


INSERT INTO location (location_id, location_name) VALUES
(144, 'Albert Park'),
(145, 'Alexandra'),
(146, 'Alfred Nicolas Gardens'),
(147, 'Anakie'),
(148, 'Anglesea'),
(149, 'Anglesea Do Not Use'),
(150, 'Apollo Bay'),
(127348, 'Bacchus Marsh Depot'),
(151, 'Bacchus Marsh Office'),
(152, 'Bairnsdale'),
(135695, 'Bairnsdale (Depot)'),
(153, 'Ballarat'),
(127349, 'Balook Depot'),
(154, 'Beaufort'),
(155, 'Beechworth'),
(156, 'Benalla'),
(157, 'Bendigo'),
(158, 'Bendoc'),
(127350, 'Blackbird Depot'),
(263, 'Bourke Street'),
(142, 'Bourke Street - OLD'),
(22186, 'Box Hill'),
(159, 'Braeside Park'),
(135687, 'Bright (Depot)'),
(160, 'Bright (Office)'),
(135696, 'Brimbank (Depot)'),
(161, 'Brimbank Park'),
(162, 'Brimbank Park -Ctl Ro'),
(127351, 'Buchan Depot'),
(163, 'Buchan Office'),
(164, 'Burnley'),
(165, 'Bushy Park (Depot)'),
(166, 'Cann River'),
(130975, 'Cape Conran (Office)'),
(167, 'Casterton'),
(168, 'Castlemaine'),
(10395, 'Cohuna'),
(10374, 'Cohuna (OLD)'),
(169, 'Colac'),
(135697, 'Colac (Depot)'),
(170, 'Coolart'),
(171, 'Creswick'),
(224, 'Dandenong Ranges Botanic Garden'),
(172, 'Dargo'),
(127352, 'Deddick (Depot)'),
(173, 'Dharnya Centre'),
(174, 'Dunkeld'),
(127353, 'Echuca Depot'),
(175, 'Echuca Office'),
(176, 'Erica'),
(177, 'Ferntree Gully'),
(178, 'Forrest'),
(179, 'Foster (Depot)'),
(135699, 'Foster (Office)'),
(135698, 'Foster Primary (Depot)'),
(180, 'French Island'),
(181, 'Gabo Island'),
(182, 'Geelong Do Not Use'),
(183, 'Gembrook'),
(127354, 'Halls Gap Depot'),
(184, 'Halls Gap Office'),
(127355, 'Hattah Kulkyne Depot'),
(185, 'Hattah Kulkyne Office'),
(186, 'Heyfield'),
(187, 'Hopetoun (Office)'),
(188, 'Horsham'),
(189, 'Inglewood'),
(135700, 'Inverloch (Office & Depot)'),
(190, 'Irymple'),
(191, 'Kerang (Office)'),
(192, 'Kinglake'),
(135701, 'Kinglake (Depot)'),
(119588, 'Knoxfield'),
(127358, 'Lake Eildon Depot'),
(193, 'Lake Eildon Office'),
(23092, 'Launching Way'),
(194, 'Lavers Hill'),
(195, 'Loch Sport'),
(196, 'Lorne'),
(197, 'Lysterfield'),
(198, 'Macarthur Depot'),
(199, 'Macedon'),
(127359, 'Mallacoota Depot'),
(200, 'Mallacoota Office'),
(201, 'Mansfield'),
(202, 'Maroondah'),
(135702, 'Maroondah (Office and Depot)'),
(203, 'Maryborough'),
(204, 'Marysville'),
(205, 'Mildura'),
(135703, 'Morwell (Depot)'),
(121468, 'Mount Eccles'),
(206, 'Mt Beauty'),
(207, 'Mt Buffalo'),
(127360, 'Nathalia Depot'),
(208, 'Nathalia Office'),
(209, 'Natimuk'),
(210, 'National WSC'),
(211, 'Nelson'),
(212, 'Nhill'),
(16423, 'Nicholson Street'),
(213, 'Nyerimilang'),
(214, 'Olinda'),
(127361, 'Omeo Depot'),
(215, 'Omeo Office'),
(216, 'Orbost'),
(135704, 'Orbost (Depot)'),
(217, 'Organ Pipes'),
(302, 'Parks Victoria'),
(9260, 'Patterson River'),
(218, 'Plenty Gorge'),
(219, 'Point Cook'),
(130972, 'Point Hicks Lighthouse'),
(127397, 'Point Nepean Depot'),
(9261, 'Point Nepean Office'),
(220, 'Port Campbell'),
(135705, 'Port Campbell (Depot)'),
(135694, 'Port Welshpool (Depot)'),
(127362, 'Portland Depot'),
(221, 'Portland Office'),
(143, 'Queen St'),
(222, 'Queenscliff'),
(135706, 'Queenscliff Depot'),
(424, 'Rainbow'),
(223, 'Redcliffs'),
(10375, 'Robinvale'),
(225, 'Rosebud'),
(226, 'Sale'),
(227, 'San Remo'),
(135707, 'San Remo Depot'),
(135708, 'Seawinds (Depot)'),
(228, 'Serendip'),
(229, 'Shepherd Road'),
(230, 'Shepparton - Do Not Use'),
(10376, 'Shepparton Depot'),
(231, 'Silvan'),
(232, 'Speed'),
(233, 'St Arnaud'),
(234, 'State Coal Mine'),
(235, 'Stawell'),
(127363, 'Swan Hill Depot'),
(236, 'Swan Hill Office'),
(237, 'Tallangatta'),
(238, 'Tidal River'),
(135709, 'Tower Hill (Depot)'),
(239, 'Traralgon'),
(135710, 'Traralgon (Depot)'),
(23090, 'Twelve Apostles Kiosk'),
(240, 'Underbool'),
(241, 'Upper Yarra'),
(242, 'Wail'),
(135711, 'Wangaratta (Depot)'),
(243, 'Wangaratta Office'),
(244, 'Warrandyte'),
(245, 'Warrnambool'),
(246, 'Werribee Park'),
(247, 'Werrimull'),
(248, 'Westerfolds'),
(249, 'Whitfield'),
(250, 'William Ricketts'),
(251, 'Williamstown'),
(252, 'Wilsons Promontory Lightstation'),
(253, 'Wodonga'),
(254, 'Wonthaggi'),
(255, 'Woodlands'),
(256, 'Woori Yallock'),
(257, 'Wyperfeld'),
(423, 'Yaapeet'),
(258, 'Yanakie'),
(135712, 'Yanakie (Depot)'),
(259, 'Yarra Bend'),
(260, 'Yarram (Office)'),
(261, 'Yarrawonga'),
(262, 'You Yangs Depot'),
(127364, 'You Yangs Office'),
(1, 'Work from Home'),
(2, 'Other Agency Office'),
(3, 'F&E Deployment'),
(4, 'Remote Location');




-- ACTIVITIES MANAGEMENT SCHEMA:
CREATE TABLE activities (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  programs INTEGER[],
  percentages NUMERIC(5,2)[],
  status VARCHAR(255) NOT NULL DEFAULT 'user_defined',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  user_id INTEGER
);

INSERT INTO activities (name, programs, percentages, status, user_id)
VALUES 
  ('Activity Name', '{615,665}', '{60.00,40.00}', 'user_defined', 1),
  ('Activity 2', '{515,555}', '{30.00,70.00}', 'user_defined', 1),
  ('Activity 3', '{414,424}', '{50.00,50.00}', 'emergency', 1);



  CREATE TABLE fund (
    id SERIAL PRIMARY KEY,
    fund_source_num VARCHAR(10) UNIQUE NOT NULL,
    fund_source_name VARCHAR(255) NOT NULL
);

-- Inserting sample data
INSERT INTO fund (fund_source_num, fund_source_name) VALUES
('000', '000 Non Fund Source Related'),
('100', '100 Insurance Claims - General'),
('200', '200 Box Ironbark - Output'),
('210', '210 DSE - Devil Bend - Output'),
('220', '220 DSE - Point Nepean'),
('230', '230 BERC (Bays and Maritime) - Output'),
('240', '240 BERC (Enhancing Vic''s Parks and Reserves) - Output'),
('250', '250 BERC (Great Trails for a Liveable City) - Output'),
('260', '260 BERC (Mullum Mullum) - Output'),
('270', '270 BERC (National Park Upgrades) - Output'),
('280', '280 BERC (Natural Values Management) - Output'),
('290', '290 BERC (Otways) - Output'),
('300', '300 BERC (Point Nepean) - Output'),
('310', '310 BERC (Urban Parks and Trails) - Output');

