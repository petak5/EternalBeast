//
//  Library.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 16/05/2021.
//

import Cocoa

final class Library {
    static let shared = Library()
    
    private var songs: [Song]
    
    private init() {
        songs = [Song]()
    }
    
    private func addFile(path: String) {
        let song = Song(fromPath: path)
        if let _song = song {
            songs.append(_song)
        }
    }
    
    private func addDirectory(directory: String) {
        let fileManager = FileManager.default
        
        do {
            let items = try fileManager.contentsOfDirectory(atPath: directory)
            
            for item in items {
                addFile(path: directory + "/" + item)
            }
        } catch let error {
            NSResponder().presentError(error)
            print("Failed to retreive contents of directory: '" + directory + "'")
        }
    }
    
    public func addSongs(fromPath path: String) {
        var isDir: ObjCBool = false
        
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
            if isDir.boolValue {
                addDirectory(directory: path)
            } else {
                addFile(path: path)
            }
        }
    }
    
    public func getSongs() -> [Song] {
        return songs
    }
}
