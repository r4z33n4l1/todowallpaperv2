//
//  WallpaperPreviewView.swift
//  todowallpaper2
//
//  Created by Razeen Ali on 2026-03-22.
//

import SwiftUI

/// Device-frame preview view before saving the wallpaper.
struct WallpaperPreviewView: View {
    let todos: [TodoItem]
    @Environment(\.dismiss) private var dismiss

    @State private var generatedImage: UIImage?
    @State private var isGenerating = false
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var showPermissionDenied = false
    @State private var previewScale: CGFloat = 0.9
    @State private var previewOpacity: Double = 0

    var body: some View {
        NavigationStack {
            ZStack {
                // Dark gradient background
                LinearGradient(
                    colors: [Color(hex: "0F0F1A"), Color(hex: "1A1A2E")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                if let image = generatedImage {
                    VStack(spacing: 24) {
                        Spacer()

                        // Phone frame preview
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 520)
                            .clipShape(RoundedRectangle(cornerRadius: 44))
                            .overlay(
                                RoundedRectangle(cornerRadius: 44)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.3), .white.opacity(0.05)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            )
                            .shadow(color: .cyan.opacity(0.15), radius: 30, y: 10)
                            .padding(.horizontal, 40)
                            .scaleEffect(previewScale)
                            .opacity(previewOpacity)

                        Spacer()

                        // Save button
                        VStack(spacing: 16) {
                            Button {
                                Task {
                                    await saveToPhotos()
                                }
                            } label: {
                                HStack(spacing: 10) {
                                    if isSaving {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "square.and.arrow.down")
                                            .font(.body.weight(.semibold))
                                        Text("Save to Photos")
                                            .font(.body.weight(.semibold))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [.cyan, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .disabled(isSaving)

                            Text("Saved wallpapers appear in your **Taskwall** album")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.4))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                    }
                } else if isGenerating {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.cyan)

                        Text("Generating wallpaper...")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white.opacity(0.7))
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("Wallpaper Saved", isPresented: $showSuccess) {
                Button("Done") {
                    dismiss()
                }
            } message: {
                Text("Your wallpaper has been saved to the Taskwall album in Photos.")
            }
            .alert("Photo Access Required", isPresented: $showPermissionDenied) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Taskwall needs access to your photo library to save wallpapers. Please enable it in Settings.")
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
        .task {
            await generateWallpaper()
        }
    }

    @MainActor
    private func generateWallpaper() async {
        isGenerating = true
        defer { isGenerating = false }

        try? await Task.sleep(for: .milliseconds(100))

        generatedImage = WallpaperGenerator.generate(todos: todos)

        if generatedImage == nil {
            errorMessage = "Failed to generate wallpaper image."
            showError = true
        } else {
            // Animate preview in
            withAnimation(.spring(duration: 0.6, bounce: 0.2)) {
                previewScale = 1.0
                previewOpacity = 1.0
            }
        }
    }

    private func saveToPhotos() async {
        guard let image = generatedImage else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            try await PhotoLibraryManager.saveToAlbum(image)
            showSuccess = true
        } catch is PhotoLibraryManager.PhotoError {
            showPermissionDenied = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    let sampleTodos = [
        TodoItem(title: "Buy groceries", isCompleted: false, sortOrder: 0),
        TodoItem(title: "Call dentist", isCompleted: true, sortOrder: 1),
        TodoItem(title: "Ship feature", isCompleted: false, sortOrder: 2),
    ]

    return WallpaperPreviewView(todos: sampleTodos)
}
