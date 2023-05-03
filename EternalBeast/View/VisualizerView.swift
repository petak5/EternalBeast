//
//  Visualizer.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 03/05/2023.
//

import Foundation
import SwiftUI

struct VisualizerView: View {
    @Binding
    var amplitudes: [Float?]

    var body: some View {
        HStack(spacing: 0.0){
            ForEach(0 ..< self.amplitudes.count) { number in
                VisualizerBarView(amplitude: self.$amplitudes[number])
            }
        }
        .background(Color.black)
    }
}

struct VisualizerBarView: View {
    @Binding var amplitude: Float?

    private let defaultAmplitude: Float = 0.5

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom){
                Rectangle()
                    .fill(.green)
                    .mask(Rectangle().padding(.top, geometry.size.height - geometry.size.height * CGFloat(self.amplitude ?? defaultAmplitude)))
                    .animation(.easeOut(duration: 0.15))
            }
            .border(Color.black, width: geometry.size.width * 0.1)
        }
    }
}
