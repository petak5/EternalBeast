//
//  LibraryArtistsViewController.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 02/05/2021.
//

import Cocoa

// Song item represents a row in songs table view, where each album has a group cell
struct SongItem {
    var song: Song?
    var album: String
    var year: String
    var isGroup: Bool
    
    init(song: Song?, album: String = "", year: String = "") {
        self.song = song
        self.album = album
        self.year = year
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
    
    // Supported file extensions
    private let supportedFileTypes = [".mp3", ".flac", ".alac", ".m4a", ".mp4a", ".wav"]
    
    // Player singleton
    private var player = Player.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Repeat button is available from macOS 11
        if #available(macOS 11.0, *) {
            repeatButton.image = NSImage(systemSymbolName: "repeat", accessibilityDescription: "Repeat all")
        }
        
        artistsTableView.delegate = self
        artistsTableView.dataSource = self
        
        songsTableView.delegate = self
        songsTableView.dataSource = self
        songsTableView.doubleAction = #selector(playClickedSong)
        
        player.delegate = self
        
        loadSongs()
    }
    
    // Add selected files or folders to library
    @IBAction func addToLibrary(_ sender: Any) {
        let dialog = NSOpenPanel();
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseFiles          = true;
        dialog.canChooseDirectories    = true;
        dialog.allowsMultipleSelection = true;
        
        // Run the modal, exit if user cancels
        if dialog.runModal() != NSApplication.ModalResponse.OK {
            return
        }
        
        // Get all files
        let paths = getPathsfromUrlsRecursive(urls: dialog.urls)
        
        // Add all files to library
        for path in paths {
            addSong(fromPath: path)
        }
        
        displayedArtists = Array(artists.keys).sorted()
        
        artistsTableView.reloadData()
        songsTableView.reloadData()
    }
    
    // Get all files from URLs, exploring directories recursively
    // The files are filtered and only files with extensions defined in 'supportedFileTypes' array are returned
    func getPathsfromUrlsRecursive(urls: [URL]) -> [String] {
        var paths = [String]()
        
        for url in urls {
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
                
                // URL path is direcotry
                if isDir.boolValue {
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
                    
                // URL path is file
                } else {
                    if supportedFileTypes.contains(where: { s in url.path.hasSuffix(s) }) {
                        paths.append(url.path)
                    }
                }
            }
        }
        
        return paths
    }
    
    public func addSong(fromPath path: String) {
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: path) || !fileManager.isReadableFile(atPath: path) {
            print("File '\(path)' does not exist or is not readable.")
            return
        }
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let cdContext = appDelegate.persistentContainer.viewContext
        
        let song = Song(context: cdContext)
        song.loadMetadata(pathToFile: path)
        
        addSongObjectToArtistsDictionary(song: song)
    }
    
    // Adds song instance to local dictionary 'artists' holding all songs
    func addSongObjectToArtistsDictionary(song: Song) {
        // Create artist if not found
        if !artists.contains(where: {k, v in k == song.artist}) {
            artists[song.artist] = []
        }
        // Add song to artist
        artists[song.artist]?.append(song)
    }
    
    // MARK: - CoreData
    
    // Load songs from CoreData container
    func loadSongs() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let cdContext = appDelegate.persistentContainer.viewContext
        
        let request : NSFetchRequest<Song> = NSFetchRequest(entityName: "Song")
        do {
            let songs = try cdContext.fetch(request)
            for song in songs {
                addSongObjectToArtistsDictionary(song: song)
            }
        } catch {
            print("Error loading songs, \(error)")
        }
        
        displayedArtists = Array(artists.keys).sorted()

        artistsTableView.reloadData()
        songsTableView.reloadData()
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
            if #available(macOS 11.0, *) {
                repeatButton.image = NSImage(systemSymbolName: "repeat", accessibilityDescription: "Repeat all")
            } else {
                // TODO: Fallback on earlier versions
            }
            repeatButton.contentTintColor = .controlAccentColor
        } else if player.getPlaybackMode() == .RepeatAll {
            player.setPlaybackMode(.RepeatOne)
            if #available(macOS 11.0, *) {
                repeatButton.image = NSImage(systemSymbolName: "repeat.1", accessibilityDescription: "Repeat one")
            } else {
                // TODO: Fallback on earlier versions
            }
            repeatButton.contentTintColor = .controlAccentColor
        } else {
            player.setPlaybackMode(.RepeatOff)
            if #available(macOS 11.0, *) {
                repeatButton.image = NSImage(systemSymbolName: "repeat", accessibilityDescription: "Repeat off")
            } else {
                // TODO: Fallback on earlier versions
            }
            repeatButton.contentTintColor = nil
        }
    }
    
    func updatePlaybackInfo() {
        if let currentSong = player.getCurrentSong() {
            songNameLabel.stringValue = currentSong.artist + " - " + currentSong.title
            
            if let image = player.currentSongArtwork {
                coverArtImage.image = image
            } else {
                coverArtImage.image = nil
            }
        } else {
            songNameLabel.stringValue = ""
            coverArtImage.image = nil
        }
        
        if player.isPlaying() {
            playButton.image = NSImage(named: NSImage.touchBarPauseTemplateName)
        } else {
            playButton.image = NSImage(named: NSImage.touchBarPlayTemplateName)
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
        // Artists
        if tableView == artistsTableView {
            return displayedArtists.count
            
        // Songs
        } else if tableView == songsTableView {
            let row = artistsTableView.selectedRow
            
            // No row selected
            if row == -1 {
                return 0
            }
            
            return displayedSongs.count
        
        // Unknown table view
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        // Artists table view
        if tableView == artistsTableView {
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("artistCell"), owner: self) as! NSTableCellView
            cell.textField!.stringValue = displayedArtists[row]
            
            return cell
            
        // Songs table view
        } else if tableView == songsTableView {
            
            // Album group cell
            if displayedSongs[row].isGroup {
                var text = displayedSongs[row].album
                let year = displayedSongs[row].year
                
                // Add year to title if is provided
                if !year.isEmpty {
                    text = year + " - " + text
                }
                
                let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("albumGroupCell"), owner: self) as! AlbumGroupCell
                cell.albumNameLabel.stringValue = text
                
                return cell
                
            // Song cell
            } else {
                let artistSelectedRow = artistsTableView.selectedRow
                
                // No row selected
                if artistSelectedRow == -1 {
                    return nil
                }
                
                guard let song = displayedSongs[row].song else { fatalError("WTF dude") }
                
                var text = song.title
                if !song.trackNumber.isEmpty {
                    text = song.trackNumber + ": " + text
                }
                
                let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("songCell"), owner: self) as! SongCell
                cell.songNameLabel.stringValue = text
                cell.songLengthLabel.stringValue = song.length
                
                return cell
            }
            
        // Unknown table view
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        // Songs are divided into groups by album name
        if tableView == songsTableView {
            return displayedSongs[row].isGroup
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {

        // Artist cell
        if tableView == artistsTableView {
            return 52
            
        // Songs table view
        } else if tableView == songsTableView {
            
            // Album group cell
            if displayedSongs[row].isGroup {
                return 48
            
            // Song cell
            } else {
                return 32
            }
            
        // Unknown table view
        } else {
            return 0
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let tableView = notification.object as? NSTableView
        
        guard let _tableView = tableView else { return }
        if _tableView == artistsTableView {
            reloadSongsTableData()
        }
    }
    
    // Reload selected artist's songs to displayed songs array and update the table view with it
    func reloadSongsTableData() {
        // Get selected artist row
        let artistRow = artistsTableView.selectedRow
        
        if artistRow == -1 {
            // Do nothing
            return
        } else {
            let artistName = displayedArtists[artistRow]
            let newDisplayedSongs = artists[artistName]
            guard var newDisplayedSongs = newDisplayedSongs else { return }
            
            // MARK: Sorting is not as good as desired but it is not possible to sort songs in any useful manner without track number and sort albums by year.
            //       Unfortunately it's not that simple to get this information from song files.
            
            // Sort by track number
            //newDisplayedSongs.sort { $0.trackNumber < $1.trackNumber }
            // Sort by year
            //newDisplayedSongs.sort { $0.year < $1.year }
            // Sort by title
            newDisplayedSongs.sort { $0.title < $1.title }
            // Sort by album
            newDisplayedSongs.sort { $0.album < $1.album }
            
            displayedSongs = []
            for s in newDisplayedSongs {
                // If the song is first in the array or if the previous song was from different album, create an album group
                if displayedSongs.isEmpty || displayedSongs.last?.song?.album != s.album {
                    displayedSongs.append(SongItem(song: nil, album: s.album, year: s.year))
                }
                
                displayedSongs.append(SongItem(song: s))
            }
            
            songsTableView.reloadData()
        }
    }
    
    // Double clicking song will play the file
    @objc func playClickedSong() {
        let clickedRow = songsTableView.clickedRow
        
        if clickedRow == -1 {
            return
        }
        
        if displayedSongs[clickedRow].isGroup {
            return
        }
        
        player.stop()
        player.clearQueue()
        
        // Add songs starting from the selected one
        for item in displayedSongs[clickedRow...] {
            if !item.isGroup {
                player.addToQueue(song: item.song!)
            }
        }
        // Add the other songs before the selected one
        for item in displayedSongs[0..<clickedRow] {
            if !item.isGroup {
                player.addToQueue(song: item.song!)
            }
        }
        
        player.play()
    }
    
    // MARK: - Artists table view context menu
    
    @IBAction func playArtistContextMenuClicked(_ sender: Any) {
        playClickedArtistSongs()
    }
    
    // Play all clicked artist's songs
    func playClickedArtistSongs() {
        let clickedRow = artistsTableView.clickedRow
        
        if clickedRow == -1 {
            return
        }
        
        player.stop()
        player.clearQueue()
        
        guard let songs = artists[displayedArtists[clickedRow]] else { return }
        
        // Add all artist's songs
        for song in songs {
            player.addToQueue(song: song)
        }
        
        player.play()
    }
    
    @IBAction func deleteArtistContextMenuClicked(_ sender: Any) {
        let clickedRow = artistsTableView.clickedRow
        
        if clickedRow == -1 {
            return
        }
        
        let artistName = displayedArtists[clickedRow]
        guard let artistSongs = artists[artistName] else { return }
        
        // Ask user for confirmation
        let alert = NSAlert.init()
        alert.messageText = "Remove all \"\(artistName)\"'s songs from library?"
        alert.informativeText = "Removing songs from library will not delete the files from your computer."
        alert.addButton(withTitle: "Remove")
        alert.addButton(withTitle: "Cancel")
        
        // Stop if user clicked "Cancel"
        if alert.runModal() != NSApplication.ModalResponse.alertFirstButtonReturn {
            return
        }
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let cdContext = appDelegate.persistentContainer.viewContext
        
        for song in artistSongs {
            cdContext.delete(song)
        }
        
        artists.removeValue(forKey: artistName)
        
        // Reload songs table
        displayedSongs = []
        songsTableView.reloadData()
        
        // Reload artist table
        displayedArtists = Array(artists.keys).sorted()
        artistsTableView.reloadData()
    }
    
    // MARK: - Songs table view context menu
    
    @IBAction func playContextMenuClicked(_ sender: Any) {
        playClickedSong()
    }
    
    @IBAction func deleteContextMenuClicked(_ sender: Any) {
        let clickedRow = songsTableView.clickedRow
        
        if clickedRow == -1 {
            return
        }
        
        if displayedSongs[clickedRow].isGroup {
            return
        }
        
        guard let song = displayedSongs[clickedRow].song else { return }
        guard let artistSongs = artists[displayedArtists[artistsTableView.selectedRow]] else { return }
        
        guard let index = artistSongs.firstIndex(where: { s in s.getPathToFile() == song.getPathToFile() }) else { return }
        
        // Ask user for confirmation
        let alert = NSAlert.init()
        alert.messageText = "Remove \"\(song.title)\" from library?"
        alert.informativeText = "Removing song from library will not delete the file from your computer."
        alert.addButton(withTitle: "Remove")
        alert.addButton(withTitle: "Cancel")
        
        // Stop if user clicked "Cancel"
        if alert.runModal() != NSApplication.ModalResponse.alertFirstButtonReturn {
            return
        }
        
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let cdContext = appDelegate.persistentContainer.viewContext
        
        cdContext.delete(song)
        
        // Remove the song and reload table view data
        artists[displayedArtists[artistsTableView.selectedRow]]?.remove(at: index)
        reloadSongsTableData()
        
        // If artist has just one last song, remove the artist
        if artistSongs.count == 1 {
            artists.removeValue(forKey: displayedArtists[artistsTableView.selectedRow])
            
            displayedArtists = Array(artists.keys).sorted()
            artistsTableView.reloadData()
        }
    }
    
}
