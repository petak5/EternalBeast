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
    private (set) var title: String
    private (set) var artist: String
    private (set) var album: String
    private (set) var year: String
    private (set) var length: String
    private (set) var trackNumber: String
    
    public init(pathToFile: String) {
        self.pathToFile = pathToFile
        self.title = (pathToFile as NSString).lastPathComponent
        self.artist = "Unknown Artist"
        self.album = ((pathToFile as NSString).deletingLastPathComponent as NSString).lastPathComponent
        self.year = ""
        self.length = "0:00"
        self.trackNumber = ""
    }
    
    public func loadMetadata() {
        let fileUrl = URL(fileURLWithPath: pathToFile)
        let asset = AVAsset(url: fileUrl) as AVAsset
        
        // Get metadata
        for metaDataItem in asset.metadata {
            if metaDataItem.commonKey == .commonKeyTitle {
                title = metaDataItem.value as! String
            }
            if metaDataItem.commonKey == .commonKeyArtist {
                let artistString = metaDataItem.value as! String
                
                // Replace default value only if some value is provided
                if !artistString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    artist = artistString
                }
            }
            if metaDataItem.commonKey == .commonKeyAlbumName {
                album = metaDataItem.value as! String
            }
            if metaDataItem.commonKey == .id3MetadataKeyYear {
                year = metaDataItem.value as! String
            }
            if metaDataItem.commonKey == .id3MetadataKeyTrackNumber ||
                metaDataItem.commonKey == .iTunesMetadataKeyTrackNumber {
                trackNumber = metaDataItem.value as! String
            }
        }
        
        length = asset.duration.seconds.timeStringFromDouble()
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

}
