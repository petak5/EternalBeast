//
//  Song.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 05/07/2021.
//

import Cocoa

@objc(Song)
public class Song: NSManagedObject, Identifiable {
    @NSManaged private (set) var filePath: String
    @NSManaged private (set) var title: String?
    @NSManaged private (set) var artist: String?
    @NSManaged private (set) var album: String?
    @NSManaged private (set) var year: String?
    @NSManaged private (set) var length: String?
    @NSManaged private (set) var trackNumber: NSNumber?
    @NSManaged private (set) var discNumber: NSNumber?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Song> {
        return NSFetchRequest<Song>(entityName: "Song")
    }

    public func loadMetadata(pathToFile: String) {
        self.filePath = pathToFile

        let metadata = MetadataLoader.loadMetadata(pathToFile: pathToFile)

        self.title = metadata.title
        self.artist = metadata.artist
        self.album = metadata.album
        self.year = metadata.year
        self.length = metadata.length
        self.trackNumber = NSNumber(value: metadata.trackNumber ?? 0)
        self.discNumber = NSNumber(value: metadata.discNumber ?? 0)
    }

    public func getPathToFile() -> String {
        return filePath
    }

    public func getDirectoryPath() -> String {
        return (filePath as NSString).deletingLastPathComponent
    }

    public func getFileName() -> String {
        return (filePath as NSString).lastPathComponent
    }

}
