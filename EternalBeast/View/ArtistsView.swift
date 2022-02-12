//
//  ArtistsView.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 02/07/2021.
//

import SwiftUI

struct ArtistsView: View {
    @State var selectKeeper = Set<String>()

    let artists: [Artist]

    var body: some View {
        NavigationView {
            List(artists, id: \.name) { artist in
                NavigationLink(destination: ArtistDetailView(artist: artist)) {
                    Text(artist.name)
                }
            }
        }
    }
}

//struct ArtistsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ArtistsView()
//    }
//}
