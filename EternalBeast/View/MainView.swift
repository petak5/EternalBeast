//
//  ContentView.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 02/07/2021.
//

import SwiftUI
import CoreData

enum NavigationItem {
    case Artists
    case Albums
    case Songs
}

struct MainView: View {
    @Environment(\.managedObjectContext)
    private var viewContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Song.title, ascending: true),
            NSSortDescriptor(keyPath: \Song.artist, ascending: true)
        ],
        animation: .default)
    private var songs: FetchedResults<Song>

    @State
    var library = Library.shared
    @StateObject
    var player = Player.shared

    @State
    var selection: NavigationItem? = .Artists
    @State
    var selectedArtist: String? = nil

    var body: some View {
        NavigationView {
            List(selection: $selection) {
                Section(header: Text("Library")) {
                    NavigationLink(destination: ArtistsView(selection: $selectedArtist)) {
                        Label("Artists", systemImage: "music.mic")
                    }
                    .tag(NavigationItem.Artists)

                    NavigationLink(destination: Text("List of albums...")) {
                        Label("Albums", systemImage: "square.stack")
                    }
                    .tag(NavigationItem.Albums)

                    NavigationLink(destination: Text("List of all songs")) {
                        Label("Songs", systemImage: "music.note")
                    }
                    .tag(NavigationItem.Songs)
                }
                .collapsible(false)

//                Section(header: Text("Playlists"), footer: Text("asdf")) {
//                    NavigationLink(destination: Text("Songs of playlist 1")) {
//                        Label("Playlist 1", systemImage: "music.note.list")
//                    }
//                    NavigationLink(destination: Text("Songs of playlist 2")) {
//                        Label("Playlist 2", systemImage: "music.note.list")
//                    }
//                }
            }
            .listStyle(SidebarListStyle())
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                }
            }
            ToolbarItem(placement: .principal) {
                MediaControlsView()
            }
        }
        .environmentObject(player)
        .environmentObject(library)
        .onAppear {
            for song in songs {
                library.addSong(song: song)
            }
        }
        .frame(minWidth: 800)
    }

    func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
