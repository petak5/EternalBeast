//
//  Song.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 16/05/2021.
//

import Cocoa

struct Song {
    private var directoryPath: String
    private var fileName: String
    
    public init?(fromPath path: String) {
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: path) || !fileManager.isReadableFile(atPath: path) {
            print("File '\(path)' does not exist or is not readable.")
            return nil
        }
        
        fileName = (path as NSString).lastPathComponent
        directoryPath = (path as NSString).deletingLastPathComponent
//        fileName = fileManager.displayName(atPath: path)
    }
    
    public func getDirectoryPath() -> String {
        return directoryPath
    }
    
    public func getFileName() -> String {
        return fileName
    }

}
