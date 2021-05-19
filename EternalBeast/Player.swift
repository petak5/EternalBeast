//
//  Player.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 19/05/2021.
//

import Cocoa
import AVFoundation

enum PlaybackMode {
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
    }
    
    func addToQueue(song: Song) {
        queue.push(song)
    }
    
    func clearQueue() {
        queue.clear()
    }

//    func add(fromFolder folder: String) {
//        do {
//            let files = try FileManager.default.contentsOfDirectory(atPath: folder)
//
//            for file in files {
//                let suffix = String(file.suffix(4))
//                if suffix == ".mp3" {
//                    add(file: file)
//                }
//            }
//
//        } catch let error {
//            print(error.localizedDescription)
//        }
//    }
    
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
    
    // MARK: - Timer
    
    private func update(_ timer: Timer) {
        delegate?.progressChanged(progress: getProgress())
    }
}

extension Player: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playNext()
        
        delegate?.playbackStateChanged(currentSong: currentSong, isPlaying: isPlaying(), progress: getProgress())
    }
}
