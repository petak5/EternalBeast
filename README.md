# Eternal Beast - simple music player

GitHub: https://github.com/petak5/EternalBeast

<img src="https://github.com/petak5/EternalBeast/blob/master/screenshot.png?raw=true">

## How to use:
  1. Add songs to library by navigating to `File->Add To Library...` or pressing `Cmd+O` and select files or directories that you want to add (the files must be located in `~/Music` folder otherwise you won't be able to play them on the next app laucnh because of App Sandbox)
  2. Select an Artist on the left side and *double* click on a song from list on the right side (alternatively you can *right* click on a song and select `Play`)
  3. Enjoy listening to music :)

## Features:
  - Now Playing system menu integration
  - Repeat all, repat one and stop after this song modes (works only on macOS 11.0 and higher)

## Limitations:
  - Files must be located in users music foler (`~/Music`) to allow the application to read them after restart. This is because of App Sandbox allows to read only user selected files or files from the music folder.
  - *Play previous song* action is not supported
  - Files without metadata will show alternate info
    - for example songs without album name use dictionary name as the album name and file name as the song tile
  - Loading many files at once can consume lot of memory, even GBs. There is some reference counting problem with `AVAsset` and its `.metadata` property that stops it from dealocating until all songs are added. A simple demo project showing this behaviour can be found at https://github.com/petak5/MemoryNotFreeing-macOS
