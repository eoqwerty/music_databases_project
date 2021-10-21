--Emilia Ochoa (eochoa6)
--Angi Benton (abenton3)

-- 1. What artist had the most songs in the top 100s during each U.S presidents administration?
-- *Note: since we only have music data up till 2017, the max number of times an artist appears in top 100
--        during the trump admin was 3 times. Four different artists appeared 3 times.
--        similarly, two different artists (Madonna and Mariah Carey) had the same number of song

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
WHERE A.numHits = M.m

--2. List the top song of each year of the administrations where unemployment increased (from start to end of administration)
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


--5. What is the average popularity, energy, and danceability of top 100 songs, grouped by genre?
SELECT genre, AVG(popularity) AS popularity, AVG(energy) AS energy, AVG(danceability) AS danceability
FROM SongGenre JOIN Song
ON SongGenre.songID = Song.id
WHERE popularity IS NOT NULL
GROUP BY genre

--6. What were the years where the average tempo of the top 100 tracks was > 120 bpm, the average 'energy' was > 0.5, the and the S&P 500 grew by > 10%?
--*7. What was the mean track popularity during recession years, grouped by genre?
--10. What is the average ‘danceability’ of the most popular songs during years where the S&P Roi fell > 5%s?
WITH    yrs AS( SELECT year
                FROM EconomicHealth
                WHERE snpRoi < 5.0),
                
        songs AS (SELECT Song.danceability, Song.id AS songID, position, year
                  FROM BillboardChart JOIN Song
                  WHERE Song.id = BillboardChart.songID AND danceability != 0.0)
                
SELECT songs.year, AVG(danceability)
FROM songs JOIN yrs 
        ON songs.year = yrs.year
GROUP BY songs.year

--11. What was the most popular genre of music in each of the years where overall GDP decreased?
WITH   genreCntPerYr AS  (SELECT BC.year, SG.genre, COUNT(SG.songID) AS cnt
                     FROM SongGenre AS SG JOIN BillboardChart AS BC
                     ON SG.songID = BC.songID
                     GROUP BY SG.genre, BC.year),
                     
       yearMaxes AS (SELECT year, MAX(cnt) AS maxs
                     FROM genreCntPerYr
                     GROUP BY year),

       topGenreByYr AS (SELECT YM.year, genre, cnt
                        FROM yearMaxes AS YM JOIN genreCntPerYr AS GC
                        ON YM.maxs = GC.cnt AND YM.year = GC.year)
                        
SELECT yrs.year, genre, cnt
FROM topGenreByYr JOIN (SELECT year
                FROM EconomicHealth
                WHERE realGdpPch < 0) as yrs
ON yrs.year = topGenreByYr.year


--12. What was the average unemployment rate during years where ‘pop’ was the most popular genre?
WITH popcntbyyr AS  (SELECT BC.year, COUNT(SG.songID) AS cnt
                     FROM SongGenre AS SG JOIN BillboardChart AS BC
                     ON SG.songID = BC.songID
                     WHERE SG.genre LIKE 'pop'        
                     GROUP BY BC.year),
     yearMaxes AS (SELECT A.year, MAX(A.cnt) AS maxs
                   FROM (SELECT BC.year, SG.genre, count(SG.genre) AS cnt
                         FROM SongGenre AS SG JOIN BillboardChart AS BC
                         ON SG.songID = BC.songID
                         GROUP BY SG.genre, BC.year) AS A
                   GROUP BY A.year)
SELECT popyrs.year, unemploymentRate
FROM EconomicHealth JOIN (  SELECT yearMaxes.year AS year
                            FROM popcntbyyr JOIN yearMaxes 
                            ON popcntbyyr.cnt = maxs AND popcntbyyr.year = yearMaxes.year) AS popyrs
WHERE EconomicHealth.year = popyrs.year


--13. What was the average ‘valence’ of the top 100 songs in years where the unemployment rate was above 4%, listed in increasing order?
WITH  vsongsbyyr AS (SELECT year, AVG(Song.valence) AS avgv
                    FROM BillboardChart JOIN Song
                    WHERE Song.id = BillboardChart.songID 
                    GROUP BY BillboardChart.year)
                    
