//
//  Song.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 16/05/2021.
//

import Cocoa
import AVFoundation

@objc(Song)
public class Song: NSManagedObject, Identifiable {
    @NSManaged private var pathToFile: String
    @NSManaged private (set) var title: String
    @NSManaged private (set) var artist: String
    @NSManaged private (set) var album: String
    @NSManaged private (set) var year: String
    @NSManaged private (set) var length: String
    @NSManaged private (set) var trackNumber: String
    @NSManaged private (set) var discNumber: String
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Song> {
        return NSFetchRequest<Song>(entityName: "Song")
    }
    
    public func loadMetadata(pathToFile: String) {
        
        // Default values
        self.pathToFile = pathToFile
        self.title = (pathToFile as NSString).lastPathComponent
        self.artist = "Unknown Artist"
        self.album = ((pathToFile as NSString).deletingLastPathComponent as NSString).lastPathComponent
        self.year = ""
        self.length = "0:00"
        self.trackNumber = ""
        self.discNumber = ""
        
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

            // MARK: ID3 metadata
            if metaDataItem.keySpace == .id3, let key = metaDataItem.key {
                // Track number
                if key.description == "TRCK" {
                    let values = metaDataItem.stringValue!.split(separator: "/")
                    trackNumber = String(values[0])
                // Part of a set (number of CD disc, etc.)
                } else if key.description == "TPOS" {
                    let values = metaDataItem.stringValue!.split(separator: "/")
                    discNumber = String(values[0])
                // Year
                } else if key.description == "TYER" {
                    year = metaDataItem.stringValue ?? ""
                }
            }
            
            // MARK: iTunes metadata (ALAC in .m4a files)
            if metaDataItem.keySpace == .iTunes {
                // Year
                if metaDataItem.identifier == .iTunesMetadataReleaseDate {
                    let releaseDate = metaDataItem.stringValue!
                    // Get year from yyyy-mm-dd format
                    let dateSplitted = releaseDate.split(separator: "-")
                    let year = String(dateSplitted[0])
                    
                    self.year = year
                    
                // Track number
                } else if metaDataItem.identifier == .iTunesMetadataTrackNumber {
                    // Oh boy, where to begin...
                    // Data of this metadata item is 8 bytes long but only 2 bytes represent the track number
                    // The 2 bytes are also offset by 2 bytes
                    
                    let trackNumberData = metaDataItem.dataValue!
                    // Convert the data to 64 bit unsigned integer (8 bytes)
                    let num: UInt64 = trackNumberData.withUnsafeBytes { $0.load(as: UInt64.self) }
                    // Split the number into bytes
                    let dataBytes = withUnsafeBytes(of: num.littleEndian) {
                        Array($0)
                    }
                    
                    // Fisrt and second bytes representing the track number (offset by 2)
                    let firstByte: UInt8 = dataBytes[2]
                    let secondByte: UInt8 = dataBytes[3]
                    // Track number is 16 bit unsigned int (2 * 1 byte)
                    // Assign first byte and shift it to it's position
                    var trackNumber: UInt16 = UInt16(firstByte)
                    trackNumber = trackNumber << 8
                    // Add second byte
                    trackNumber += UInt16(secondByte)
                    
                    // Here the track number should be correctly extracted from the data
                    self.trackNumber = String(trackNumber)
                    
                // Disc number
                } else if metaDataItem.identifier == .iTunesMetadataDiscNumber {
                    // Oh boy, where to begin...
                    // Data of this metadata item is 6 bytes long but only 2 bytes represent the disc number
                    // The 2 bytes are also offset by 2 bytes
                    
                    let discNumberData = metaDataItem.dataValue!
                    // Convert the data to 32 bit unsigned integer (4 bytes)
                    let num: UInt32 = discNumberData.withUnsafeBytes { $0.load(as: UInt32.self) }
                    // Split the number into bytes
                    let dataBytes = withUnsafeBytes(of: num.littleEndian) {
                        Array($0)
                    }
                    
                    // Fisrt and second bytes representing the disc number (offset by 2)
                    let firstByte: UInt8 = dataBytes[2]
                    let secondByte: UInt8 = dataBytes[3]
                    // Disc number is 16 bit unsigned int (2 * 1 byte)
                    // Assign first byte and shift it to it's position
                    var discNumber: UInt16 = UInt16(firstByte)
                    discNumber = discNumber << 8
                    // Add second byte
                    discNumber += UInt16(secondByte)
                    
                    // Here the disc number should be correctly extracted from the data
                    self.discNumber = String(discNumber)
                }
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
