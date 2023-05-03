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
    @State
    private var hoveredSong: Song? = nil
    @Binding
    var songSortDescriptors: [SortDescriptor<Song>]
    @EnvironmentObject
    var player: Player

    let artist: Artist
    var sortedAlbums: [Album] {
        artist.albums.sorted(using: .keyPath(\.year))
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(artist.name)
                .font(.title)
                .padding(.vertical, 10)

            // MARK: - Albums
            List(sortedAlbums, id: \.self, selection: $selectedSong) { album in
                Section(header: Text(album.name)) {
                    // MARK: - Songs
                    ForEach(album.songs.sorted(using: songSortDescriptors), id: \.self) { song in
                        ArtistDetailSongView(deleteConfirmationShown: $deleteConfirmationShown, songToDelete: $songToDelete, song: song, isHovered: hoveredSong == song, sortedAlbums: sortedAlbums, songSortDescriptors: $songSortDescriptors)
                            // TODO: find out why is .onHover disabling context menus in the view :/
                            .onHover { isHovered in
                                if isHovered {
                                    hoveredSong = song
                                } else {
                                    hoveredSong = nil
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
