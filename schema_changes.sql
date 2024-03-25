

ALTER TABLE ts_timesheet_t
ADD COLUMN variance character varying(255) 
ADD COLUMN variance_type character varying(255)

delete from ts_timesheet_t;

ALTER TABLE ts_timesheet_t
ALTER COLUMN time_accrued TYPE numeric(12, 4) USING time_accrued::numeric(12, 4),
ALTER COLUMN time_til TYPE numeric(12, 4) USING time_til::numeric(12, 4),
ALTER COLUMN time_leave TYPE numeric(12, 4) USING time_leave::numeric(12, 4),
ALTER COLUMN time_overtime TYPE numeric(12, 4) USING time_overtime::numeric(12, 4),
ALTER COLUMN time_comm_svs TYPE numeric(12, 4) USING time_comm_svs::numeric(12, 4);

ALTER TABLE ts_timesheet_t
RENAME COLUMN time_accrued TO time_flexi;

ALTER TABLE ts_timesheet_t
ALTER COLUMN t_comment TYPE TEXT,
ALTER COLUMN notes TYPE TEXT;

