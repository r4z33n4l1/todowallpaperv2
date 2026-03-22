//
//  AutoWallpaperGuideView.swift
//  todowallpaper2
//
//  Created by Razeen Ali on 2026-03-22.
//

import SwiftUI

/// Step-by-step checklist for setting up automatic wallpaper updates via Shortcuts automations.
struct AutoWallpaperGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("setup_step_1") private var step1Done = false
    @AppStorage("setup_step_2") private var step2Done = false
    @AppStorage("setup_step_3") private var step3Done = false
    @AppStorage("setup_step_4") private var step4Done = false
    @AppStorage("setup_step_5") private var step5Done = false

    private var completedCount: Int {
        [step1Done, step2Done, step3Done, step4Done, step5Done].filter { $0 }.count
    }

    private var allDone: Bool { completedCount == 5 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero
                    heroSection

                    // Progress
                    progressBar

                    // Checklist
                    VStack(spacing: 12) {
                        checklistItem(
                            step: 1,
                            isChecked: $step1Done,
                            icon: "clock.badge.checkmark",
                            title: "Create a new Automation",
                            detail: "Open the Shortcuts app → Automations tab → tap +. Choose a trigger: \"Time of Day\" (e.g. 7 AM daily), \"When App is Opened/Closed\", or \"When Charger Connected\"."
                        )

                        checklistItem(
                            step: 2,
                            isChecked: $step2Done,
                            icon: "wand.and.stars",
                            title: "Add \"Generate Todo Wallpaper\"",
                            detail: "In your new automation, tap \"Add Action\" and search for \"Generate Todo Wallpaper\". This action renders your current task list as a fresh wallpaper image."
                        )

                        checklistItem(
                            step: 3,
                            isChecked: $step3Done,
                            icon: "photo.on.rectangle",
                            title: "Add \"Set Wallpaper\"",
                            detail: "Tap \"Add Action\" again and search for \"Set Wallpaper\". It automatically receives the generated image. Choose Lock Screen, Home Screen, or both."
                        )

                        criticalChecklistItem(
                            step: 4,
                            isChecked: $step4Done,
                            icon: "eye.slash",
                            title: "Turn OFF \"Show Preview\"",
                            detail: "In the Set Wallpaper action, disable \"Show Preview\". Without this, you'll get a confirmation popup every time — defeating the purpose of automation.",
                            color: .orange
                        )

                        criticalChecklistItem(
                            step: 5,
                            isChecked: $step5Done,
                            icon: "bolt.fill",
                            title: "Set to \"Run Immediately\"",
                            detail: "When saving the automation, set it to \"Run Immediately\" (not \"After Confirmation\") and turn OFF \"Notify When Run\". This makes it fully silent.",
                            color: .cyan
                        )
                    }
                    .padding(.horizontal)

                    // Success state
                    if allDone {
                        successBanner
                            .padding(.horizontal)
                            .transition(.scale.combined(with: .opacity))
                    }

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

                    // Reset link
                    if completedCount > 0 {
                        Button("Reset checklist") {
                            withAnimation {
                                step1Done = false
                                step2Done = false
                                step3Done = false
                                step4Done = false
                                step5Done = false
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.3))
                    }

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

            Text("Follow these 5 steps to set up a Shortcuts automation that silently updates your wallpaper with your latest tasks.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(completedCount) of 5 steps")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.6))
                Spacer()
                Text(allDone ? "All done!" : "\(5 - completedCount) remaining")
                    .font(.caption)
                    .foregroundStyle(allDone ? .green : .white.opacity(0.4))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.cyan, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(completedCount) / 5.0)
                        .animation(.spring(duration: 0.4), value: completedCount)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal)
    }

    // MARK: - Checklist Item

    private func checklistItem(step: Int, isChecked: Binding<Bool>, icon: String, title: String, detail: String) -> some View {
        Button {
            withAnimation(.spring(duration: 0.3, bounce: 0.2)) {
                isChecked.wrappedValue.toggle()
            }
        } label: {
            HStack(alignment: .top, spacing: 14) {
                // Checkbox
                ZStack {
                    Circle()
                        .stroke(isChecked.wrappedValue ? Color.clear : Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 28, height: 28)

                    if isChecked.wrappedValue {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.cyan, .green],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 28, height: 28)

                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                    } else {
                        Text("\(step)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: icon)
                            .font(.caption)
                            .foregroundStyle(isChecked.wrappedValue ? .green : .cyan)
                        Text(title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(isChecked.wrappedValue ? .white.opacity(0.5) : .white)
                            .strikethrough(isChecked.wrappedValue, color: .white.opacity(0.3))
                    }

                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(isChecked.wrappedValue ? 0.3 : 0.6))
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial.opacity(isChecked.wrappedValue ? 0.5 : 1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isChecked.wrappedValue
                                    ? Color.green.opacity(0.15)
                                    : Color.white.opacity(0.08),
                                lineWidth: 1
                            )
                    )
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Critical Checklist Item

    private func criticalChecklistItem(step: Int, isChecked: Binding<Bool>, icon: String, title: String, detail: String, color: Color) -> some View {
        Button {
            withAnimation(.spring(duration: 0.3, bounce: 0.2)) {
                isChecked.wrappedValue.toggle()
            }
        } label: {
            HStack(alignment: .top, spacing: 14) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isChecked.wrappedValue ? Color.clear : color.opacity(0.4), lineWidth: 2)
                        .frame(width: 28, height: 28)

                    if isChecked.wrappedValue {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(color)
                            .frame(width: 28, height: 28)

                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                    } else {
                        Text("\(step)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(color.opacity(0.7))
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: icon)
                            .font(.caption)
                            .foregroundStyle(color)
                        Text(title)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(isChecked.wrappedValue ? color.opacity(0.5) : color)
                            .strikethrough(isChecked.wrappedValue, color: color.opacity(0.3))

                        if !isChecked.wrappedValue {
                            Text("IMPORTANT")
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundStyle(color)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(color.opacity(0.2)))
                        }
                    }

                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(isChecked.wrappedValue ? 0.3 : 0.6))
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(isChecked.wrappedValue ? 0.03 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isChecked.wrappedValue
                                    ? color.opacity(0.1)
                                    : color.opacity(0.2),
                                lineWidth: 1
                            )
                    )
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Success Banner

    private var successBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title2)
                .foregroundStyle(.green)

            VStack(alignment: .leading, spacing: 2) {
                Text("Setup Complete!")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                Text("Your wallpaper will now update automatically.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.green.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.green.opacity(0.2), lineWidth: 1)
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
                question: "Why does the app open briefly?",
                answer: "The wallpaper renderer needs a UI context to draw your task list. The app opens, generates the image, and the shortcut sets it — all in about 2 seconds."
            )

            faqItem(
                question: "What if Set Wallpaper fails sometimes?",
                answer: "iOS 18 has a known bug where \"Set Wallpaper\" can fail on some devices. A workaround: create a second automation with the same actions, delayed by 1 minute, as a backup."
            )

            faqItem(
                question: "Can I use this with Focus modes?",
                answer: "Yes! Set the automation trigger to a specific Focus mode, so your wallpaper updates when you switch to Work, Personal, etc."
            )

            faqItem(
                question: "What triggers work best?",
                answer: "\"Time of Day\" (e.g. 7 AM) is most popular. \"When App is Closed\" also works great — your wallpaper updates every time you leave the app after editing your tasks."
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
