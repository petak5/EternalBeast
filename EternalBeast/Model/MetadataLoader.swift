//
//  MetadataHandler.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 11/07/2021.
//

import Foundation
import AVFoundation
import Cocoa

struct Metadata {
    var pathToFile: String
    var title: String?
    var artist: String?
    var album: String?
    var year: String?
    var length: String?
    var trackNumber: Int?
    var discNumber: Int?
}

struct MetadataLoader {
    public static func loadMetadata(pathToFile: String) -> Metadata {
        var metadata: Metadata

        // Default values
        metadata = Metadata(pathToFile: pathToFile)
        metadata.title = (pathToFile as NSString).lastPathComponent
        metadata.artist = "Unknown Artist"
        metadata.album = ((pathToFile as NSString).deletingLastPathComponent as NSString).lastPathComponent
        metadata.year = ""
        metadata.length = "0"
        metadata.trackNumber = 0
        metadata.discNumber = 0

        let fileUrl = URL(fileURLWithPath: pathToFile)
        let asset = AVAsset(url: fileUrl) as AVAsset

        // Get metadata
        for metaDataItem in asset.metadata {
            if metaDataItem.commonKey == .commonKeyTitle {
                metadata.title = metaDataItem.value as? String
            }
            if metaDataItem.commonKey == .commonKeyArtist {
                let artistString = metaDataItem.value as! String

                // Replace default value only if some value is provided
                if !artistString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    metadata.artist = artistString
                }
            }
            if metaDataItem.commonKey == .commonKeyAlbumName {
                metadata.album = metaDataItem.value as? String
            }

            // MARK: ID3 metadata
            if metaDataItem.keySpace == .id3, let key = metaDataItem.key {
                // Track number
                if key.description == "TRCK" {
                    let values = metaDataItem.stringValue!.split(separator: "/")
                    metadata.trackNumber = Int(String(values[0])) ?? 0
                // Part of a set (number of CD disc, etc.)
                } else if key.description == "TPOS" {
                    let values = metaDataItem.stringValue!.split(separator: "/")
                    metadata.discNumber = Int(String(values[0])) ?? 0
                // Year
                } else if key.description == "TYER" {
                    metadata.year = metaDataItem.stringValue ?? ""
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

                    metadata.year = year

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
                    metadata.trackNumber = Int(trackNumber)

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
                    metadata.discNumber = Int(discNumber)
                }
            }
        }

        //length = asset.duration.seconds.timeStringFromDouble()

        return metadata
    }

    public static func getSongArtwork(song: Song) -> NSImage? {
        let fileUrl = URL(fileURLWithPath: song.getPathToFile())
        let asset = AVAsset(url: fileUrl) as AVAsset

        var artwork: NSImage?
        // Get metadata
        for metaDataItem in asset.metadata {
            // If metadata item is artwork, create image and save it to variable
            if metaDataItem.commonKey == .commonKeyArtwork {
                if let data = metaDataItem.dataValue,
                let image = NSImage(data: data) {
                    artwork = image
                }
            }
        }

        return artwork
    }
}
