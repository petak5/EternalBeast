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
        if player.url == nil {
            prepare()
        }
        
        MPNowPlayingInfoCenter.default().playbackState = .playing
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: currentSong?.title,
            MPMediaItemPropertyArtist: currentSong?.artist,
            MPMediaItemPropertyAlbumTitle: currentSong?.album
        ]
        
        player.play()
        
        delegate?.playbackStateChanged(currentSong: currentSong, isPlaying: isPlaying(), progress: getProgress())
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
