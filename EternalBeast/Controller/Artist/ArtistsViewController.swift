//
//  LibraryArtistsViewController.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 02/05/2021.
//

import Cocoa

class ArtistsViewController: NSSplitViewController {

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
    
    func showItems(title: String, items: [String]) {
        //self.items.append(title)
    }
    
    
    public func openFolder(withPath path: String) {
        let fileManager = FileManager.default
        
        do {
            let items = try fileManager.contentsOfDirectory(atPath: path)
            
            showItems(title: path, items: items)
        } catch let error {
            NSResponder().presentError(error)
            print("Failed to retreive contents of directory: '" + path + "'")
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func add() -> String? {
        let dialog = NSOpenPanel();
            
        dialog.title                   = "Choose a directory";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseFiles          = false;
        dialog.canChooseDirectories    = true;
        dialog.allowsMultipleSelection = false;

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url
            
            if let _result = result {
                let path = _result.path
                print(path)
                
                return path
            } else {
                return nil
            }
        } else {
            // User clicked on "Cancel"
            return nil
        }
    }

    @IBAction func addToLibrary(_ sender: Any) {
        let path = add()
        if let _path = path {
            openFolder(withPath: _path)
            library.addSongs(fromPath: _path)
            
            artistsTableView.reloadData()
            songsTableView.reloadData()
        }
    }
    
}

// MARK: - TableView Extensions

extension ArtistsViewController: NSTableViewDelegate, NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return library.getSongs().count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellName = ""
        var text = ""
        
        if tableView == artistsTableView {
            cellName = "artistCell"
            text = library.getSongs()[row].getDirectoryPath()
        } else if tableView == songsTableView {
            cellName = "songCell"
            text = library.getSongs()[row].getFileName()
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
}
