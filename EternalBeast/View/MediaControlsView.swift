//
//  MediaControlsView.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 28/01/2022.
//

import SwiftUI

struct MediaControlsView: View {
    @Environment(\.openWindow)
    var openWindow

    @EnvironmentObject
    private var player: Player

    var body: some View {
        HStack(spacing: 0) {
            // MARK: - Previous
            Button(action: {
                player.playPrevious()
            }) {
                Image(systemName: "backward.fill")
            }
            .disabled(player.currentSong == nil)
            // MARK: - Play/Pause
            Button(action: {
                if player.isPlaying {
                    player.pause()
                } else {
                    player.play()
                }
            }) {
                ZStack {
                    // Hidden play and pause images, to ensure constant width of the view
                    if (player.isPlaying) { Image(systemName: "play.fill").hidden()}
                    else { Image(systemName: "pause.fill").hidden() }

                    if (player.isPlaying) {
                        Image(systemName: "pause.fill")
                    } else {
                        Image(systemName: "play.fill")
                    }
                }
            }
            .disabled(player.currentSong == nil)
            // MARK: - Next
            Button(action: {
                Player.shared.playNext()
            }) {
                Image(systemName: "forward.fill")
            }
            .disabled(player.currentSong == nil)

            // MARK: - Playback Mode
            Button {
                if player.playbackMode == .RepeatAll {
                    player.playbackMode = .RepeatOne
                } else if player.playbackMode == .RepeatOne {
                    player.playbackMode = .RepeatOff
                } else if player.playbackMode == .RepeatOff {
                    player.playbackMode = .RepeatAll
                }
            } label: {
                ZStack {
                    // Hidden images to preseerve constant size
                    Image(systemName: "repeat").hidden()
                    Image(systemName: "repeat.1").hidden()
                    Image(systemName: "repeat").hidden()

                    if player.playbackMode == .RepeatAll {
                        Image(systemName: "repeat")
                            .help("Repeat All")
                            .foregroundColor(.accentColor)
                    } else if player.playbackMode == .RepeatOne {
                        Image(systemName: "repeat.1")
                            .help("Repeat One")
                            .foregroundColor(.accentColor)
                    } else if player.playbackMode == .RepeatOff {
                        Image(systemName: "repeat")
                            .help("Repeat Off")
                    }
                }
            }

            HStack(spacing: 0) {
                // MARK: - Artwork Image
                if let artwork = player.artwork {
                    Image(nsImage: artwork)
                        .resizable()
                        .frame(width: 42, height: 42)
                        .onTapGesture {
                            openWindow(id: "artwork-image")
                        }
                } else {
                    VStack {
                        Image(systemName: "music.note")
                    }
                    .frame(width: 42)
                }

                VStack(spacing: 0) {
                    // MARK: - Info
                    HStack(spacing: 0) {
                        if let s = player.currentSong {
                            let title = s.title ?? ""
                            let artist = s.artist ?? ""
                            let album = s.album ?? ""
                            VStack(spacing: 0) {
                                Text(title)
                                    .font(.headline)
                                Text("\(artist) - \(album)")
                                    .font(.subheadline)
                            }
                            .help("\(title)\n\(artist) - \(album)")
                        } else {
                            VStack(spacing: 0) {
                                Text(" ")
                                    .font(.headline)
                                Text(" ")
                                    .font(.subheadline)
                            }
                        }
                    }
                    .frame(width: 250)

                    HStack(spacing: 0) {
                        timeView(seconds: player.playbackProgress * player.duration, alignment: .trailing)

                        // MARK: - Progress slider
                        Slider(value: Binding(get: {
                            return player.playbackProgress
                        }, set: { newValue in
                            player.playbackProgress = newValue
                            player.seekToTime(seconds: newValue * player.duration)
                        }))
                        .disabled(player.currentSong == nil)
                        .frame(width: 250)

                        timeView(seconds: player.duration, alignment: .leading)
                    }
                }
                .frame(idealWidth: 350)
            }
            .padding(.horizontal, 20)

            // MARK: - Volume Slider
            HStack(spacing: 0) {
                Image(systemName: "speaker")

                Slider(value: Binding(get: {
                    return player.volume
                }, set: { newValue in
                    player.volume = newValue
                    player.setVolume(value: newValue)
                }))

                Image(systemName: "speaker.wave.3")
            }
            .frame(width: 110)
        }
    }

    @ViewBuilder
    func timeView(seconds: Double, alignment: Alignment) -> some View {
        Text(seconds.timeStringFromDouble())
            .font(.subheadline)
            .monospacedDigit()
            .frame(idealWidth: 40, alignment: alignment)
            .padding(.horizontal, 5)
    }
}

//struct MediaControlsView_Previews: PreviewProvider {
//    static var previews: some View {
//        MediaControlsView()
//            .environmentObject(Player.shared)
//    }
//}
