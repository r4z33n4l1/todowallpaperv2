//
//  AppGroupContainer.swift
//  todowallpaper2
//
//  Created by Razeen Ali on 2026-03-22.
//

import Foundation

extension URL {
    /// Shared App Group container for sharing data between app and widget extension.
    /// Make sure to add "group.com.yourapp.todowallpaper" to both app and widget targets
    /// in Signing & Capabilities → App Groups.
    static var appGroupContainer: URL {
        guard let url = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.r4z33n.todowallpaper2"
        ) else {
            fatalError("App Group container not configured. Add 'group.r4z33n.todowallpaper2' to Signing & Capabilities → App Groups.")
        }
        return url
    }
}
