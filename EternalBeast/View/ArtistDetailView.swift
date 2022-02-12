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

    let artist: Artist

    var body: some View {
        VStack {
            Text(artist.name)
                .font(.title)

            List(selection: $selectKeeper) {
                // MARK: - Albums
                ForEach(artist.albums, id: \.self) { album in
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
}

//struct SongsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SongsView()
//    }
//}
