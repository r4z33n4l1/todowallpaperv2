//
//  TodoShortcutsProvider.swift
//  todowallpaper2
//
//  Created by Razeen Ali on 2026-03-22.
//

import AppIntents

/// Auto-registers shortcuts with the system on app install.
/// Users will see "Generate Todo Wallpaper" in the Shortcuts app immediately.
struct TodoShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GenerateWallpaperIntent(),
            phrases: [
                "Generate wallpaper with \(.applicationName)",
                "Update my \(.applicationName)",
                "Refresh \(.applicationName) wallpaper",
                "Create wallpaper in \(.applicationName)"
            ],
            shortTitle: "Generate Wallpaper",
            systemImageName: "photo.on.rectangle"
        )
    }
}
