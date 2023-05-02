//
//  Library.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 02/05/2023.
//

import Foundation
import Cocoa

struct Artist: Hashable, Identifiable {
    public let id = UUID()
    public let name: String
    public var albums: [Album]
}

struct Album: Hashable {
    let name: String
    var songs: [Song]
}

class Library: ObservableObject {
    public static let shared = Library()

    @Published
    var artists: [Artist] = [Artist]()

    func addSong(song: Song) {
        // Artist index
        if let artistIndex = artists.firstIndex(where: { artist in artist.name == song.artist }) {
            // Album index
            if let albumIndex = artists[artistIndex].albums.firstIndex(where: { album in album.name == song.album }) {
                if !artists[artistIndex].albums[albumIndex].songs.contains(song) {
                    artists[artistIndex].albums[albumIndex].songs.append(song)
                }
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

    /// Load song from path and add it to the Library and DB
    func loadSong(filePath: String, moc: NSManagedObjectContext) {
        let song = Song(context: moc)
        song.loadMetadata(pathToFile: filePath)

        // Check if there isn't already htis song (avoid duplicating)
        if let artist = artists.first(where: {$0.name == song.artist}) {
            if let album = artist.albums.first(where: {$0.name == song.album}) {
                if let _ = album.songs.first(where: {$0.title == song.title}) {
                    return
                }
            }
        }

        do {
            try moc.save()
            Library.shared.addSong(song: song)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    /// Clear the whole library
    func clear(moc: NSManagedObjectContext) {
        for artist in Library.shared.artists {
            for album in artist.albums {
                for song in album.songs {
                    moc.delete(song)
                }
            }
        }

        do {
            try moc.save()
            artists = []
            Player.shared.stop()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}