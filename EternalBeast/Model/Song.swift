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
    
    public init(directoryPath: String, fileName: String) {
        self.directoryPath = directoryPath
        self.fileName = fileName
    }
    
    public func getDirectoryPath() -> String {
        return directoryPath
    }
    
    public func getFileName() -> String {
        return fileName
    }

}
