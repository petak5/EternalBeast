//
//  ArtistsView.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 02/07/2021.
//

import SwiftUI

struct ArtistsView: View {
    @Environment(\.managedObjectContext)
    private var moc

    @Binding
    var selection: String?
    @State
    private var deleteConfirmationShown = false
    @State
    private var artistToDelete: Artist? = nil
    @EnvironmentObject
    private var library: Library
    @EnvironmentObject
    private var player: Player

    var body: some View {
        NavigationView {
            List(library.artists, id: \.name, selection: $selection) { artist in
                NavigationLink(destination: ArtistDetailView(artist: artist)) {
                    Text(artist.name)
                }
                .tag(artist.name)
                .contextMenu() {
                    Button("Play") {
                        var songs: [Song] = []
                        for album in artist.albums {
                            songs.append(contentsOf: album.songs)
                        }
                        player.playSongs(songs: songs)
                    }
                    Button("Delete") {
                        artistToDelete = artist
                        deleteConfirmationShown = true
                    }
                }
                .alert("Are you sure you want to delete the artist \"\(artistToDelete?.name ?? "")\" from library?", isPresented: $deleteConfirmationShown) {
                    Button("No", role: .cancel) { }
                    Button("Yes", role: .destructive) {
                        withAnimation {
                            if let artistToDelete = artistToDelete {
                                Library.shared.delete(artist: artistToDelete, moc: moc)
                            }
                            deleteConfirmationShown = false
                            artistToDelete = nil
                        }
                    }
                }
            }
        }
    }
}

//struct ArtistsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ArtistsView()
//    }
//}
