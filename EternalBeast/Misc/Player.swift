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
import Combine

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
    @Published var playbackProgress = 0.0
    @Published var duration = 0.0
    @Published var artwork: NSImage?
    private var itemStatusCancellable: AnyCancellable?

    var timer: Timer? = nil

    init() {
        setupObserving()

        ConfigureMPRemoteCommands()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if let item = self.player.currentItem {
                self.playbackProgress = item.currentTime().seconds / item.duration.seconds
                
                
                // MOVE UPDATING THE NOWPLAYBACKINFO TO RELEVANT PROPERTIES' SETTERS?
                
                
                // Update playback info in the Now Playing system menu
                if var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
                    nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.player.currentItem?.currentTime().seconds
//                    nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.player.currentItem?.duration
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                }
            } else {
                self.playbackProgress = 0.0
            }
        }
    }

    // Set up property observing
    private func setupObserving() {
        // Observe change of current AVPlayerItem's status, when readyToPlay, duration can be read
        // Status changes to readyToPlay when resources are loaded (including metadata such as duration)
        itemStatusCancellable = player.publisher(for: \.currentItem?.status, options: [.new, .initial]).sink { newStatus in
            if newStatus == .readyToPlay {
                if let item = self.player.currentItem {
                    self.duration = item.duration.seconds
                } else {
                    self.duration = 0.0
                }
            } else {
                self.playbackProgress = 0.0
                self.duration = 0.0
            }
            if var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.duration
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
    }

    @objc func playerItemDidReachEnd(notification: Notification) {
        playNext()
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
            seekToTime(seconds: seconds)
            return .success
        }
    }

    func addToQueue(songs: [Song]) {
        for song in songs {
            addToQueue(song: song)
        }
    }

    func addToQueue(song: Song) {
        queue.push(song)
    }

    func clearQueue() {
        queue.clear()
        history.clear()
    }

    private func prepare() {
        // Open first song from queue
        guard let song = queue.first() else { return }
        prepare(withSong: song)
    }

    private func prepare(withSong song: Song) {
        currentSong = song
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

        guard let currentSong = currentSong else {
            return
        }

        if player.status != .readyToPlay {
            prepare()
        }

        artwork = MetadataLoader.getSongArtwork(song: currentSong)

        MPNowPlayingInfoCenter.default().playbackState = .playing
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: currentSong.title,
            MPMediaItemPropertyArtist: currentSong.artist,
            MPMediaItemPropertyAlbumTitle: currentSong.album,
            MPMediaItemPropertyPlaybackDuration: player.currentItem?.duration.seconds,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: player.currentItem?.currentTime(),
            MPNowPlayingInfoPropertyPlaybackRate: 1
        ]
        if let artwork = artwork {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artwork.size) { _ in artwork }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo

        player.play()
        isPlaying = true
    }

    func playSongs(songs: [Song]) {
        stop()

        clearQueue()
        addToQueue(songs: songs)

        prepare()
        play()
    }

    func playSong(_ song: Song) {
        stop()

        clearQueue()
        addToQueue(song: song)

        prepare()
        play()
    }

    func playPrevious() {
        // Seek to start if less that 5s elapsed
        if duration * playbackProgress > 5 {
            replayFromStart()
        } else {
            if playbackMode == .RepeatOff {
                replayFromStart()
            } else if playbackMode == .RepeatOne {
                replayFromStart()
            } else if playbackMode == .RepeatAll {
                stop()

                // If there is a song in history, put it to front of queue
                if let song = history.pop() {
                    queue.insert(song, at: 0)
                }

                // Play first song from queue
                prepare()
                play()
            }
        }
    }

    func playNext() {
        if playbackMode == .RepeatOff {
            pause()
            seekToTime(seconds: 0)
        } else if playbackMode == .RepeatOne {
            replayFromStart()
        } else if playbackMode == .RepeatAll {
            stop()

            guard let song = queue.pop() else {
                return
            }

            history.insert(song, at: 0)

            if queue.isEmpty() && playbackMode == .RepeatAll {
                addToQueue(songs: history.items().reversed())
                history.clear()
            }

            prepare()
            play()
        }
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
        currentSong = nil
        artwork = nil

        MPNowPlayingInfoCenter.default().playbackState = .stopped

        isPlaying = false
    }

    func replayFromStart() {
        seekToTime(seconds: 0)
        play()
    }

    func seekToTime(seconds: Double) {
        if seconds < 0 || seconds > duration {
            return
        }

        player.seek(to: CMTime(seconds: seconds, preferredTimescale: .max))
    }
}
