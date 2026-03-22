//
//  WallpaperGenerator.swift
//  todowallpaper2
//
//  Created by Razeen Ali on 2026-03-22.
//

import SwiftUI
import UIKit

/// Service for generating wallpaper images from todo data using ImageRenderer.
class WallpaperGenerator {

    // Standard iPhone pixel dimensions for wallpaper generation
    // Used as fallback when UIScreen isn't available (e.g. AppIntents background)
    private static let defaultPixelSize = CGSize(width: 1170, height: 2532) // iPhone 14

    /// Renders the wallpaper template to a UIImage at the correct device resolution.
    /// Must be called from the main actor.
    @MainActor
    static func generate(todos: [TodoItem]) -> UIImage? {
        let pixelSize: CGSize

        // UIScreen.main is available when the app has a UI context.
        // When launched by AppIntents/Shortcuts, it may not be ready yet,
        // so we fall back to standard dimensions.
        let screen = UIScreen.main
        let screenSize = screen.bounds.size
        let scale = screen.scale

        if screenSize.width > 0 && screenSize.height > 0 {
            pixelSize = CGSize(
                width: screenSize.width * scale,
                height: screenSize.height * scale
            )
        } else {
            pixelSize = defaultPixelSize
        }

        let template = WallpaperTemplateView(
            todos: todos,
            deviceSize: pixelSize
        )

        let renderer = ImageRenderer(content: template)

        // CRITICAL: Set scale to 1.0 because we already sized the view
        // at full pixel dimensions. Setting scale to screen scale here
        // would double-scale the output.
        renderer.scale = 1.0

        return renderer.uiImage
    }

    /// Generates a wallpaper with custom size (useful for different device types)
    @MainActor
    static func generate(todos: [TodoItem], size: CGSize, scale: CGFloat = 1.0) -> UIImage? {
        let pixelSize = CGSize(
            width: size.width * scale,
            height: size.height * scale
        )

        let template = WallpaperTemplateView(
            todos: todos,
            deviceSize: pixelSize
        )

        let renderer = ImageRenderer(content: template)
        renderer.scale = 1.0

        return renderer.uiImage
    }
}
