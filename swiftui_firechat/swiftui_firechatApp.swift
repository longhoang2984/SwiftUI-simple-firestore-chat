//
//  swiftui_firechatApp.swift
//  swiftui_firechat
//
//  Created by Hoang Cuu Long on 11/30/21.
//

import SwiftUI

@main
struct swiftui_firechatApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MessagesView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
