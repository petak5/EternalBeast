//
//  Tools.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 06/12/2023.
//

import Foundation

public class Tools {
    /// Recursively find all songs at given path (the path can be a signle song file)
    /// - Parameter paths: Paths to search for song in
    /// - Parameter allowedFileTypes: List of allowed file type extensions
    /// - Returns: List of song urls
    static func findSongURLs(in paths: [URL], allowedFileTypes: [String]) -> [URL] {
        var songURLs: [URL] = []

        for path in paths {
            do {
                var isDirectory: ObjCBool = false
                if FileManager.default.fileExists(atPath: path.path, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        // Recursively search in subdirectories
                        let newPaths = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                        let subdirectoryMP3Files = findSongURLs(in: newPaths, allowedFileTypes: allowedFileTypes)
                        songURLs.append(contentsOf: subdirectoryMP3Files)
                    } else {
                        // Check if the file has one of allowed extensions
                        if allowedFileTypes.contains(path.pathExtension.lowercased()) {
                            songURLs.append(path)
                        }
                    }
                }
            } catch {
                print("Error in findingSongURLs: \(error)")
            }
        }

        return songURLs
    }
}
