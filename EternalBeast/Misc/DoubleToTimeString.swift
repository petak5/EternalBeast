//
//  DoubleToTimeString.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 05/07/2021.
//

import Foundation

extension Double {
    // Format time for music player
    func timeStringFromDouble() -> String {
        let time = Int(self)

        //let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)

        if hours == 0 {
            return String(format: "%d:%0.2d", minutes, seconds)
        }
        else {
            return String(format: "%d:%0.2d:%0.2d", hours, minutes, seconds)
        }
    }
}
