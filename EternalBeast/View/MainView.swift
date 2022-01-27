//
//  ContentView.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 02/07/2021.
//

import SwiftUI
import CoreData

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Song.title, ascending: true),
            NSSortDescriptor(keyPath: \Song.artist, ascending: true)
        ],
        animation: .default)
    private var songs: FetchedResults<Song>

    //@State var artists: [Artist] = [Artist]()
    @State var library = Library.shared

    var body: some View {
        NavigationView {
            List {
                NavigationLink("Artists") {
                    ArtistsView(artists: library.artists)
                }
                NavigationLink("Albums") {
                    Text("List of albums...")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                }
            }
        }
        .onAppear {
//            addSongs()
//            deleteAllSongs()

            for song in songs {
                library.addSong(song: song)
            }
        }
    }

    func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }

    func addSongs() {
        let filePath = "/Users/peter/Desktop/Music/Unleash the Archers/2015 - Time Stands Still/04 - Tonight We Ride.mp3"

        let s = Song(context: viewContext)
        s.loadMetadata(pathToFile: filePath)

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    func deleteAllSongs() {
        for song in songs {
            viewContext.delete(song)
        }

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct Artist: Hashable {
    let name: String
    var albums: [Album]
}

struct Album: Hashable {
    let name: String
    var songs: [Song]
}

struct Library {
    public static let shared = Library()

    var artists: [Artist] = [Artist]()

    mutating func addSong(song: Song) {
        // Artist index
        if let artistIndex = artists.firstIndex(where: { artist in artist.name == song.artist }) {
            // Album index
            if let albumIndex = artists[artistIndex].albums.firstIndex(where: { album in album.name == song.album }) {
                artists[artistIndex].albums[albumIndex].songs.append(song)
            } else {
                let album = Album(name: song.album ?? "Unknown", songs: [song])
                artists[artistIndex].albums.append(album)
            }
        } else {
            let album = Album(name: song.album ?? "Unknown", songs: [song])
            let artist = Artist(name: song.artist ?? "Unknown", albums: [album])
            artists.append(artist)
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
