# Your Pitch -- daily_spotify

An app that recommends a curated and customizable daily song and stores the song in a calendar.

## How does it work?

The app is built with flutter to help speed up the process of developing a cross platform app.

The app utilizes Spotify's Web API to collect information on the user and uses this information to find a song to recommend.
To communicate with Spotify's WEB API I created my own API wrapper.

All data is stored in a local database with the help of hive db.
