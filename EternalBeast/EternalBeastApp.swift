//
//  EternalBeastApp.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 02/07/2021.
//

import SwiftUI

@main
struct EternalBeastApp: App {
    private let persistenceController = PersistenceController.shared

    @Environment(\.scenePhase)
    private var scenePhase

    @State
    private var deleteConfirmationShown = false
    @StateObject
    var library = Library.shared
    @StateObject
    var player = Player.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .alert("Are you sure you want to clear the whole library?", isPresented: $deleteConfirmationShown) {
                    Button("No", role: .cancel) { }
                    Button("Yes", role: .destructive) {
                        withAnimation {
                            let moc = persistenceController.container.viewContext
                            Library.shared.clear(moc: moc)
                        }
                        deleteConfirmationShown = false
                    }
                }
                .environmentObject(player)
                .environmentObject(library)
        }
        .windowToolbarStyle(.unified(showsTitle: false))
        .commands {
            SidebarCommands()
            CommandGroup(after: .importExport) {
                Button("Add songs") {
                    let openPanel = NSOpenPanel()
                    openPanel.allowedFileTypes = ["mp3", "flac"]
                    openPanel.canChooseFiles = true
                    openPanel.canChooseDirectories = false
                    openPanel.allowsMultipleSelection = true
                    openPanel.begin { result in
                        if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                            for url in openPanel.urls {
                                do {
                                    let moc = persistenceController.container.viewContext
                                    Library.shared.loadSong(filePath: url.path, moc: moc)
                                }
                            }
                        }
                    }
                }
                .keyboardShortcut("O", modifiers: [.command])
                Button("Clear Library") {
                    deleteConfirmationShown = true
                }
            }
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }

        Window("Artwork", id: "artwork-image") {
            HStack {
                if let artwork = player.artwork {
                    Image(nsImage: artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Text("No artwork")
                }
            }
        }
    }
}
