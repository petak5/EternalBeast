//
//  LibraryArtistsViewController.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 02/05/2021.
//

import Cocoa

class ArtistsViewController: NSViewController {

    private var library = Library.shared
    
    @IBOutlet weak var artistsTableView: NSTableView!
    @IBOutlet weak var songsTableView: NSTableView!
    
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
            library.addSongs(fromPath: path)
        }
        
        artistsTableView.reloadData()
        songsTableView.reloadData()
    }
    
}

// MARK: - TableView Extensions

extension ArtistsViewController: NSTableViewDelegate, NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == artistsTableView {
            return library.getDirectories().count
        } else if tableView == songsTableView {
            let row = artistsTableView.selectedRow
            
            // No row selected
            if row == -1 {
                return 0
            } else {
                let directories = library.getDirectories()
                
                // Index out of bounds
                if row > directories.count {
                    return 0
                }
                
                let songs = library.getSongs(fromDirectory: directories[row])
                if let _songs = songs {
                    return _songs.count
                } else {
                    return 0
                }
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
            text = library.getDirectories()[row]
        } else if tableView == songsTableView {
            cellName = "songCell"
            
            let directorySelectedRow = artistsTableView.selectedRow
            
            // No row selected
            if directorySelectedRow == -1 {
                return nil
            } else {
                let directories = library.getDirectories()
                
                // Index out of bounds
                if directorySelectedRow > directories.count {
                    return nil
                }
                
                let songs = library.getSongs(fromDirectory: directories[directorySelectedRow])
                if let _songs = songs {
                    text = _songs[row].getFileName()
                } else {
                    return nil
                }
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
        if let _tableView = tableView {
            if _tableView == artistsTableView {
                songsTableView.reloadData()
            }
        }
    }
}
