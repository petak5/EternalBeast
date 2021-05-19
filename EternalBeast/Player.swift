//
//  Player.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 19/05/2021.
//

import Cocoa
import AVFoundation

final class Player {
    static let shared = Player()
    
    private var player: AVAudioPlayer
    private var queue: Queue<Song>
    private var currentSong: Song? { queue.first() }
    
    private init() {
        queue = Queue<Song>()

        self.player = AVAudioPlayer()
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
            self.player = try AVAudioPlayer(contentsOf: url)
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
    }
    
    func playNext() {
        stop()
        let _ = queue.pop()
        play()
    }
    
    func pause() {
        if player.isPlaying {
            player.pause()
        }
    }
    
    func stop() {
        player.stop()
        player = AVAudioPlayer()
    }
    
    func isPlaying() -> Bool {
        return player.isPlaying
    }
}
