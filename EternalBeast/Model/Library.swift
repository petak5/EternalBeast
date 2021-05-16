//
//  Library.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 16/05/2021.
//

import Cocoa

final class Library {
    static let shared = Library()
    
    private var songs: [String: [Song]]
    
    private init() {
        songs = [String: [Song]]()
    }
    
    private func addFile(path: String) {
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: path) || !fileManager.isReadableFile(atPath: path) {
            print("File '\(path)' does not exist or is not readable.")
            return
        }
        
        let fileName = (path as NSString).lastPathComponent
        let directoryPath = (path as NSString).deletingLastPathComponent
        
        let song = Song(directoryPath: directoryPath, fileName: fileName)
        
        if songs[directoryPath] == nil {
            songs[directoryPath] = [song]
        } else {
            songs[directoryPath]?.append(song)
        }
    }
    
    private func addFilesFromDirectory(directory: String) {
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
                addFilesFromDirectory(directory: path)
            } else {
                addFile(path: path)
            }
        }
    }
    
    public func getDirectories() -> [String] {
        return Array(songs.keys)
    }
    
    public func getSongs(fromDirectory directory: String) -> [Song]? {
        return songs[directory]
    }
}
