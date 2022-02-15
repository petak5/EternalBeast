//
//  SongsView.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 02/07/2021.
//

import SwiftUI

struct ArtistDetailView: View {
    @State private var selectedSong: Song?
    @State var player = Player.shared

    let artist: Artist

    var body: some View {
        VStack {
            Text(artist.name)
                .font(.title)

            // MARK: - Albums
            List(artist.albums, id: \.self, selection: $selectedSong) { album in
                Section(header: Text(album.name)) {
                    // MARK: - Songs
                    ForEach(album.songs, id: \.self) { song in
                        HStack {
                            Button(action: {
                                player.playSong(song)
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
