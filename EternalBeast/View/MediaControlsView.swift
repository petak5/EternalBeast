//
//  MediaControlsView.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 28/01/2022.
//

import SwiftUI

struct MediaControlsView: View {

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

            // MARK: - Image
            Image(systemName: "music.note")
                .padding()

            VStack(spacing: 0) {
                // MARK: - Info
                HStack(spacing: 0) {
                    if let s = player.currentSong {
                        let title = s.title ?? ""
                        let artist = s.artist ?? ""
                        let album = s.album ?? ""
                        VStack(spacing: 0) {
                            Text(title.appending(title))
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
                    Text((player.playbackProgress * player.duration).timeStringFromDouble())
                        .font(.subheadline)
                        .monospacedDigit()
                        .frame(width: 60, alignment: .trailing)
                        .padding(.horizontal, 5)

                    // MARK: - Progress
                    Slider(value: Binding(get: {
                        return player.playbackProgress
                    }, set: { newValue in
                        player.playbackProgress = newValue
                        player.seekToTime(seconds: newValue * player.duration)
                    }))
                    .disabled(player.currentSong == nil)
                    .frame(width: 250)

                    Text(player.duration.timeStringFromDouble())
                        .font(.subheadline)
                        .monospacedDigit()
                        .frame(width: 60, alignment: .leading)
                        .padding(.horizontal, 5)
                }
            }
            .frame(width: 390)
        }
    }
}

struct MediaControlsView_Previews: PreviewProvider {
    static var previews: some View {
        MediaControlsView()
            .environmentObject(Player.shared)
    }
}
