//
//  EternalBeastApp.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 02/07/2021.
//

import SwiftUI

@main
struct EternalBeastApp: App {
    let persistenceController = PersistenceController.shared

    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .commands {
            SidebarCommands()
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}
