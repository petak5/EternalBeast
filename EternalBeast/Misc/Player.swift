//
//  Player.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 28/01/2022.
//

import Cocoa
import Combine
import AVFoundation
import MediaPlayer

enum PlaybackMode {
    case RepeatOff
    case RepeatAll
    case RepeatOne
}

final class Player: ObservableObject {
    static let shared = Player()

    private var player = AVPlayer()
    @Published private (set) var queue = Queue<Song>()
    @Published private (set) var history = Queue<Song>()
    @Published private (set) var currentSong: Song?
    @Published var playbackMode: PlaybackMode = .RepeatAll
    @Published var isPlaying = false

    init() {
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
            if self.isPlaying {
                self.pause()
            } else {
                self.play()
            }
            return .success
        }

        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget { [unowned self] event in
            self.playPrevious()
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
        let url = URL(fileURLWithPath: song.getPathToFile())
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
    }

    func play() {
        if isPlaying {
            return
        }

        if queue.isEmpty() {
            return
        }

        if player.status != .readyToPlay {
            prepare()
        }

        MPNowPlayingInfoCenter.default().playbackState = .playing

        player.play()
        isPlaying = true
    }

    func playSong(_ song: Song) {
        stop()

        queue.clear()
        queue.push(song)

        prepare()
        play()
    }

    func playPrevious() {
        stop()

        // If there is a song in history, put it to front of queue
        if let song = history.pop() {
            queue.insert(song, at: 0)
        }

        // Play first song from queue
        prepare()
        play()
    }

    func playNext() {
        stop()

        guard let song = queue.pop() else {
            return
        }
        history.insert(song, at: 0)

        play()
    }

    func pause() {
        if isPlaying {
            player.pause()
        }

        MPNowPlayingInfoCenter.default().playbackState = .paused

        isPlaying = false
    }

    func stop() {
        player.replaceCurrentItem(with: nil)

        MPNowPlayingInfoCenter.default().playbackState = .stopped

        isPlaying = false
    }

    func seekToTime(time: Double) {
        player.seek(to: CMTime(seconds: time, preferredTimescale: .max))
    }
}
