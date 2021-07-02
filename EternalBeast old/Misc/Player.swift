//
//  Player.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 19/05/2021.
//

import Cocoa
import AVFoundation
import MediaPlayer

enum PlaybackMode {
    case RepeatOff
    case RepeatAll
    case RepeatOne
}

final class Player: NSObject {
    static let shared = Player()
    
    private var player: AVAudioPlayer
    private var queue: Queue<Song>
    private var currentSong: Song? { queue.first() }
    private var playbackMode: PlaybackMode
    private var timer: Timer?
    
    // "last song" for checking if artwork needs to be updated
    private var lastSongForArtwork: Song?
    private (set) var currentSongArtwork: NSImage?
    
    var delegate: PlayerDelegate?
    
    private override init() {
        queue = Queue<Song>()
        player = AVAudioPlayer()
        playbackMode = .RepeatAll
        
        super.init()
        
        player.delegate = self
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: update)
        timer?.fire()
        
        ConfigureMPRemoteCommands()
    }
    
    // Add actions to MediaPlayer Remote Commands from Now Playing system menu
    private func ConfigureMPRemoteCommands() {
        MPRemoteCommandCenter.shared().playCommand.addTarget { [unowned self] event in
            self.play()
            return .success
        }
        
        MPRemoteCommandCenter.shared().pauseCommand.addTarget { [unowned self] event in
            self.pause()
            return .success
        }
        
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget { [unowned self] event in
            if self.isPlaying() {
                self.pause()
            } else {
                self.play()
            }
            return .success
        }
        
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget { [unowned self] event in
            self.playNext()
            return .success
        }
        
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget { [unowned self] event in
            let seconds = (event as? MPChangePlaybackPositionCommandEvent)?.positionTime ?? 0
            seekToTime(time: seconds)
            return .success
        }
    }
    
    func addToQueue(song: Song) {
        queue.push(song)
    }
    
    func clearQueue() {
        queue.clear()
    }
    
    private func prepare() {
        // Open first song from queue
        guard let song = queue.first() else { return }
        prepare(withSong: song)
    }
    
    private func prepare(withSong song: Song) {
        do {
            let url = URL(fileURLWithPath: song.getPathToFile())
            player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
        } catch let error {
            NSResponder().presentError(error)
            print(error.localizedDescription)
        }
    }
    
    func play() {
        guard let currentSong = self.currentSong else { return }
        
        if player.url == nil {
            prepare()
        }
        
        MPNowPlayingInfoCenter.default().playbackState = .playing
        
        if let lastSong = lastSongForArtwork {
            if lastSong.getPathToFile() != currentSong.getPathToFile() {
                lastSongForArtwork = currentSong
                updateCurrentSongArtwork()
            }
        } else {
            lastSongForArtwork = currentSong
            updateCurrentSongArtwork()
        }
        
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: currentSong.title,
            MPMediaItemPropertyArtist: currentSong.artist,
            MPMediaItemPropertyAlbumTitle: currentSong.album,
            MPMediaItemPropertyPlaybackDuration: player.duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: player.currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: 1
        ]
        if let artwork = currentSongArtwork {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artwork.size) { _ in artwork }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
        player.play()
        
        delegate?.playbackStateChanged(currentSong: currentSong, isPlaying: isPlaying(), progress: getProgress())
    }
    
    func updateCurrentSongArtwork() {
        if let lastSong = lastSongForArtwork {
            let fileUrl = URL(fileURLWithPath: lastSong.getPathToFile())
            let asset = AVAsset(url: fileUrl) as AVAsset
            
            // Get metadata
            for metaDataItem in asset.metadata {
                // If metadata item is artwork, create image and save it to variable
                if metaDataItem.commonKey == .commonKeyArtwork {
                    if let data = metaDataItem.dataValue,
                    let newImage = NSImage(data: data) {
                        currentSongArtwork = newImage
                    }
                }
            }
        }
    }
    
    func playNext() {
        stop()
        
        if playbackMode == .RepeatAll {
            let song = queue.pop()
            if let song = song {
                queue.push(song)
            }
        }
        
        play()
    }
    
    func pause() {
        if player.isPlaying {
            player.pause()
        }
        
        MPNowPlayingInfoCenter.default().playbackState = .paused
        
        delegate?.playbackStateChanged(currentSong: currentSong, isPlaying: isPlaying(), progress: getProgress())
    }
    
    func stop() {
        player.stop()
        player = AVAudioPlayer()
        player.delegate = self
        
        delegate?.playbackStateChanged(currentSong: currentSong, isPlaying: isPlaying(), progress: getProgress())
    }
    
    func isPlaying() -> Bool {
        return player.isPlaying
    }
    
    func getCurrentSong() -> Song? {
        return queue.first()
    }
    
    // Current song's lenght in seconds
    func getCurrentSongLength() -> Double {
        return player.duration
    }
    
    func getProgress() -> Double {
        if player.duration == 0 {
            return 0
        } else {
            return player.currentTime / player.duration
        }
    }
    
    func seekToTime(time: Double) {
        player.currentTime = time
        
        // Update playback info in the Now Playing system menu
        if var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
        
        if let timer = timer {
            update(timer)
        }
    }
    
    func getPlaybackMode() -> PlaybackMode {
        return playbackMode
    }
    
    func setPlaybackMode(_ playbackMode: PlaybackMode) {
        self.playbackMode = playbackMode
    }
    
    // MARK: - Timer
    
    private func update(_ timer: Timer) {
        delegate?.progressChanged(progress: getProgress())
    }
}

extension Player: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        if playbackMode != .RepeatOff {
            playNext()
        }
        
        delegate?.playbackStateChanged(currentSong: currentSong, isPlaying: isPlaying(), progress: getProgress())
    }
}
