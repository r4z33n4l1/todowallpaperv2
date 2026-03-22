//
//  PhotoLibraryManager.swift
//  todowallpaper2
//
//  Created by Razeen Ali on 2026-03-22.
//

import Photos
import UIKit

/// Service for managing photo library operations, specifically saving wallpapers to a custom album.
class PhotoLibraryManager {

    static let albumName = "TodoWallpaper"

    enum AuthResult {
        case authorized
        case denied
    }

    /// Request photo library read/write permission (needed to find/create albums).
    /// If previously denied, returns `.denied` so the caller can offer to open Settings.
    static func requestAuthorization() async -> AuthResult {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        switch status {
        case .authorized, .limited:
            return .authorized
        default:
            return .denied
        }
    }

    /// Find the TodoWallpaper album, if it exists
    private static func findAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        return PHAssetCollection.fetchAssetCollections(
            with: .album, subtype: .any, options: fetchOptions
        ).firstObject
    }

    /// Save image to the "TodoWallpaper" album, creating it if needed.
    static func saveToAlbum(_ image: UIImage) async throws {
        let authResult = await requestAuthorization()
        guard authResult == .authorized else {
            throw PhotoError.notAuthorized
        }

        // Fetch album BEFORE the change block to avoid deadlock
        let existingAlbum = findAlbum()

        if let album = existingAlbum {
            // Album exists — add image to it
            try await PHPhotoLibrary.shared().performChanges {
                let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                guard let placeholder = assetRequest.placeholderForCreatedAsset else { return }
                let albumRequest = PHAssetCollectionChangeRequest(for: album)
                albumRequest?.addAssets([placeholder] as NSFastEnumeration)
            }
        } else {
            // Create album first, then add image in a second change block
            var collectionLocalID: String?
            try await PHPhotoLibrary.shared().performChanges {
                let createRequest = PHAssetCollectionChangeRequest
                    .creationRequestForAssetCollection(withTitle: albumName)
                collectionLocalID = createRequest.placeholderForCreatedAssetCollection.localIdentifier
            }

            // Now fetch the newly created album and add the image
            guard let localID = collectionLocalID,
                  let newAlbum = PHAssetCollection.fetchAssetCollections(
                      withLocalIdentifiers: [localID],
                      options: nil
                  ).firstObject else {
                throw PhotoError.albumCreationFailed
            }

            try await PHPhotoLibrary.shared().performChanges {
                let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                guard let assetPlaceholder = assetRequest.placeholderForCreatedAsset else { return }
                let albumRequest = PHAssetCollectionChangeRequest(for: newAlbum)
                albumRequest?.addAssets([assetPlaceholder] as NSFastEnumeration)
            }
        }
    }

    enum PhotoError: LocalizedError {
        case notAuthorized
        case albumCreationFailed

        var errorDescription: String? {
            switch self {
            case .notAuthorized:
                return "Photo library access is required to save wallpapers. Please enable it in Settings."
            case .albumCreationFailed:
                return "Failed to create the TodoWallpaper album."
            }
        }
    }
}
