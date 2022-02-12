//
//  MediaControlsView.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 28/01/2022.
//

import SwiftUI

struct MediaControlsView: View {

    @ObservedObject var player = Player.shared

    var body: some View {
        HStack {
            // MARK: - Previous
            Button(action: {
                player.playPrevious()
            }) {
                Image(systemName: "backward.fill")
            }
            // MARK: - Play/Pause
            Button(action: {
                if player.isPlaying {
                    player.pause()
                } else {
                    player.play()
                }
            }) {
                if (player.isPlaying) {
                    Image(systemName: "pause.fill")
                } else {
                    Image(systemName: "play.fill")
                }
            }
            // MARK: - Next
            Button(action: {
                Player.shared.playNext()
            }) {
                Image(systemName: "forward.fill")
            }

            // MARK: - Image
            Image(systemName: "music.note")

            // MARK: - Info
            if let s = player.currentSong {
                Text("\(s.artist ?? "") - \(s.album ?? "") - \(s.title ?? "")")
            } else {
                Text("")
            }

            // MARK: - Progress
            Slider(value: Binding(get: {
                return player.playbackProgress
            }, set: { newValue in
                player.playbackProgress = newValue
                player.seekToTime(seconds: newValue * player.duration)
            }))
        }
    }
}

struct MediaControlsView_Previews: PreviewProvider {
    static var previews: some View {
        MediaControlsView()
    }
}
