//
//  LibraryArtistsViewController.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 02/05/2021.
//

import Cocoa

struct SongItem {
    var song: Song?
    var album: String
    var isGroup: Bool
    
    init(song: Song?, album: String = "") {
        self.song = song
        self.album = album
        self.isGroup = !self.album.isEmpty
    }
}

class MainViewController: NSViewController {
    
    @IBOutlet weak var artistsTableView: NSTableView!
    @IBOutlet weak var songsTableView: NSTableView!
    
    
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var repeatButton: NSButton!
    @IBOutlet weak var coverArtImage: NSImageView!
    @IBOutlet weak var songNameLabel: NSTextField!
    @IBOutlet weak var progressLabel: NSTextField!
    @IBOutlet weak var playbackSlider: NSSlider!
    
    // [Artist name : Songs]
    private var artists = [String: [Song]]()
    private var displayedArtists = [String]()
    private var displayedSongs = [SongItem]()
    
    private let supportedFileTypes = [".mp3", ".flac", ".alac", ".m4a", ".mp4a", ".wav"]
    
    private var player = Player.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        artistsTableView.delegate = self
        artistsTableView.dataSource = self
        
        songsTableView.delegate = self
        songsTableView.dataSource = self
        songsTableView.doubleAction = #selector(songsTableViewDoubleClicked)
        
        player.delegate = self
    }
    
    @objc func songsTableViewDoubleClicked() {
        let selectedRow = songsTableView.selectedRow
        
        if selectedRow == -1 {
            return
        }
        
        if displayedSongs[selectedRow].isGroup {
            return
        }
        
        player.stop()
        player.clearQueue()
        
        // Add songs starting from the selected one
        for item in displayedSongs[selectedRow...] {
            if !item.isGroup {
                player.addToQueue(song: item.song!)
            }
        }
        // Add the other songs before the selected one
        for item in displayedSongs[0..<selectedRow] {
            if !item.isGroup {
                player.addToQueue(song: item.song!)
            }
        }
        
        player.play()
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
            let urls = dialog.urls
            
            for url in urls {
                // Add all music files from subdirectories (recursively)
                if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
                    for case let fileURL as URL in enumerator {
                        do {
                            let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                            if fileAttributes.isRegularFile! {
                                let path = fileURL.path
                                
                                if supportedFileTypes.contains(where: { s in path.hasSuffix(s) }) {
                                    paths.append(path)
                                }
                            }
                        } catch {
                            print(error, fileURL)
                        }
                    }
                }
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
    
    // MARK: - Playback controls
    
    @IBAction func previousButtonClicked(_ sender: Any) {
    }
    
    @IBAction func playButtonClicked(_ sender: Any) {
        if !player.isPlaying() {
            player.play()
        } else {
            player.pause()
        }
        
        updatePlaybackInfo()
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        player.playNext()
        
        updatePlaybackInfo()
    }
    
    @IBAction func repeatButtonClicked(_ sender: Any) {
        if player.getPlaybackMode() == .RepeatOff {
            player.setPlaybackMode(.RepeatAll)
            repeatButton.image = NSImage(systemSymbolName: "repeat", accessibilityDescription: "Repeat all")
            repeatButton.contentTintColor = .controlAccentColor
        } else if player.getPlaybackMode() == .RepeatAll {
            player.setPlaybackMode(.RepeatOne)
            repeatButton.image = NSImage(systemSymbolName: "repeat.1", accessibilityDescription: "Repeat one")
            repeatButton.contentTintColor = .controlAccentColor
        } else {
            player.setPlaybackMode(.RepeatOff)
            repeatButton.image = NSImage(systemSymbolName: "repeat", accessibilityDescription: "Repeat off")
            repeatButton.contentTintColor = nil
        }
    }
    
    func updatePlaybackInfo() {
        if let currentSong = player.getCurrentSong() {
            songNameLabel.stringValue = currentSong.getArtistName() + " - " + currentSong.getTitle()
            
            // TODO: Set cover art
        } else {
            songNameLabel.stringValue = ""
            
            // TODO: Set cover art to some placeholder image
        }
        
        if player.isPlaying() {
            playButton.image = NSImage(systemSymbolName: "pause.fill", accessibilityDescription: "Pause")
        } else {
            playButton.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: "Play")
        }
    }
    
    @IBAction func playbackSliderChanged(_ sender: Any) {
        let seekTime = playbackSlider.doubleValue * player.getCurrentSongLength()
        player.seekToTime(time: seekTime)
    }
}

// MARK: - PlayerDelegate
extension MainViewController: PlayerDelegate {
    func progressChanged(progress: Double) {
        playbackSlider.doubleValue = progress
        
        let total = player.getCurrentSongLength().timeStringFromDouble()
        let current = (progress * player.getCurrentSongLength()).timeStringFromDouble()
        progressLabel.stringValue = current + "/" + total
    }
    
    func playbackStateChanged(currentSong: Song?, isPlaying: Bool, progress: Double) {
        updatePlaybackInfo()
        
        if currentSong == nil {
            playbackSlider.isEnabled = false
        } else {
            playbackSlider.isEnabled = true
        }
    }
}


// MARK: - TableView Extensions

extension MainViewController: NSTableViewDelegate, NSTableViewDataSource {

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
                if displayedSongs[row].isGroup {
                    text = displayedSongs[row].album
                } else {
                    guard let song = displayedSongs[row].song else { fatalError("WTF dude") }
                    text = song.getTitle()
                }
            }
        } else {
            return nil
        }
        
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellName), owner: self) as! NSTableCellView
        cell.textField!.stringValue = text

        return cell
    }
    
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        if tableView == songsTableView {
            return displayedSongs[row].isGroup
        } else {
            return false
        }
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
                return
            } else {
                let artistName = displayedArtists[artistRow]
                let newDisplayedSongs = artists[artistName]
                guard var newDisplayedSongs = newDisplayedSongs else { return }
                
                // Sort by title
                newDisplayedSongs.sort {$0.getTitle() < $1.getTitle()}
                // Sort by album
                newDisplayedSongs.sort {$0.getAlbumName() < $1.getAlbumName()}
                
                displayedSongs = []
                for s in newDisplayedSongs {
                    // If the song is first in the array or if the previous song was from different album, create an album group
                    if displayedSongs.isEmpty || displayedSongs.last?.song?.getAlbumName() != s.getAlbumName(){
                        displayedSongs.append(SongItem(song: nil, album: s.getAlbumName()))
                    }
                    
                    displayedSongs.append(SongItem(song: s))
                }
                
                songsTableView.reloadData()
            }
        }
    }
}
