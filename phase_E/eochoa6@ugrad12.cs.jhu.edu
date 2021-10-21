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

--Create stored procedures for Phase E

-- 1. What artist had the most songs in the top 100s during each U.S presidents administration?
DELIMITER //

DROP PROCEDURE IF EXISTS TopArtistByPresident //

CREATE PROCEDURE TopArtistByPresident(IN pres VARCHAR(35))
BEGIN
    WITH 
        songNArtist AS (SELECT artist, Song.id AS songID, position, year
                        FROM BillboardChart JOIN Song
                        WHERE Song.id = BillboardChart.songID),
                        
        artistsNums AS (SELECT president, artist, COUNT(songID) AS numHits
                                FROM songNArtist JOIN Administration
                                ON songNArtist.year >= startYear AND songNArtist.year < endYear
                                GROUP BY artist, president
                                ORDER BY startYear),
                                
        maxNums AS (SELECT MAX(numHits) AS m, president
                            FROM artistsNums
                            GROUP BY president)
                            
    SELECT M.president, A.artist
    FROM artistsNums AS A JOIN maxNums AS M
    ON A.president = M.president 
    WHERE A.numHits = M.m AND pres = M.president;



END; //

DELIMITER ;

--2. List the top song of each year of the administrations where unemployment increased (from start to end of administration)
DELIMITER //

DROP PROCEDURE IF EXISTS TopSongsIncUnemployment //

CREATE PROCEDURE TopSongsIncUnemployment
BEGIN
WITH topsongs       AS (SELECT songID, song, artist, year
                        FROM BillboardChart JOIN Song
                        ON BillboardChart.songID = Song.id
                        WHERE position = 1),
                        
     transyrs       AS (SELECT E.year, president, unemploymentRate, startYear, endYear
                        FROM Administration AS A JOIN EconomicHealth AS E
                        ON A.startYear= E.year OR A.endYear-1 = E.year
                        ORDER BY E.year),
                        
     uincadmins     AS (SELECT transyrs.president, transyrs.startYear as st, transyrs.endYear as end
                    FROM transyrs JOIN transyrs AS yrsend
                    WHERE transyrs.president = yrsend.president AND 
                           transyrs.year < yrsend.year AND
                           transyrs.unemploymentRate < yrsend.unemploymentRate)
SELECT year, president, song, artist
FROM topsongs JOIN uincadmins 
WHERE topsongs.year >= st AND topsongs.year < end
ORDER BY topsongs.year;



END; //

DELIMITER ;



--HELPER QUERY FOR FINDING DECADE
DELIMITER //

DROP PROCEDURE IF EXISTS GetDecades //

CREATE PROCEDURE GetDecades
BEGIN
    SELECT DISTINCT B1.year, (SELECT MIN(B2.year) 
                          FROM BillboardChart AS B2 
                          WHERE B1.year DIV 10 = B2.year DIV 10)
                          AS decade
    FROM BillboardChart AS B1
    WHERE B1.year != 1959
    ORDER BY year;

END; //

DELIMITER ;

-- 14. What was the average acousticness of the top 100 songs of each decade ?
DELIMITER //

DROP PROCEDURE IF EXISTS AvgAcousticByDecade //

CREATE PROCEDURE AvgAcousticByDecade
BEGIN
    SELECT decade, AVG(S.acousticness) AS avgAcousticness
    FROM (CALL GetDecades) AS D
    JOIN BillboardChart AS BC ON D.year = BC.year 
    JOIN Song AS S ON S.id = BC.songId 
    WHERE S.acousticness IS NOT NULL
    GROUP BY D.decade;  

END; //

DELIMITER ;



-- 15. What was the most popular genre of each decade? (note: 90's has a tie)
DELIMITER //

DROP PROCEDURE IF EXISTS TopGenreByDecade //

CREATE PROCEDURE TopGenreByDecade
BEGIN
WITH  DecadeGenreCount AS   (SELECT D.decade, SG.genre, COUNT(SG.songId) AS numSongs 
                       FROM (CALL GetDecades) AS D
                       JOIN BillboardChart AS BC ON D.year = BC.year 
                       JOIN SongGenre AS SG ON SG.songId = BC.songId
                       GROUP BY D.decade, SG.genre)  
SELECT t1.decade, t1.genre AS biggestGenre, t1.numSongs 
FROM DecadeGenreCount AS t1
WHERE t1.numSongs IN (SELECT MAX(numSongs) 
                      FROM DecadeGenreCount AS t2 
                      WHERE t1.decade = t2.decade); 


END; //

DELIMITER ;

