//
//  LibraryArtistsViewController.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 02/05/2021.
//

import Cocoa

class ArtistsViewController: NSViewController {
    
    @IBOutlet weak var artistsTableView: NSTableView!
    @IBOutlet weak var songsTableView: NSTableView!
    
    private var artists = [String: [Song]]()
    private var displayedArtists = [String]()
    private var displayedSongs = [Song]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        artistsTableView.delegate = self
        artistsTableView.dataSource = self
        
        songsTableView.delegate = self
        songsTableView.dataSource = self
    }
    
    func add() -> [String] {
        let dialog = NSOpenPanel();
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseFiles          = true;
        dialog.canChooseDirectories    = true;
        dialog.allowsMultipleSelection = true;

        var paths = [String]()
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.urls
            
            for path in result {
                paths.append(path.path)
            }
            
            return paths
        } else {
            // User clicked on "Cancel"
            return paths
        }
    }
    
    @IBAction func addToLibrary(_ sender: Any) {
        let paths = add()
        
        for path in paths {
            addSongs(fromPath: path)
        }
        
        displayedArtists = Array(artists.keys)
        
        artistsTableView.reloadData()
        songsTableView.reloadData()
    }
    
    private func addFile(path: String) {
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: path) || !fileManager.isReadableFile(atPath: path) {
            print("File '\(path)' does not exist or is not readable.")
            return
        }
        
        let song = Song(pathToFile: path)
        
        // Create artist if not found
        if !artists.contains(where: {k, v in k == song.getArtistName()}) {
            artists[song.getArtistName()] = []
        }
        // Add song to artist
        artists[song.getArtistName()]?.append(song)
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
    
}

// MARK: - TableView Extensions

extension ArtistsViewController: NSTableViewDelegate, NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == artistsTableView {
            return displayedArtists.count
        } else if tableView == songsTableView {
            let row = artistsTableView.selectedRow
            
            // No row selected
            if row == -1 {
                return 0
            } else {
                return displayedSongs.count
            }
        } else {
            return 0
        }
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellName = ""
        var text = ""
        
        if tableView == artistsTableView {
            cellName = "artistCell"
            text = displayedArtists[row]
        } else if tableView == songsTableView {
            cellName = "songCell"
            
            let artistSelectedRow = artistsTableView.selectedRow
            
            // No row selected
            if artistSelectedRow == -1 {
                return nil
            } else {
                text = displayedSongs[row].getTitle()
            }
        } else {
            return nil
        }
        
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellName), owner: self) as! NSTableCellView
        cell.textField!.stringValue = text

        return cell
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        var value: CGFloat = 0
        
        if tableView == artistsTableView {
            value = 52
        } else if tableView == songsTableView {
            value = 32
        }
        
        return value
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let tableView = notification.object as? NSTableView
        
        guard let _tableView = tableView else { return }
        if _tableView == artistsTableView {
            // Get selected artist row
            let artistRow = artistsTableView.selectedRow
            
            if artistRow == -1 {
                // Do nothing
            } else {
                let artistName = displayedArtists[artistRow]
                let newDisplayedSongs = artists[artistName]
                guard let newDisplayedSongs = newDisplayedSongs else { return }
                
                displayedSongs = newDisplayedSongs
                // Sort by title
                displayedSongs.sort {$0.getTitle() < $1.getTitle()}
                // Sort by album
                displayedSongs.sort {$0.getAlbumName() < $1.getAlbumName()}
                
                songsTableView.reloadData()
            }
        }
    }
}
