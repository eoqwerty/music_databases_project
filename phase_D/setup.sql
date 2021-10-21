--Emilia Ochoa (eochoa6)
--Angi Benton (abenton3)

-- Create the EconomicHealth Relation 
DROP TABLE IF EXISTS EconomicHealth;
CREATE TABLE EconomicHealth 
(
year INT,
unemploymentRate REAL,
realGdpPch REAL,
snpRoi REAL,
PRIMARY KEY (year),
CHECK (year <= 2021),
CHECK (0 <= unemploymentRate AND unemploymentRate <= 100),
CHECK (-100 <= snpRoi)
);

--Change this to your full path
LOAD DATA LOCAL INFILE '/Users/emi.ochoa/databases/databases_project/phase_C/EconomicHealth.txt' 
INTO TABLE EconomicHealth
COLUMNS TERMINATED BY '\t'
LINES TERMINATED BY '\n'; 

SELECT * FROM EconomicHealth; 


--Create Administration relation
DROP TABLE IF EXISTS Administration;
CREATE TABLE Administration
(
president VARCHAR(25),
startYear INT,
endYear INT,
PRIMARY KEY (startYear, endYear),
CHECK (startYear <= 2021)
);

--Change this to your full path
LOAD DATA LOCAL INFILE '/Users/emi.ochoa/databases/databases_project/phase_C/Administration.txt' 
INTO TABLE Administration
COLUMNS TERMINATED BY '\t'
LINES TERMINATED BY '\n'; 

SELECT * FROM Administration; 


--Create Genre relation
DROP TABLE IF EXISTS Genre;
CREATE TABLE Genre
(
genre VARCHAR(50),
PRIMARY KEY (genre)
);

--Change this to your full path
LOAD DATA LOCAL INFILE '/Users/emi.ochoa/databases/databases_project/phase_C/Genre.txt' 
INTO TABLE Genre
COLUMNS TERMINATED BY '\t'
LINES TERMINATED BY '\n'; 

SELECT * FROM Genre; 


--Create Song relation
DROP TABLE IF EXISTS Song;
CREATE TABLE Song 
(
id INT, 
song VARCHAR(100) NOT NULL,
artist VARCHAR(100) NOT NULL,
musicKey INT,
tempo REAL,
explicit VARCHAR(5),
popularity INT,
danceability REAL,
energy REAL,
acousticness REAL,
instrumentalness REAL,
liveness REAL,
valence REAL,
PRIMARY KEY (id),
CHECK(tempo > 0),
CHECK(0 <= popularity AND popularity <= 100),
CHECK(0 <= danceability AND danceability <= 1),
CHECK(0 <= energy AND energy <= 1),
CHECK(0 <= acousticness AND acousticness <= 1),
CHECK(0 <= instrumentalness AND instrumentalness <= 1),
CHECK(0 <= liveness AND liveness <= 1),
CHECK(0 <= valence AND valence <= 1)
);


--Change this to your full path
LOAD DATA LOCAL INFILE '/Users/emi.ochoa/databases/databases_project/phase_C/Song.txt' 
INTO TABLE Song
COLUMNS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
(id, song, artist, @v_musicKey, @v_tempo, @v_explicit, @v_popularity, @v_danceability, @v_energy, @v_acousticness, @v_instrumentalness, @v_liveness, @v_valence)
SET
musicKey = NULLIF(@v_musicKey, ''),
tempo = NULLIF(@v_tempo, ''),
explicit = NULLIF(@v_explicit, ''),
popularity = NULLIF(@v_popularity, ''),
danceability = NULLIF(@v_danceability, ''),
energy = NULLIF(@v_energy, ''),
acousticness = NULLIF(@v_acousticness, ''),
instrumentalness = NULLIF(@v_instrumentalness, ''),
liveness = NULLIF(@v_liveness, ''),
valence = NULLIF(@v_valence, '')
;

SELECT * FROM Song; 


--Create SongGenre relation
DROP TABLE IF EXISTS SongGenre;
CREATE TABLE SongGenre
(
songID INT,
genre VARCHAR(50),
PRIMARY KEY (songID, genre),
FOREIGN KEY (songID) REFERENCES Song(id)  ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (genre) REFERENCES Genre(genre) ON DELETE CASCADE ON UPDATE CASCADE
);


--Change this to your full path
LOAD DATA LOCAL INFILE '/Users/emi.ochoa/databases/databases_project/phase_C/SongGenre.txt' 
INTO TABLE SongGenre
COLUMNS TERMINATED BY '\t'
LINES TERMINATED BY '\n'; 

SELECT * FROM SongGenre; 


--Create BillboardChart relation
DROP TABLE IF EXISTS BillboardChart;
CREATE TABLE BillboardChart 
(
songID INT, 
year INT,
position INT,
PRIMARY KEY (songID, year),
FOREIGN KEY(songId) REFERENCES Song(id) ON DELETE CASCADE ON UPDATE CASCADE
);

--Change this to your full path
LOAD DATA LOCAL INFILE '/Users/emi.ochoa/databases/databases_project/phase_C/BillboardChart.txt' 
INTO TABLE BillboardChart
COLUMNS TERMINATED BY '\t'
LINES TERMINATED BY '\n'; 

SELECT * FROM BillboardChart;

