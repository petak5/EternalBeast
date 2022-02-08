//
//  MediaControlsView.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 28/01/2022.
//

import SwiftUI

struct MediaControlsView: View {

    @ObservedObject var player = Player.shared
//    @ObservedObject var song = Player.shared.currentSong ?? Library.shared.artists[0].albums[0].songs[0]

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

            Image(systemName: "music.note")
            VStack {
                Text("Slider ------------------------")
                Text("Artist - Album - Song")
            }
        }
    }
}

struct MediaControlsView_Previews: PreviewProvider {
    static var previews: some View {
        MediaControlsView()
    }
}
