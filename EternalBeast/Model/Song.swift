//
//  Song.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 16/05/2021.
//

import Cocoa
import AVFoundation

class Song {
    private let pathToFile: String
    private var title: String
    private var artist: String
    private var album: String
    private var year: Int
    
    public init(pathToFile: String) {
        self.pathToFile = pathToFile
        self.title = (pathToFile as NSString).lastPathComponent
        self.artist = "Unknown Artist"
        self.album = (pathToFile as NSString).deletingLastPathComponent
        self.year = 1970
        
        retrieveMetadata()
    }
    
    private func retrieveMetadata() {
        let fileUrl = URL(fileURLWithPath: pathToFile)
        let asset = AVAsset(url: fileUrl) as AVAsset
        
        // Get metadata
        for metaDataItems in asset.commonMetadata {
            if metaDataItems.commonKey == .commonKeyTitle {
                let titleData = metaDataItems.value as! NSString
                title = String(titleData)
            }
            if metaDataItems.commonKey == .commonKeyArtist {
                let artistData = metaDataItems.value as! NSString
                artist = String(artistData)
            }
            if metaDataItems.commonKey == .commonKeyAlbumName {
                let albumNameData = metaDataItems.value as! NSString
                album = String(albumNameData)
            }
        }
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
