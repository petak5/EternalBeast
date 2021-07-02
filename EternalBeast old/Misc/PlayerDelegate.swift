//
//  PlayerDelegate.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 19/05/2021.
//

import Foundation

protocol PlayerDelegate {
    // Called when song progress (current time) changed
    func progressChanged(progress: Double)
    
    // Called when playback state is changed
    // That can be when current song has been updated or when playback is started or paused
    func playbackStateChanged(currentSong: Song?, isPlaying: Bool, progress: Double)
}