SELECT yrs.year, avgv AS avgValence
FROM vsongsbyyr JOIN (SELECT year
                      FROM EconomicHealth
                      WHERE unemploymentRate > 4.0) AS yrs
WHERE vsongsbyyr.year = yrs.year
                    

--15. What was the percentage of songs listed as ‘explicit’ during years where gdp and S&P Roi both fell 
WITH  exsongs AS (SELECT year, COUNT(songID) AS exNum
                  FROM (SELECT Song.explicit, Song.id AS songID, year
                        FROM BillboardChart JOIN Song
                        WHERE Song.id = BillboardChart.songID) AS songs
                  WHERE explicit = 'TRUE'
                  GROUP BY year),
                  
      perbyyr AS (SELECT exsongs.year, (exNum/100) AS percent
                  FROM exsongs 
                  GROUP BY exsongs.year)
     
 SELECT yrs.year, COALESCE(percent, 0.0)  AS per 
 FROM perbyyr RIGHT JOIN (SELECT year
                          FROM EconomicHealth
                          WHERE realGdpPch < 0 AND snpRoi < 0) AS yrs
        ON perbyyr.year = yrs.year



--16. List the years where the most popular genre in the top 100 songs was some kind of rap
'TODO: would this double count songs with cateogories rap and atl rap'
WITH rapCntByYr AS  (SELECT BC.year, COUNT(SG.songID) AS cnt
                     FROM SongGenre AS SG JOIN BillboardChart AS BC
                     ON SG.songID = BC.songID
                     WHERE SG.genre LIKE '%rap%'        
                     GROUP BY BC.year),

     yearMaxes AS (SELECT A.year, MAX(A.cnt) AS maxs
                   FROM (SELECT BC.year, SG.genre, count(SG.genre) AS cnt
                         FROM SongGenre AS SG JOIN BillboardChart AS BC
                         ON SG.songID = BC.songID
                         GROUP BY SG.genre, BC.year)  AS A
                   GROUP BY A.year)
SELECT yearMaxes.year
FROM rapCntByYr JOIN yearMaxes 
        ON rapCntByYr.cnt = maxs AND rapCntByYr.year = yearMaxes.year


--17. For each year where unemployment decreased by more than 1%, what was the average  ‘liveliness’ of the top 100 songs released in January, vs those released in December?
--18. What was the average tempo of the top 100 songs of each decade, compared to the average tempo of the top 100 songs in the year with the highest unemployment rate in each decade? 
--19. What was the average ‘popularity’ of top songs with a tempo over 125, during years where the average unemployment rate was below 3%? 
WITH    yrs     AS (SELECT year
                    FROM EconomicHealth
                    WHERE unemploymentRate < 4.0)

SELECT year, AVG(popularity) AS popAvg
FROM Song JOIN (SELECT songID, yrs.year
                FROM BillboardChart JOIN yrs
                ON BillboardChart.year = yrs.year) AS yr
ON Song.id = yr.songID
WHERE tempo > 125
GROUP BY year;


--20. What was the average unemployment rate of years where the top song was labeled 'explicit'
WITH exyrs       AS (SELECT year
                    FROM Song JOIN BillboardChart
                    ON Song.id = BillboardChart.songID
                    WHERE BillboardChart.position = 1 AND Song.explicit = 'TRUE')
SELECT unemploymentRate
FROM exyrs JOIN EconomicHealth
ON exyrs.year = EconomicHealth.year



-- For each genre, for how many years was the top song in this genre? (exclude genres without any no. 1s)
WITH NumOneSongs AS (SELECT songId, year 
                     FROM BillboardChart 
                     WHERE position = 1)
SELECT genre, COUNT(year) AS numYearsTopSong
FROM NumOneSongs AS nos 
JOIN SongGenre as sg 
ON nos.songId = sg.songId
GROUP BY genre 
ORDER BY numYearsTopSong DESC



