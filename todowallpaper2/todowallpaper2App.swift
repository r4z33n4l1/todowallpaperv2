//
//  todowallpaper2App.swift
//  todowallpaper2
//
//  Created by Razeen Ali on 2026-03-22.
//

import SwiftUI
import SwiftData

@main
struct todowallpaper2App: App {
    var body: some Scene {
        WindowGroup {
            TodoListView()
        }
        .modelContainer(sharedModelContainer)
    }
}
// Shared ModelContainer for app, widget, and intents
// Uses App Group storage to enable data sharing
let sharedModelContainer: ModelContainer = {
    let schema = Schema([TodoItem.self])
    
    // IMPORTANT: For widget/intent support, configure to use App Group storage
    // For now, using default storage. To enable widget/intent access:
    // 1. Add App Group capability to both app and widget targets
    // 2. Use group.com.yourapp.todowallpaper as the identifier
    // 3. Uncomment the custom URL configuration below
    
    // Default configuration (local to app only)
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    
    // App Group configuration (uncomment when ready for widgets/intents):
    /*
    let config = ModelConfiguration(
        schema: schema,
        url: URL.appGroupContainer.appending(path: "TodoWallpaper.sqlite"),
        cloudKitDatabase: .none
    )
    */
    
    do {
        return try ModelContainer(for: schema, configurations: [config])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()

