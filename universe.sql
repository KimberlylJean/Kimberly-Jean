--Creating the database
CREATE DATABASE universe;

--Creating the tables
CREATE TABLE galaxy();
CREATE TABLE star();
CREATE TABLE planet();
CREATE TABLE moon();
CREATE TABLE extrasolar_planet();

--Adding the name column
ALTER TABLE galaxy ADD COLUMN name VARCHAR(30) NOT NULL; 
ALTER TABLE star ADD COLUMN name VARCHAR(30) NOT NULL; 
ALTER TABLE planet ADD COLUMN name VARCHAR(30) NOT NULL; 
ALTER TABLE moon ADD COLUMN name VARCHAR(30) NOT NULL;
ALTER TABLE extrasolar_planet ADD COLUMN name VARCHAR(30) NOT NULL; 

--Adding primary keys
ALTER TABLE galaxy ADD COLUMN galaxy_id INT PRIMARY KEY;
ALTER TABLE star ADD COLUMN star_id INT PRIMARY KEY;
ALTER TABLE planet ADD COLUMN planet_id INT PRIMARY KEY;
ALTER TABLE moon ADD COLUMN moon_id INT PRIMARY KEY;
ALTER TABLE extrasolar_planet ADD COLUMN extrasolar_planet_id INT PRIMARY KEY; 

--Adding foreign keys 
ALTER TABLE star ADD COLUMN galaxy_id INT REFERENCES galaxy(galaxy_id);
ALTER TABLE planet ADD COLUMN star_id INT REFERENCES star(star_id);
ALTER TABLE moon ADD COLUMN planet_id INT REFERENCES planet(planet_id);

--ADDING UNIQUE constraint to the id column
ALTER TABLE galaxy ADD CONSTRAINT uniquega_id UNIQUE(galaxy_id);
ALTER TABLE planet ADD CONSTRAINT uniquepl_id UNIQUE(planet_id);
ALTER TABLE star ADD CONSTRAINT uniquest_id UNIQUE(star_id);
ALTER TABLE moon ADD CONSTRAINT uniquemn_id UNIQUE(moon_id);
ALTER TABLE extrasolar_planet ADD CONSTRAINT uniquees_id UNIQUE(extrasolar_planet_id);

---Adding Columns
ALTER TABLE galaxy ADD COLUMN description TEXT;
ALTER TABLE galaxy ADD COLUMN has_life BOOLEAN;
ALTER TABLE galaxy ADD COLUMN is_spherical BOOLEAN;
ALTER TABLE galaxy ADD COLUMN age_in_millions_of_years NUMERIC(4,1);
ALTER TABLE galaxy ADD COLUMN galaxy_types VARCHAR(30);

ALTER TABLE star ADD COLUMN description TEXT;
ALTER TABLE star ADD COLUMN has_life BOOLEAN;
ALTER TABLE star ADD COLUMN is_spherical BOOLEAN;
ALTER TABLE star ADD COLUMN age_in_millions_of_years NUMERIC(4,1);
ALTER TABLE star ADD COLUMN star_types VARCHAR(30);
ALTER TABLE star ADD COLUMN distance_from_earth INT;
ALTER TABLE star ADD COLUMN diameter_in_km INT;

ALTER TABLE planet ADD COLUMN description TEXT;
ALTER TABLE planet ADD COLUMN has_life BOOLEAN;
ALTER TABLE planet ADD COLUMN is_spherical BOOLEAN;
ALTER TABLE planet ADD COLUMN age_in_millions_of_years NUMERIC(4,1);
ALTER TABLE planet ADD COLUMN planet_types VARCHAR(30);
ALTER TABLE planet ADD COLUMN distance_from_earth INT;
ALTER TABLE planet ADD COLUMN diameter_in_km INT;

ALTER TABLE moon ADD COLUMN description TEXT;
ALTER TABLE moon ADD COLUMN has_life BOOLEAN;
ALTER TABLE moon ADD COLUMN is_spherical BOOLEAN;
ALTER TABLE moon ADD COLUMN age_in_millions_of_years NUMERIC(4,1);
ALTER TABLE moon ADD COLUMN moon_types VARCHAR(30);
ALTER TABLE moon ADD COLUMN distance_from_earth INT;
ALTER TABLE moon ADD COLUMN diameter_in_km INT;

ALTER TABLE extrasolar_planet ADD COLUMN description TEXT;


--Adding rows 

INSERT INTO galaxy(galaxy_id,name,description) VALUES(1,'Andromeda Galaxy','nearest large galaxy'),
(2,'Canis Major Dwarf','closest galaxy to the Milky Way'),
(3,'Cygnus A','most powerful cosmic source of radio waves'),
(4,'Maffei 1 and 2','unobserved until late 1960s'),
(5,'Magellanic Cloud','companion galaxies'),
(6,'Milky Way','large spiral system'),
(7,'Virgo A','giant elliptical galaxy');

INSERT INTO planet(planet_id,name,description) VALUES(1,'Mercury','smallest planet in solar system'),
(2,'Venus','opposite direction of most planets'),
(3,'Earth','home planet'),
(4,'Mars','dusty,cold,desert'),
(5,'Jupiter','giant planet'),
(6,'Saturn','complex system of icy rings'),
(7,'Uranus','seventh planet from the Sun'),
(8,'Neptune','eighth and most distant planet orbiting our Sun'),
(9,'Pluto','complex word of ice mountains and frozen plains'),
(10,'Ceres','heavily cratered with large amounts of ice underground'),
(11,'Haumea','one of the fastest rotating large object in our solar system'),
(12,'Eris','largest known dwarf planet in our solar system');

--Adding the moons

--Earth's moon
INSERT INTO moon(moon_id,planet_id,name) VALUES(1,3,'Earths moon');

--Mars
INSERT INTO moon(moon_id,planet_id,name) VALUES(2,4,'Deimos'),(3,4,'Phobos');

--Pluto
INSERT INTO moon(moon_id,planet_id,name) VALUES(4,9,'Charon'),(5,9,'Hydra'),(6,9,'Kerberos'),(7,9,'Nix'),(8,9,'Styx');


--Neptune
INSERT INTO moon(moon_id,planet_id,name) VALUES(9,8,'Despina'),(10,8,'Galatea'),(11,8,'Halimede'),(12,8,'Hippocamp'),(13,8,'Laomedeia');

--Jupiter
INSERT INTO moon(moon_id,planet_id,name) VALUES(14,5,'Io'),(15,5,'Europa'),(16,5,'Ganymede'),(17,5,'Callisto');

--Uranus
INSERT INTO moon(moon_id,planet_id,name) VALUES(18,7,'Ariel'),(19,7,'Belinda'),(20,7,'Bianca'),(21,7,'Caliban');

--Insert stars 
INSERT INTO star(star_id,galaxy_id,name) VALUES(1,2,'Sirius A,B'),(2,3,'Deneb'),(3,3,'Albireo'),(4,5,'R71'),(5,3,'Gamma Cygni'),(6,3,'Delta Cygni');


--Adding extrasolar planets
INSERT INTO extrasolar_planet(name,extrasolar_planet_id) VALUES('HAT-P-1b',1),('55 Cancri e',2),('Kepler-186f',3);










