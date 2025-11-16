
-- MySQL setup for Stray Dog Management (2025–2027; 20 cities)
-- Usage:
--   mysql -u root -p -e "CREATE DATABASE stray_dog_mgmt_full;"
--   mysql --local-infile=1 -u root -p stray_dog_mgmt_full < mysql_setup_full.sql

DROP TABLE IF EXISTS fact_budget;
DROP TABLE IF EXISTS fact_adoptions;
DROP TABLE IF EXISTS fact_abc;
DROP TABLE IF EXISTS fact_incidents;
DROP TABLE IF EXISTS dim_ngos;
DROP TABLE IF EXISTS dim_calendar;
DROP TABLE IF EXISTS dim_cities;
DROP TABLE IF EXISTS dim_states;

CREATE TABLE dim_states ( StateID INT PRIMARY KEY, State VARCHAR(60) );
CREATE TABLE dim_cities (
  CityID INT PRIMARY KEY, StateID INT, State VARCHAR(60), City VARCHAR(80), Population BIGINT,
  FOREIGN KEY (StateID) REFERENCES dim_states(StateID)
);
CREATE TABLE dim_calendar (
  Date DATE PRIMARY KEY, Year INT, Month INT, Quarter INT, MonthName VARCHAR(10), DayOfWeek VARCHAR(20), IsWeekend BOOLEAN
);
CREATE TABLE dim_ngos (
  NGOID INT PRIMARY KEY, NGOName VARCHAR(80), CityID INT, Capacity INT, HasVetOnsite BOOLEAN, HasAmbulance BOOLEAN, City VARCHAR(80), State VARCHAR(60),
  FOREIGN KEY (CityID) REFERENCES dim_cities(CityID)
);
CREATE TABLE fact_incidents (
  IncidentID BIGINT PRIMARY KEY, Date DATE, CityID INT, IncidentType VARCHAR(30), Severity VARCHAR(10), ResponseTimeMins INT, Resolved BOOLEAN, AssignedNGO INT, City VARCHAR(80), State VARCHAR(60),
  FOREIGN KEY (CityID) REFERENCES dim_cities(CityID)
);
CREATE TABLE fact_abc (
  ProgramID BIGINT PRIMARY KEY, Date DATE, CityID INT, ABC_Surgeries INT, Vaccinations INT, MobileCamp BOOLEAN, City VARCHAR(80), State VARCHAR(60),
  FOREIGN KEY (CityID) REFERENCES dim_cities(CityID)
);
CREATE TABLE fact_adoptions (
  AdoptID BIGINT PRIMARY KEY, Date DATE, CityID INT, ShelterIntake INT, Adoptions INT, City VARCHAR(80), State VARCHAR(60),
  FOREIGN KEY (CityID) REFERENCES dim_cities(CityID)
);
CREATE TABLE fact_budget (
  BudgetID BIGINT PRIMARY KEY, Year INT, Month INT, CityID INT, BudgetAllocated DECIMAL(18,2), BudgetUtilized DECIMAL(18,2), City VARCHAR(80), State VARCHAR(60),
  FOREIGN KEY (CityID) REFERENCES dim_cities(CityID)
);

CREATE INDEX idx_incidents_date_city ON fact_incidents (Date, CityID);
CREATE INDEX idx_abc_date_city      ON fact_abc (Date, CityID);
CREATE INDEX idx_adopt_date_city    ON fact_adoptions (Date, CityID);
CREATE INDEX idx_budget_ym_city     ON fact_budget (Year, Month, CityID);

LOAD DATA LOCAL INFILE 'dim_states.csv'     INTO TABLE dim_states     FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'dim_cities.csv'     INTO TABLE dim_cities     FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'dim_calendar.csv'   INTO TABLE dim_calendar   FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'dim_ngos.csv'       INTO TABLE dim_ngos       FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'fact_incidents.csv' INTO TABLE fact_incidents FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'fact_abc.csv'       INTO TABLE fact_abc       FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'fact_adoptions.csv' INTO TABLE fact_adoptions FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'fact_budget.csv'    INTO TABLE fact_budget    FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
