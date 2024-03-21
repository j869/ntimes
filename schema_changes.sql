


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
    time_accrued VARCHAR(8),
    time_til VARCHAR(8),
    time_leave VARCHAR(8),
    time_overtime VARCHAR(8),
    time_comm_svs VARCHAR(8),
    t_comment VARCHAR(255),
    location_id INTEGER,
    activity VARCHAR(255),
    notes VARCHAR(255),
    entry_date DATE,
    on_duty SMALLINT,
    duty_catagory SMALLINT,
    "status" VARCHAR(10),
    rwe_day SMALLINT,
    fund_src VARCHAR(10)
);

INSERT INTO ts_timesheet_t ("person_id", "work_date", "time_start", "time_finish", "time_lunch", "time_extra_break", "time_total", "time_accrued", "time_til", "time_leave", "time_overtime", "time_comm_svs", "t_comment", "location_id", "activity", "notes", "entry_date", "on_duty", "duty_catagory", "status", "rwe_day", "fund_src") 
VALUES (1, '2024-03-01', '09:00', '17:00', '01:00', '00:00', '08:00', '08:00', '00:00', '00:00', '00:00', '00:00', 'Regular work hours', 1, 'Coding', 'Meeting with team lead', '2024-03-01', 1, 1, 'Submitted', 0, 'Internal');
INSERT INTO ts_timesheet_t ("person_id", "work_date", "time_start", "time_finish", "time_lunch", "time_extra_break", "time_total", "time_accrued", "time_til", "time_leave", "time_overtime", "time_comm_svs", "t_comment", "location_id", "activity", "notes", "entry_date", "on_duty", "duty_catagory", "status", "rwe_day", "fund_src") 
VALUES (1, '2024-03-01', '08:30', '16:30', '00:30', '00:00', '08:00', '08:00', '00:00', '00:00', '00:00', '00:00', 'Development tasks completed', 2, 'Testing', 'Code review session', '2024-03-01', 1, 1, 'Submitted', 0, 'Internal');
INSERT INTO ts_timesheet_t ("person_id", "work_date", "time_start", "time_finish", "time_lunch", "time_extra_break", "time_total", "time_accrued", "time_til", "time_leave", "time_overtime", "time_comm_svs", "t_comment", "location_id", "activity", "notes", "entry_date", "on_duty", "duty_catagory", "status", "rwe_day", "fund_src") 
VALUES (2, '2024-03-01', '09:30', '17:30', '01:00', '00:00', '08:00', '08:00', '00:00', '00:00', '00:00', '00:00', 'Client meeting', 3, 'Client Communication', 'Discuss project progress', '2024-03-01', 1, 1, 'Submitted', 0, 'External');
