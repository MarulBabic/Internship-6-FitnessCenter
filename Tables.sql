CREATE TABLE Countries(
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL,
  population INTEGER NOT NULL,
  avg_salary FLOAT NOT NULL
);

CREATE TABLE Coaches(
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  birth_date DATE NOT NULL,
  gender VARCHAR(10) CHECK (gender IN ('MUŠKI', 'ŽENSKI', 'NEPOZNATO', 'OSTALO')),
  country INTEGER REFERENCES Countries(id)
);

CREATE TABLE FitnessCenters(
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  country INTEGER REFERENCES Countries(id),
  working_hours_start TIMESTAMP NOT NULL,
  working_hours_end TIMESTAMP NOT NULL
);

CREATE TABLE FitnessCenterCoaches (
  fitness_center_id INTEGER REFERENCES FitnessCenters(id),
  coach_id INTEGER REFERENCES Coaches(id),
  coach_type VARCHAR(20),
  PRIMARY KEY (fitness_center_id, coach_id)
);

ALTER TABLE FitnessCenterCoaches
ADD CONSTRAINT fitnesscentercoaches_coach_type_check
CHECK (coach_type IN ('glavni trener', 'pomocni trener'));

CREATE TABLE Activities(
  id SERIAL PRIMARY KEY,
  type VARCHAR(50) NOT NULL,
  CONSTRAINT chk_activity_type CHECK (type IN ('strength training', 'cardio', 'yoga', 'dance', 'injury rehabilitation'))
);

CREATE TABLE ActivitiesInFC(
  id SERIAL PRIMARY KEY,
  fitness_center INTEGER REFERENCES FitnessCenters(id),
  activity INTEGER REFERENCES Activities(id),
  coach INTEGER REFERENCES Coaches(id)
);


CREATE TABLE Schedules (
  id SERIAL PRIMARY KEY,
  activityCode INTEGER REFERENCES ActivitiesInFC(id),
  uniqueCode VARCHAR(20) UNIQUE NOT NULL,
  occupancy INTEGER NOT NULL,
  max_occupancy INTEGER NOT NULL,
  time_of_activity TIMESTAMP NOT NULL,
  price_per_session FLOAT NOT NULL,
  CONSTRAINT chk_occupancy CHECK (occupancy <= max_occupancy)
);

CREATE TABLE Users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  birth_date DATE NOT NULL
);

CREATE TABLE UserActivities (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES Users(id),
  schedule_id INTEGER REFERENCES Schedules(id)
);

CREATE OR REPLACE FUNCTION check_main_trainer_limit() 
RETURNS TRIGGER AS $$
BEGIN
  IF (SELECT COUNT(*) 
      FROM ActivitiesInFC 
      WHERE coach = NEW.coach AND fitness_center = NEW.fitness_center) >= 2
      AND (SELECT coach_type 
           FROM FitnessCenterCoaches 
           WHERE coach_id = NEW.coach 
           AND fitness_center_id = NEW.fitness_center) = 'glavni trener' THEN
    RAISE EXCEPTION 'Trener može biti glavni trener na najviše 2 aktivnosti u ovom fitness centru';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_main_trainer_limit
BEFORE INSERT ON ActivitiesInFC
FOR EACH ROW
EXECUTE FUNCTION check_main_trainer_limit();