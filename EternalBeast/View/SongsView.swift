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

    @State
    private var sortOrder = [KeyPathComparator(\Song.title!)]
    @Binding
    var selection: Set<Song.ID>

    var body: some View {
        Table(of: Song.self, selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Title", value: \.title!) { song in
                Text(song.title ?? " ")
            }
            TableColumn("Album", value: \.album!) { song in
                Text(song.album ?? " ")
            }
            TableColumn("Artist", value: \.artist!) { song in
                Text(song.artist ?? " ")
            }
            TableColumn("Year", value: \.year!) { song in
                Text(song.year ?? " ")
            }
            TableColumn("Track", value: \.trackNumber!.intValue) { song in
                Text(song.trackNumber?.stringValue ?? " ")
            }
            TableColumn("Disc", value: \.discNumber!.intValue) { song in
                Text(song.discNumber?.stringValue ?? " ")
            }

        } rows: {
            ForEach(library.songs.sorted(using: sortOrder), id: \.self) { song in
                TableRow(song)
            }
        }
        .onChange(of: sortOrder) { newValue in
            sortOrder = newValue
            print(newValue.count)
            print(newValue.first!.keyPath)
            print(newValue.first!.order)
        }
    }
}
