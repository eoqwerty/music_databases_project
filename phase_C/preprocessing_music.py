#INPUT DATA: billboard_yearly.csv, hotStuff.csv,
#OUTPUT DATA: Song.txt, Genre.txt, SongGenre.txt, BillboardChart.txt

import pandas as pd 
import json 

#Helper functions!

# e.g., "Jay-Z featuring Beyonce" -> "Jay-Z"
def removeFeature(artistName):
  return artistName.split(' featuring')[0]

# get an array of genres from strings of the form "['pop', 'rap']"
def getGenreArrayFromString(str):
  try: 
    str = str.replace("'", '"')
    str = '{"genres":' + str + '}'
    obj = json.loads(str)
    return obj['genres']
  except Exception as e: #bad str 
    return []
  
#open source data
bb = pd.read_csv("billboard_yearly_FIXED.csv")
hotSpotify = pd.read_csv("hotSpotify.csv", encoding ='latin1')

#set up the dataframes for each of our relations 
Song = pd.DataFrame(columns = ['songId', 'title', 'artist', 'genres', 'key', 'tempo', 'explicit', 
'popularity', 'danceability', 'energy', 'acousticness', 'instrumentalness', 'liveness', 'valence'])
BillboardChart = pd.DataFrame(columns = ['songId', 'chartYear', 'chartPosition'], dtype = int)
Genre = pd.DataFrame(columns = ["genreName"]) 
SongGenre = pd.DataFrame(columns = ["songId", "genreName"])

#clean the billboard data
bb = bb.sort_values(by = ['title', 'artist', 'year']) #sort by song (useful for removing duplicates)
bb = bb.reset_index(drop=True) 
bb = bb.drop("Unnamed: 0",axis=1)

#LOG 
print("Building Song and BillboardChart from billboard data...")

#extract everything relevant from billboard data (Part of Song relation, all of BillboardChart relation)
curSongId = -1
curTitle = ""
curArtist = ""
for i, row in bb.iterrows():
  if((curTitle != row['title']) | (curArtist  != row['artist'])): 
    #new song!!
    curTitle, curArtist = row['title'], removeFeature(row['artist']) #EMI EDITED
    curSongId += 1 #get a new id for this song 
    new_song = {'songId': curSongId, 'title': curTitle, 'artist': curArtist} #strip artist name of "featuring ... " EMI EDITED
    Song = Song.append(new_song, ignore_index = True)
  #new song or not, we should associate this song with the chart   
  new_chart = {'songId': curSongId, 'chartYear': row['year'], 'chartPosition': row['number']}
  BillboardChart = BillboardChart.append(new_chart, ignore_index = True)

BillboardChart = BillboardChart.sort_values(by = ["chartYear"])
  
#LOG 
print("Matching Song with spotify data...")

#Match the songs in Song with songs in hotspotify, which contains additional metadata 
    #criteria for matching a song in the billboard data to one in spotify data:
    #exact matching titles, and artist in billboard is substring of Performer in spotify 
    #change this maybe?
Song['spotifyMatchFound'] = 0
for bbIndex, bbRow in Song.iterrows():
  name_matches = hotSpotify[hotSpotify['Song'] == bbRow['title']]
  for spotIndex, spotRow in name_matches.iterrows():
    if (bbRow['artist'] in spotRow['Performer']):
      Song.loc[bbIndex, 'spotifyMatchFound'] = 1
      Song.loc[bbIndex, 'genres'] = spotRow['spotify_genre']
      Song.loc[bbIndex, 'key'] = spotRow['key']
      Song.loc[bbIndex, 'tempo'] = spotRow['tempo']
      Song.loc[bbIndex, 'explicit'] = spotRow['spotify_track_explicit']
      Song.loc[bbIndex, 'popularity'] = spotRow['spotify_track_popularity']
      #special spotify characteristics 
      Song.loc[bbIndex, 'danceability'] = spotRow['danceability']
      Song.loc[bbIndex, 'energy'] = spotRow['energy']
      Song.loc[bbIndex, 'acousticness'] = spotRow['acousticness']
      Song.loc[bbIndex, 'instrumentalness'] = spotRow['instrumentalness']
      Song.loc[bbIndex, 'liveness'] = spotRow['liveness']
      Song.loc[bbIndex, 'valence'] = spotRow['valence']
      break
  
#LOG 
print("Building Genre and SongGenre from spotify data...")

#GENRES
  #parse the genres string 
  #associate Song and Genre using the SongGenre relation
Genre["relevant"] = 0;
songsWithGoodGenreString = 0;
Genre.set_index("genreName", inplace = True)
for index, song in Song[Song.spotifyMatchFound == 1].iterrows():
  genres = getGenreArrayFromString(song["genres"])
  if(len(genres) > 0):
    songsWithGoodGenreString += 1
  for genre in genres: 
    # remember this genre 
    new_genre = {"genreName": genre}
    Genre = Genre.append(new_genre, ignore_index = True)
    # record that this song is in this genre 
    new_song_genre = {'songId': song['songId'], 'genreName': genre }
    SongGenre = SongGenre.append(new_song_genre, ignore_index = True)
Genre.drop_duplicates(inplace = True, ignore_index = True)

#report statistics
spotifyMatchPercent = Song[Song.spotifyMatchFound == 1].shape[0] / Song.shape[0] * 100
genreParsePercent = songsWithGoodGenreString / Song[Song.spotifyMatchFound == 1].shape[0] * 100
print("%.1f%% of billboard songs have a spotify match, and %.1f%% of those had parseable genres"%(spotifyMatchPercent, genreParsePercent))

#remove temporary columns 
Song = Song.drop(columns = ["genres", "spotifyMatchFound"]) #should we keep spotify match found ? 
Genre = Genre.drop(columns = ["relevant"])

#final exports 
BillboardChart.to_csv("BillboardChart.txt", header = False, index = False, sep = '\t')
Song.to_csv("Song.txt", header = False, index = False, sep = '\t', float_format = "%.5f")
Genre.to_csv("Genre.txt", header = False, index = False, sep = '\t')
SongGenre.to_csv("SongGenre.txt", header = False, index = False, sep = '\t')








