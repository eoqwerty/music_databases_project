--Emilia Ochoa (eochoa6)
--Angi Benton (abenton3)

CREATE TABLE EconomicHealth 
(
year INT,
unemploymentRate REAL,
realGdpPch REAL,
snpRoi REAL,
PRIMARY KEY (year),
CHECK (1948 <= year AND year <= 2020),
CHECK (0 <= unemploymentRate AND unemploymentRate <= 100),
CHECK (-100 <= snpRoi)
);

--Change this to your full path
LOAD DATA LOCAL INFILE '/Users/emi.ochoa/databases/databases_project/phase_C/EconomicHealth.txt' 
INTO TABLE EconomicHealth
COLUMNS TERMINATED BY ','
LINES TERMINATED BY '\n'; 

SELECT * FROM EconomicHealth 


--Create Administration relation

CREATE TABLE Administration
(
president VARCHAR(25),
startYear INT,
endYear INT,
PRIMARY KEY (startYear, endYear),
CHECK (1953 <= startYear AND startYear <= 2017)
);

--Change this to your full path
LOAD DATA LOCAL INFILE '/Users/emi.ochoa/databases/databases_project/phase_C/Administration.txt' 
INTO TABLE Administration
COLUMNS TERMINATED BY ','
LINES TERMINATED BY '\n'; 

SELECT * FROM Administration 


--Create Genre relation
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

SELECT * FROM Genre 


--Create Song relation
CREATE TABLE Song 
(
id INT, 
song VARCHAR(25),
artist VARCHAR(25),
musicKey INT,
tempo REAL,
danceability REAL,
energy REAL,
acousticness REAL,
instrumentalness REAL,
liveness REAL,
valence REAL,
PRIMARY KEY (id)
);

--Change this to your full path
LOAD DATA LOCAL INFILE '/Users/emi.ochoa/databases/databases_project/phase_C/Song.txt' 
INTO TABLE Song
COLUMNS TERMINATED BY '\t'
LINES TERMINATED BY '\n';

SELECT * FROM Song 


--Create SongGenre relation
CREATE TABLE SongGenre
(
songID INT,
genre VARCHAR(50),
PRIMARY KEY (songID, genre),
FOREIGN KEY (songID) REFERENCES Song(id),
FOREIGN KEY (genre) REFERENCES Genre(genre)
);


--Change this to your full path
LOAD DATA LOCAL INFILE '/Users/emi.ochoa/databases/databases_project/phase_C/SongGenre.txt' 
INTO TABLE SongGenre
COLUMNS TERMINATED BY '\t'
LINES TERMINATED BY '\n'; 

SELECT * FROM SongGenre 


--Create BillboardChart relation
CREATE TABLE BillboardChart 
(
songID INT, 
year INT,
position INT,
PRIMARY KEY (songID, year),
FOREIGN KEY(songId) REFERENCES Song(id)
);

--Change this to your full path
LOAD DATA LOCAL INFILE '/Users/emi.ochoa/databases/databases_project/phase_C/BillboardChart.txt' 
INTO TABLE BillboardChart
COLUMNS TERMINATED BY '\t'
LINES TERMINATED BY '\n'; 

SELECT * FROM BillboardChart

