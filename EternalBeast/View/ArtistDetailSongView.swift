//
//  ArtistDetailSongView.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 02/05/2023.
//

import Foundation
import SwiftUI

struct ArtistDetailSongView: View {
    @Binding
    var deleteConfirmationShown: Bool
    @Binding
    var songToDelete: Song?
    @EnvironmentObject
    var player: Player

    public let song: Song
    public var isHovered: Bool

    var body: some View {
        HStack {
            ZStack {
                // Hidden views to preserve constant size
                Image(systemName: "pause.fill").hidden()
                Image(systemName: "play.fill").hidden()
                Text(song.trackNumber?.stringValue ?? " ").hidden()

                if isHovered {
                    if song == player.currentSong {
                        if player.isPlaying {
                            Image(systemName: "pause.fill")
                                .onTapGesture {
                                    player.pause()
                                }
                        } else {
                            Image(systemName: "play.fill")
                                .onTapGesture {
                                    player.play()
                                }
                        }
                    } else {
                        Image(systemName: "play.fill")
                            .onTapGesture {
                                player.playSong(song)
                            }
                    }
                } else {
                    Text(song.trackNumber?.stringValue ?? " ")
                }
            }
            if song == player.currentSong {
                Text(song.title ?? "")
                    .bold()
            } else {
                Text(song.title ?? "")
            }
        }
        .contextMenu() {
            if song == player.currentSong {
                if player.isPlaying {
                    Button("Pause") {
                        player.pause()
                    }
                } else {
                    Button("Resume") {
                        player.play()
                    }
                }
            } else {
                Button("Play") {
                    player.playSong(song)
                }
            }
            Button("Delete") {
                songToDelete = song
                deleteConfirmationShown = true
            }
        }
    }
}
