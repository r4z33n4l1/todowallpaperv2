//
//  AutoWallpaperGuideView.swift
//  todowallpaper2
//
//  Created by Razeen Ali on 2026-03-22.
//

import SwiftUI

/// Step-by-step guide for setting up automatic wallpaper updates via Shortcuts automations.
struct AutoWallpaperGuideView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero
                    heroSection

                    // Steps
                    VStack(spacing: 16) {
                        stepCard(
                            number: 1,
                            icon: "clock.badge.checkmark",
                            title: "Open Shortcuts App",
                            subtitle: "Go to the Automations tab",
                            detail: "Tap the + button to create a new automation. Choose a trigger like \"Time of Day\" (e.g. 7:00 AM daily), \"When Charger Connected\", or any trigger you prefer."
                        )

                        stepCard(
                            number: 2,
                            icon: "wand.and.stars",
                            title: "Add \"Generate Todo Wallpaper\"",
                            subtitle: "Your first action",
                            detail: "Search for \"Generate Todo Wallpaper\" — it's already registered from this app. This will render your current todo list as a fresh wallpaper image every time it runs."
                        )

                        stepCard(
                            number: 3,
                            icon: "photo.on.rectangle",
                            title: "Add \"Set Wallpaper\"",
                            subtitle: "Your second action",
                            detail: "Add the \"Set Wallpaper\" action right after. It will automatically receive the generated image. Choose Lock Screen, Home Screen, or both."
                        )

                        criticalToggleCard(
                            icon: "eye.slash",
                            title: "Turn OFF \"Show Preview\"",
                            detail: "This is critical! In the Set Wallpaper action, disable \"Show Preview\". Otherwise you'll get a confirmation popup every time the automation runs.",
                            color: .orange
                        )

                        criticalToggleCard(
                            icon: "bolt.fill",
                            title: "Set to \"Run Immediately\"",
                            detail: "When saving the automation, set it to \"Run Immediately\" (not \"After Confirmation\") and turn OFF \"Notify When Run\". This makes it fully silent — no popups, no banners.",
                            color: .cyan
                        )
                    }
                    .padding(.horizontal)

                    // Open Shortcuts button
                    Button {
                        if let url = URL(string: "shortcuts://") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.up.forward.app")
                                .font(.body.weight(.semibold))
                            Text("Open Shortcuts App")
                                .font(.body.weight(.semibold))
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
                    .padding(.horizontal)

                    // FAQ section
                    faqSection
                        .padding(.horizontal)

                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
            .background {
                LinearGradient(
                    colors: [Color(hex: "0F0F1A"), Color(hex: "1A1A2E")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
            .navigationTitle("Auto Wallpaper")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.cyan.opacity(0.2), .purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: "sparkles")
                    .font(.system(size: 36))
                    .foregroundStyle(.cyan)
            }

            Text("Auto-Update Your Wallpaper")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)

            Text("Set up a Shortcuts automation to automatically update your wallpaper with your latest todos — no taps required.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }

    // MARK: - Step Card

    private func stepCard(number: Int, icon: String, title: String, subtitle: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            // Step number
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.cyan.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)

                Text("\(number)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundStyle(.cyan)
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                }

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.cyan.opacity(0.8))

                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        }
    }

    // MARK: - Critical Toggle Card

    private func criticalToggleCard(icon: String, title: String, detail: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.2))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(color)

                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        }
    }

    // MARK: - FAQ

    private var faqSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("FAQ")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white.opacity(0.5))
                .textCase(.uppercase)
                .tracking(1.2)

            faqItem(
                question: "Do I need to open the app first?",
                answer: "Yes — the automation briefly opens the app to generate the wallpaper, then it's set automatically. This happens in about 2 seconds."
            )

            faqItem(
                question: "Why does the app open briefly?",
                answer: "The wallpaper renderer needs a UI context to draw your todo list. The app opens, generates the image, and the shortcut sets it — all automatically."
            )

            faqItem(
                question: "What if Set Wallpaper fails sometimes?",
                answer: "iOS 18 has a known bug where \"Set Wallpaper\" can fail on some devices. A workaround is to create a second automation with the same actions, delayed by 1 minute, as a backup."
            )

            faqItem(
                question: "Can I use this with Focus modes?",
                answer: "Yes! You can set the automation trigger to a specific Focus mode, so your wallpaper updates when you switch to Work, Personal, etc."
            )
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        }
    }

    private func faqItem(question: String, answer: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(question)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.8))
            Text(answer)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    AutoWallpaperGuideView()
}
