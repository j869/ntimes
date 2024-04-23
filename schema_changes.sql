CREATE VIEW leave_balances AS
SELECT
    person_id,
    SUM(time_flexi) AS flexi_balance,
    SUM(time_til) AS til_balance,
    SUM(rwe_day) AS rdo_balance,
    SUM(time_leave) AS total_leave,
    SUM(time_overtime) AS total_overtime
FROM
    ts_timesheet_t
GROUP BY
     person_id,
	 username;
