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
import AudioKit

enum PlaybackMode {
    case RepeatOff
    case RepeatAll
    case RepeatOne
}

final class Player: ObservableObject, HasAudioEngine {
    static let shared = Player()

    private var player = AudioPlayer()
    public var engine = AudioEngine()
    @Published private (set) var queue = Queue<Song>()
    @Published private (set) var history = Queue<Song>()
    @Published private (set) var currentSong: Song?
    @Published var playbackMode: PlaybackMode = .RepeatAll
    @Published var isPlaying = false
    @Published var volume: Float = 1.0
    @Published var playbackProgress = 0.0
    @Published var duration = 0.0
    @Published var artwork: NSImage?

    var timer: Timer? = nil

    private let SMOL_NUMBER = 0.000001

    init() {
        ConfigureMPRemoteCommands()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.playbackProgress = self.player.currentPosition
            self.duration = self.player.duration

            // Update playback info in the Now Playing system menu
            if var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.player.currentTime
//                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.audioPlayer.duration
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
        }

        engine.output = player
        player.completionHandler = audioPlayerPlaybackCompletionHandler
        do { try engine.start() } catch let err { Log(err) }
    }

    deinit {
        player.stop()
        engine.stop()
    }

    private func audioPlayerPlaybackCompletionHandler() {
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
        do {
            try player.load(url: url)
            // THIS IS SOME NICE MAGIC
            // WITHOUT THIS SEEK BEFORE PLAYING, THE STATE IS STUCK IN 'STOPPED' STATE AND NEXT ACTION DOES NOTHIN.
            // SO TO PAUSE THE SONG YOU HAVE TO PAUSE, PLAY AND PAUSE AGAIN
            // NO IDEA WHY
            player.seek(time: TimeInterval(integerLiteral: SMOL_NUMBER))
            // MAGIC END
        } catch {
            Log(error.localizedDescription, type: .error)
        }
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

        artwork = MetadataLoader.getSongArtwork(song: currentSong)

        MPNowPlayingInfoCenter.default().playbackState = .playing
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: currentSong.title,
            MPMediaItemPropertyArtist: currentSong.artist,
            MPMediaItemPropertyAlbumTitle: currentSong.album,
            MPMediaItemPropertyPlaybackDuration: player.duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: player.currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: 1
        ]
        if let artwork = artwork {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artwork.size) { _ in artwork }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo

        player.play()
        isPlaying = true
    }

    func playSongs(albums: [Album], from currentSong: Song, songSortDescriptors: [SortDescriptor<Song>] = []) {
        stop()

        clearQueue()

        var isHistory = true
        for album in albums {
            for song in album.songs.sorted(using: songSortDescriptors) {
                if isHistory {
                    if song == currentSong {
                        addToQueue(song: song)
                        prepare()
                        play()
                        isHistory = false
                    } else {
                        addToHistory(song: song)
                    }
                } else {
                    addToQueue(song: song)
                }
            }
        }
    }

    func playSongs(songs: [Song], from currentSong: Song) {
        stop()

        clearQueue()

        var isHistory = true
        for song in songs {
            if isHistory {
                if song == currentSong {
                    addToQueue(song: song)
                    prepare()
                    play()
                    isHistory = false
                } else {
                    addToHistory(song: song)
                }
            } else {
                addToQueue(song: song)
            }
        }
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
        // Seek to start if less that 2s elapsed
        if duration * playbackProgress > 2 {
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
            seekToTime(seconds: 0)
            pause()
        } else if playbackMode == .RepeatOne {
            replayFromStart()
        } else if playbackMode == .RepeatAll {
            // TODO: For some reason when song ends, it can get stuck here (infinite loop, program freezes)
            stop()

            guard let song = queue.pop() else {
                return
            }

            addToHistory(song: song)

            if queue.isEmpty() && playbackMode == .RepeatAll {
                addToQueue(songs: history.items().reversed())
                history.clear()
            }

            prepare()
            play()
        }
    }

    /// Adds song to history (as most recent)
    private func addToHistory(song: Song) {
        history.insert(song, at: 0)
    }

    func pause() {
        if isPlaying {
            player.pause()
        }

        MPNowPlayingInfoCenter.default().playbackState = .paused

        isPlaying = false
    }

    func stop() {
        // TODO: For some reason when song ends, it can get stuck here (infinite loop, program freezes)
        player.stop()
        currentSong = nil
        artwork = nil

        MPNowPlayingInfoCenter.default().playbackState = .stopped

        isPlaying = false
    }

    func setVolume(value: Float) {
        player.volume = max(min(value, 1.0), 0.0)
    }

    func replayFromStart() {
        seekToTime(seconds: 0)
        play()
    }

    func seekToTime(seconds: Double) {
        if seconds < 0 || seconds > duration {
            return
        }

        var s = seconds
        if s == 0 {
            s = SMOL_NUMBER
        }

        let time = s - player.currentTime
        player.seek(time: TimeInterval(integerLiteral: time))
    }
}
