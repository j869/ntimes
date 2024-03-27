


ALTER TABLE ts_timesheet_t
RENAME COLUMN duty_catagory TO duty_category;


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
-- add values for user
