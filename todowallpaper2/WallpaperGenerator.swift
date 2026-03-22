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
    
    /// Renders the wallpaper template to a UIImage at the correct device resolution.
    /// Must be called from the main actor.
    @MainActor
    static func generate(todos: [TodoItem]) -> UIImage? {
        // Use UIScreen if available (in-app), otherwise fall back to iPhone 15 Pro dimensions.
        // This fallback is needed when running from Shortcuts/Intents without a UI context.
        let screenSize: CGSize
        let scale: CGFloat
        if let mainScreen = UIScreen.value(forKey: "mainScreen") as? UIScreen {
            screenSize = mainScreen.bounds.size
            scale = mainScreen.scale
        } else {
            screenSize = CGSize(width: 393, height: 852) // iPhone 15 Pro points
            scale = 3.0
        }

        let pixelSize = CGSize(
            width: screenSize.width * scale,
            height: screenSize.height * scale
        )
        
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
