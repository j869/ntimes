
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

