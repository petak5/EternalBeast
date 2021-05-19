//
//  Song.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 16/05/2021.
//

import Cocoa

class Song {
    private let pathToFile: String
    private let title: String
    private let artist: String
    private let album: String
    
    public init(pathToFile: String) {
        self.pathToFile = pathToFile
        self.title = (pathToFile as NSString).lastPathComponent
        self.artist = "Unknown Artist"
        self.album = (pathToFile as NSString).deletingLastPathComponent
    }
    
    public func getPathToFile() -> String {
        return pathToFile
    }
    
    public func getDirectoryPath() -> String {
        return (pathToFile as NSString).deletingLastPathComponent
    }
    
    public func getFileName() -> String {
        return (pathToFile as NSString).lastPathComponent
    }
    
    public func getTitle() -> String {
        return title
    }
    
    public func getArtistName() -> String {
        return artist
    }
    
    public func getAlbumName() -> String {
        return album
    }

}
