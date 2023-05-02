//
//  SongsView.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 02/07/2021.
//

import SwiftUI

struct ArtistDetailView: View {
    @Environment(\.managedObjectContext)
    private var moc

    @State
    private var selectedSong: Song?
    @State
    private var deleteConfirmationShown = false
    @State
    private var songToDelete: Song? = nil
    @EnvironmentObject
    var player: Player

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
                        .contextMenu() {
                            Button("Play") {
                                player.playSong(song)
                            }
                            Button("Delete") {
                                songToDelete = song
                                deleteConfirmationShown = true
                            }
                        }
                    }
                    .alert("Are you sure you want to delete the song \"\(songToDelete?.title ?? "")\" from library?", isPresented: $deleteConfirmationShown) {
                        Button("No", role: .cancel) { }
                        Button("Yes", role: .destructive) {
                            withAnimation {
                                if let songToDelete = songToDelete {
                                    if songToDelete == player.currentSong {
                                        player.stop()
                                    }
                                    Library.shared.delete(song: songToDelete, moc: moc)
                                }
                                deleteConfirmationShown = false
                                songToDelete = nil
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
