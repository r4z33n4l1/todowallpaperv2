//
//  GenerateWallpaperIntent.swift
//  todowallpaper2
//
//  Created by Razeen Ali on 2026-03-22.
//

import AppIntents
import SwiftData
import UIKit
import UniformTypeIdentifiers

/// App Intent that generates a wallpaper from the current todo list.
/// This can be triggered from Shortcuts, Siri, or automation.
struct GenerateWallpaperIntent: AppIntent {
    static let title: LocalizedStringResource = "Generate Todo Wallpaper"
    static let description: IntentDescription = IntentDescription(
        "Renders your current todo list as a wallpaper image and saves it to the TodoWallpaper album.",
        categoryName: "Productivity"
    )
    
    // Open the app briefly — ImageRenderer needs a UI context to render
    static let openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
        // Access the shared SwiftData container
        let container = sharedModelContainer
        let context = ModelContext(container)
        
        // Fetch all todos
        let descriptor = FetchDescriptor<TodoItem>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        let todos = try context.fetch(descriptor)
        
        // Ensure we have at least one todo
        guard !todos.isEmpty else {
            throw GenerateError.noTodos
        }
        
        // Generate the wallpaper image
        guard let image = WallpaperGenerator.generate(todos: todos) else {
            throw GenerateError.renderFailed
        }
        
        // Convert to JPEG data
        guard let data = image.jpegData(compressionQuality: 0.95) else {
            throw GenerateError.compressionFailed
        }
        
        // Save to photo library album
        do {
            try await PhotoLibraryManager.saveToAlbum(image)
        } catch {
            // Continue even if album save fails — we still return the file
            print("Warning: Failed to save to album: \(error)")
        }
        
        // Return the image as an IntentFile so Shortcuts can pipe it
        // to "Set Wallpaper" or any other action
        let file = IntentFile(
            data: data,
            filename: "TodoWallpaper-\(Date().formatted(.iso8601)).jpg",
            type: .jpeg
        )
        
        return .result(
            value: file,
            dialog: "Your wallpaper has been generated with \(todos.count) todos."
        )
    }
    
    enum GenerateError: Error, CustomLocalizedStringResourceConvertible {
        case noTodos
        case renderFailed
        case compressionFailed
        
        var localizedStringResource: LocalizedStringResource {
            switch self {
            case .noTodos:
                return "You don't have any todos yet. Add some todos first."
            case .renderFailed:
                return "Failed to render the wallpaper image."
            case .compressionFailed:
                return "Failed to compress the wallpaper image."
            }
        }
    }
}
