//
//  ArtistsView.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 02/07/2021.
//

import SwiftUI

struct ArtistsView: View {
    @Binding
    var selection: String?
    @EnvironmentObject
    private var library: Library

    var body: some View {
        NavigationView {
            List(library.artists, id: \.name, selection: $selection) { artist in
                NavigationLink(destination: ArtistDetailView(artist: artist)) {
                    Text(artist.name)
                }
                .tag(artist.name)
            }
            .contextMenu() {
                Button("Action 1") {}
                Button("Action 2") {}
            }
        }
    }
}

//struct ArtistsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ArtistsView()
//    }
//}
