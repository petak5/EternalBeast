# Eternal Beast - simple music player

GitHub: https://github.com/petak5/EternalBeast

How to use:
  1. Add songs to library by navigating to `File->Add To Library...` or pressing `Cmd+O` and select files or directories that you want to add (the files must be located in `~/Music` folder otherwise you won't be able to play them on the next app laucnh because of App Sandbox)
  2. Select an Artist on the left side and *double* click on a song from list on the right side (alternatively you can *right* click on a song and select `Play`)
  3. Enjoy listening to music :)

Features:
  - Now Playing system menu integration

Limitations:
  - *Play previous song* action is not supported
  - Loading many files at once can consume lot of memory, even GBs. There is some reference counting problem with `AVAsset` and its `.metadata` property that stops it from dealocating until all songs are added.