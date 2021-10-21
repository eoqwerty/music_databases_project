#INPUT DATA: billboard_yearly.csv, hotStuff.csv
#OUTPUT DATA: Song.txt, Genre.txt, SongGenre.txt, BillboardChart.txt

def removeFeature(artistName):
  return artistName.split(' featuring')[0]

    
import pandas as pd 
bb = pd.read_csv("sourceData/billboard_yearly.csv")
spotifySongs = pd.read_csv("sourceData/spotify_songs.csv", encoding ='latin1') 

#Set up the dataframes for each of our relations 
Song = pd.DataFrame(columns = ['songId', 'title', 'artist', 'spotifyMatchFound', 'key', 'tempo', 
'danceability', 'energy', 'acousticness', 'instrumentalness', 'liveness', 'valence'], dtype = int)
BillboardChart = pd.DataFrame(columns = ['songId', 'chartYear', 'chartPosition'], dtype = int)
Genre = pd.read_csv("sourceData/spotify_genre_list.txt") #might modify this a little 
SongGenre = pd.DataFrame()


#CLEAN THE BILLBOARD DATA
bb = bb.sort_values(by = ['title', 'artist', 'year']) #sort by song (useful for removing duplicates)
bb = bb.reset_index(drop=True) 
bb = bb.drop("Unnamed: 0",axis=1)

#extract everything relevant from bb (Part of Song relation, all of BillboardChart relation)
curSongId = -1
curTitle = ""
curArtist = ""
for i, row in bb.iterrows():
  if((curTitle != row['title']) | (curArtist  != row['artist'])): 
    #new song!! 
    curTitle, curArtist = row['title'], row['artist']
    curSongId += 1 #get a new id for this song 
    new_song = {'songId': curSongId, 'title': curTitle, 'artist': removeFeature(curArtist)} #strip artist name of "featuring ... "
    Song = Song.append(new_song, ignore_index = True)
  #new song or not, we should associate this song with the chart   
  new_chart = {'songId': curSongId, 'chartYear': row['year'], 'chartPosition': row['number']}
  BillboardChart = BillboardChart.append(new_chart, ignore_index = True)


#criteria for matching a song in the billboard data to one in spotify data:
#exact matching titles, and artist in billboard is substring of Performer in spotify 
#change this maybe?

#Song = Song.sample(10) #TEMPORARILY make Song much smaller 

Song['spotifyMatchFound'] = 0
for bbIndex, bbRow in Song.iterrows():
  print(bbRow['title'])
  name_matches = spotifySongs[spotifySongs['name'] == bbRow['title']]
  for spotIndex, spotRow in name_matches.iterrows():
    if (bbRow['artist'] in spotRow['artists']):
      print("match found!")
      Song.loc[bbIndex, 'spotifyMatchFound'] = 1
      #Song.loc[bbIndex, 'genres'] = spotRow['spotify_genre']
      Song.loc[bbIndex, 'key'] = spotRow['key']
      Song.loc[bbIndex, 'tempo'] = spotRow['tempo']
      #special spotify characteristics 
      Song.loc[bbIndex, 'danceability'] = spotRow['danceability']
      Song.loc[bbIndex, 'energy'] = spotRow['energy']
      Song.loc[bbIndex, 'acousticness'] = spotRow['acousticness']
      Song.loc[bbIndex, 'instrumentalness'] = spotRow['instrumentalness']
      Song.loc[bbIndex, 'liveness'] = spotRow['liveness']
      Song.loc[bbIndex, 'valence'] = spotRow['valence']
      break
  

#TODO -> GENRES -> maybe delete genres that dont have any songs in our dataset?
print("these r the songs")
print(Song)
BillboardChart = BillboardChart.sort_values(by = ["chartYear"])
  
BillboardChart.to_csv("BillboardChart.txt", header = False, index = False)
Song.to_csv("Song.txt", header = False, index = False)
Genre.to_csv("Genre.txt", header = False, index = False)
SongGenre.to_csv("SongGenre.txt", header = False, index = False)
