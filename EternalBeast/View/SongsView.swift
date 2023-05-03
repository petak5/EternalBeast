//
//  SongsView.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 03/05/2023.
//

import Foundation
import SwiftUI

struct SongsView: View {
    @EnvironmentObject
    var library: Library
    @EnvironmentObject
    var player: Player

    @Binding
    var sortOrder: [KeyPathComparator<Song>]
    @Binding
    var selection: Set<Song.ID>

    var body: some View {
        Table(of: Song.self, selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Title", value: \.title!) { song in
                Text(song.title ?? " ")
                    .bold(song == player.currentSong)
                    .help(song.title ?? " ")
            }
            TableColumn("Album", value: \.album!) { song in
                Text(song.album ?? " ")
                    .bold(song == player.currentSong)
                    .help(song.album ?? " ")
            }
            TableColumn("Artist", value: \.artist!) { song in
                Text(song.artist ?? " ")
                    .bold(song == player.currentSong)
                    .help(song.artist ?? " ")
            }
            TableColumn("Year", value: \.year!) { song in
                Text(song.year ?? " ")
                    .bold(song == player.currentSong)
                    .help(song.year ?? " ")
            }
            TableColumn("Track", value: \.trackNumber!.intValue) { song in
                Text(song.trackNumber?.stringValue ?? " ")
                    .bold(song == player.currentSong)
                    .help(song.trackNumber?.stringValue ?? " ")
            }
            TableColumn("Disc", value: \.discNumber!.intValue) { song in
                Text(song.discNumber?.stringValue ?? " ")
                    .bold(song == player.currentSong)
                    .help(song.discNumber?.stringValue ?? " ")
            }
            TableColumn("File", value: \.filePath) { song in
                Text(song.filePath)
                    .bold(song == player.currentSong)
                    .help(song.filePath)
            }
        } rows: {
            ForEach(library.songs.sorted(using: sortOrder), id: \.self) { song in
                TableRow(song)
                    .contextMenu {
                        Button("Play This") {
                            player.playSong(song)
                            player.playSongs(songs: library.songs.sorted(using: sortOrder), from: song)
                        }
                        Button("Play Selected") {
                            let songs = library.songs.filter({ selection.contains($0.id) })
                            player.playSongs(songs: songs.sorted(using: sortOrder))
                        }
                        Button("Play All") {
                            player.playSongs(songs: library.songs.sorted(using: sortOrder))
                        }
                    }
            }
        }
        .onChange(of: sortOrder) { newValue in
            sortOrder = newValue
        }
    }
}
