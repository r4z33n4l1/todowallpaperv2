//
//  WallpaperTemplateView.swift
//  todowallpaper2
//
//  Created by Razeen Ali on 2026-03-22.
//

import SwiftUI

/// The actual wallpaper layout that gets rendered to an image.
/// This view is designed to be rendered at full device pixel resolution.
struct WallpaperTemplateView: View {
    let todos: [TodoItem]
    let deviceSize: CGSize

    private var completedCount: Int {
        todos.filter(\.isCompleted).count
    }

    private var progress: Double {
        guard !todos.isEmpty else { return 0 }
        return Double(completedCount) / Double(todos.count)
    }

    /// Scale factor relative to a 390pt-wide reference (iPhone 15 Pro in points).
    /// Since we render at full pixel resolution (~1179px), this gives us ~3x,
    /// making font sizes match what you'd see on the actual screen.
    private var scaleFactor: CGFloat {
        deviceSize.width / 390
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "0B0B1A"),
                    Color(hex: "111128"),
                    Color(hex: "0F1B2D")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Subtle radial glow
            RadialGradient(
                colors: [Color.cyan.opacity(0.06), .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: deviceSize.width * 0.8
            )

            VStack(alignment: .leading, spacing: 20 * scaleFactor) {
                Spacer()
                    .frame(height: 140 * scaleFactor) // Status bar clearance

                // Stats bar
                HStack(spacing: 16 * scaleFactor) {
                    // Progress ring
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.08), lineWidth: 5 * scaleFactor)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                LinearGradient(
                                    colors: [.cyan, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 5 * scaleFactor, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))

                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 13 * scaleFactor, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 48 * scaleFactor, height: 48 * scaleFactor)

                    VStack(alignment: .leading, spacing: 2 * scaleFactor) {
                        Text("\(completedCount) of \(todos.count) done")
                            .font(.system(size: 16 * scaleFactor, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.8))
                        Text("tasks completed")
                            .font(.system(size: 13 * scaleFactor))
                            .foregroundStyle(.white.opacity(0.4))
                    }

                    Spacer()
                }
                .padding(16 * scaleFactor)
                .background(
                    RoundedRectangle(cornerRadius: 16 * scaleFactor)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16 * scaleFactor)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )

                // Todo items (show up to 10)
                VStack(spacing: 6 * scaleFactor) {
                    ForEach(Array(todos.prefix(10))) { todo in
                        HStack(spacing: 12 * scaleFactor) {
                            // Checkbox
                            ZStack {
                                Circle()
                                    .stroke(
                                        todo.isCompleted
                                            ? Color.clear
                                            : Color.white.opacity(0.25),
                                        lineWidth: 2 * scaleFactor
                                    )
                                    .frame(width: 22 * scaleFactor, height: 22 * scaleFactor)

                                if todo.isCompleted {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.cyan, .green.opacity(0.8)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 22 * scaleFactor, height: 22 * scaleFactor)

                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11 * scaleFactor, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }

                            Text(todo.title)
                                .font(.system(size: 17 * scaleFactor, weight: todo.isCompleted ? .regular : .medium))
                                .strikethrough(todo.isCompleted, color: .white.opacity(0.3))
                                .foregroundStyle(todo.isCompleted ? .white.opacity(0.35) : .white.opacity(0.9))
                                .lineLimit(1)

                            Spacer()
                        }
                        .padding(.horizontal, 16 * scaleFactor)
                        .padding(.vertical, 12 * scaleFactor)
                        .background(
                            RoundedRectangle(cornerRadius: 12 * scaleFactor)
                                .fill(Color.white.opacity(todo.isCompleted ? 0.03 : 0.06))
                        )
                    }
                }

                // Overflow indicator
                if todos.count > 10 {
                    Text("+\(todos.count - 10) more tasks")
                        .font(.system(size: 14 * scaleFactor, weight: .medium))
                        .foregroundStyle(.cyan.opacity(0.6))
                        .padding(.leading, 8 * scaleFactor)
                }

                Spacer()

                // Footer
                HStack {
                    Spacer()
                    Text("Taskwall")
                        .font(.system(size: 11 * scaleFactor, weight: .medium))
                        .foregroundStyle(.white.opacity(0.15))
                        .tracking(2)
                    Spacer()
                }
                .padding(.bottom, 50 * scaleFactor)
            }
            .padding(.horizontal, 32 * scaleFactor)
        }
        .frame(width: deviceSize.width, height: deviceSize.height)
    }
}

#Preview {
    let sampleTodos = [
        TodoItem(title: "Buy groceries", isCompleted: false, sortOrder: 0),
        TodoItem(title: "Call dentist", isCompleted: true, sortOrder: 1),
        TodoItem(title: "Ship feature", isCompleted: false, sortOrder: 2),
        TodoItem(title: "Review pull requests", isCompleted: false, sortOrder: 3),
        TodoItem(title: "Update documentation", isCompleted: true, sortOrder: 4),
    ]

    WallpaperTemplateView(
        todos: sampleTodos,
        deviceSize: CGSize(width: 1179, height: 2556)
    )
    .scaleEffect(0.3)
}
