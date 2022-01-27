//
//  SongsView.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 02/07/2021.
//

import SwiftUI

struct ArtistDetailView: View {
    @State var selectKeeper = Set<String>()
    @State var player = Player.shared

    let albums: [Album]

    var body: some View {
        List(selection: $selectKeeper) {
            // MARK: - Albums
            ForEach(albums, id: \.self) { album in
                Section(header: Text(album.name)) {
                    // MARK: - Songs
                    ForEach(album.songs, id: \.self) { song in
                        HStack {
                            Button(action: {
                                player.stop()
                                player.clearQueue()
                                player.addToQueue(song: song)
                                player.play()
                            }, label: {
                                Image(systemName: "play.fill")
                            })
                            Text(song.title ?? "")
                        }
                    }
                }
            }
        }
    }
}

//struct SongsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SongsView()
//    }
//}
