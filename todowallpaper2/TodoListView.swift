//
//  TodoListView.swift
//  todowallpaper2
//
//  Created by Razeen Ali on 2026-03-22.
//

import SwiftUI
import SwiftData

/// Main todo list interface with add, edit, delete, and wallpaper generation.
struct TodoListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \TodoItem.sortOrder)
    private var todos: [TodoItem]

    @State private var showingAutoSetupGuide = false
    @State private var showingTodoSheet = false
    @State private var sheetTodo: TodoItem?       // nil = adding, non-nil = editing
    @State private var sheetText = ""
    @FocusState private var todoFieldFocused: Bool
    @State private var isSavingWallpaper = false
    @State private var wallpaperSaved = false
    @State private var wallpaperError: String?
    @State private var showPermissionDenied = false
    @AppStorage("hasSeenSetupGuide") private var hasSeenSetupGuide = false

    private var stats: (completed: Int, total: Int, progress: Double) {
        TodoStore.calculateStats(for: todos)
    }

    private var incompleteTodos: [TodoItem] {
        todos.filter { !$0.isCompleted }
    }

    private var completedTodos: [TodoItem] {
        todos.filter { $0.isCompleted }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(hex: "0F0F1A"), Color(hex: "1A1A2E"), Color(hex: "16213E")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Stats card
                    if !todos.isEmpty {
                        statsCard
                            .padding(.horizontal)
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                    }

                    // Todo list
                    List {
                        // Incomplete section
                        if !incompleteTodos.isEmpty {
                            Section {
                                ForEach(incompleteTodos) { todo in
                                    TodoRow(todo: todo, onEdit: {
                                        sheetTodo = todo
                                        sheetText = todo.title
                                        showingTodoSheet = true
                                        todoFieldFocused = true
                                    }, onDelete: {
                                        withAnimation(.spring(duration: 0.3)) {
                                            modelContext.delete(todo)
                                        }
                                    })
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                                }
                                .onMove { source, destination in
                                    moveTodos(in: incompleteTodos, from: source, to: destination)
                                }
                            } header: {
                                sectionHeader("Tasks", count: incompleteTodos.count, showAdd: true)
                            }
                        }

                        // Completed section
                        if !completedTodos.isEmpty {
                            Section {
                                ForEach(completedTodos) { todo in
                                    TodoRow(todo: todo, onEdit: {
                                        sheetTodo = todo
                                        sheetText = todo.title
                                        showingTodoSheet = true
                                        todoFieldFocused = true
                                    }, onDelete: {
                                        withAnimation(.spring(duration: 0.3)) {
                                            modelContext.delete(todo)
                                        }
                                    })
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                                }
                                .onMove { source, destination in
                                    moveTodos(in: completedTodos, from: source, to: destination)
                                }
                            } header: {
                                sectionHeader("Completed", count: completedTodos.count)
                            }
                        }

                        // Empty state
                        if todos.isEmpty {
                            emptyState
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .scrollDismissesKeyboard(.interactively)
                }
            }
            .navigationTitle("Taskwall")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingAutoSetupGuide = true
                    } label: {
                        Image(systemName: "questionmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.cyan)
                            .font(.title3)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            Task { await generateAndSave() }
                        } label: {
                            if isSavingWallpaper {
                                ProgressView()
                                    .tint(.cyan)
                            } else {
                                Image(systemName: wallpaperSaved ? "checkmark.circle.fill" : "photo.on.rectangle")
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(wallpaperSaved ? .green : .cyan)
                                    .font(.title3)
                            }
                        }
                        .disabled(todos.isEmpty || isSavingWallpaper)

                        Button {
                            sheetTodo = nil
                            sheetText = ""
                            showingTodoSheet = true
                            todoFieldFocused = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.cyan)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAutoSetupGuide) {
                AutoWallpaperGuideView()
            }
            .overlay {
                if showingTodoSheet {
                    todoModal
                }
            }
            .overlay(alignment: .top) {
                if wallpaperSaved {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Saved to Gallery")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: Capsule())
                    .shadow(color: .black.opacity(0.3), radius: 10, y: 4)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 8)
                }
            }
            .animation(.spring(duration: 0.4), value: wallpaperSaved)
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
            .alert("Error", isPresented: Binding(
                get: { wallpaperError != nil },
                set: { if !$0 { wallpaperError = nil } }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(wallpaperError ?? "")
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if !hasSeenSetupGuide {
                hasSeenSetupGuide = true
                showingAutoSetupGuide = true
            }
        }
    }

    // MARK: - Stats Card

    private var statsCard: some View {
        HStack(spacing: 16) {
            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: stats.progress)
                    .stroke(
                        LinearGradient(
                            colors: [.cyan, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 0.6), value: stats.progress)

                Text("\(Int(stats.progress * 100))%")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(stats.completed) of \(stats.total) done")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)

                Text(motivationalText)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()

            // Generate button
            Button {
                Task { await generateAndSave() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "wand.and.stars")
                    Text("Generate")
                        .font(.caption.weight(.semibold))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        colors: [.cyan.opacity(0.8), .purple.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
            .disabled(todos.isEmpty || isSavingWallpaper)
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
    }

    private var motivationalText: String {
        switch stats.progress {
        case 0: return "Let's get started!"
        case 0..<0.25: return "You're on your way"
        case 0.25..<0.5: return "Making progress"
        case 0.5..<0.75: return "More than halfway!"
        case 0.75..<1: return "Almost there!"
        case 1: return "All done! Nice work"
        default: return ""
        }
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String, count: Int, showAdd: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white.opacity(0.5))
                .textCase(.uppercase)
                .tracking(1.2)

            Text("\(count)")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white.opacity(0.4))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(.white.opacity(0.1)))

            Spacer()

            if showAdd {
                Button {
                    sheetTodo = nil
                    sheetText = ""
                    showingTodoSheet = true
                    todoFieldFocused = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.caption.weight(.bold))
                        Text("Add New Task")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.cyan)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(.cyan.opacity(0.12)))
                }
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 2)
        .padding(.horizontal, 4)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checklist")
                .font(.system(size: 48))
                .foregroundStyle(.white.opacity(0.2))

            Text("No todos yet")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white.opacity(0.5))

            Text("Tap + to add your first task")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.3))

            Button {
                sheetTodo = nil
                sheetText = ""
                showingTodoSheet = true
                todoFieldFocused = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 44))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.cyan)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    // MARK: - Todo Modal

    private var todoModal: some View {
        ZStack(alignment: .bottom) {
            // Dimmed backdrop — tap to dismiss
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { dismissTodoModal() }

            // Input card pinned above the keyboard
            VStack(spacing: 16) {
                HStack {
                    Button("Cancel") { dismissTodoModal() }
                        .foregroundStyle(.white.opacity(0.6))

                    Spacer()

                    Text(sheetTodo != nil ? "Edit Task" : "New Task")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)

                    Spacer()

                    Button("Save") { saveTodo() }
                        .foregroundStyle(.cyan)
                        .fontWeight(.semibold)
                        .disabled(sheetText.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                TextField(
                    sheetTodo != nil ? "Task name" : "What do you need to do?",
                    text: $sheetText
                )
                .font(.body)
                .foregroundStyle(.white)
                .tint(.cyan)
                .focused($todoFieldFocused)
                .onSubmit { saveTodo() }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)
            .background(
                UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                    .fill(Color(hex: "1A1A2E"))
                    .ignoresSafeArea(.container, edges: .bottom)
            )
        }
        .transition(.opacity.animation(.easeOut(duration: 0.15)))
    }

    private func saveTodo() {
        let trimmed = sheetText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        if let todo = sheetTodo {
            todo.title = trimmed
        } else {
            let maxOrder = todos.map(\.sortOrder).max() ?? -1
            let todo = TodoItem(title: trimmed, sortOrder: maxOrder + 1)
            modelContext.insert(todo)
        }
        dismissTodoModal()
    }

    private func dismissTodoModal() {
        todoFieldFocused = false
        showingTodoSheet = false
    }

    // MARK: - Actions

    @MainActor
    private func generateAndSave() async {
        isSavingWallpaper = true
        wallpaperSaved = false
        defer { isSavingWallpaper = false }

        guard let image = WallpaperGenerator.generate(todos: todos) else {
            wallpaperError = "Failed to generate wallpaper image."
            return
        }

        do {
            try await PhotoLibraryManager.saveToAlbum(image)
            wallpaperSaved = true
            // Reset checkmark after 3 seconds
            try? await Task.sleep(for: .seconds(3))
            wallpaperSaved = false
        } catch is PhotoLibraryManager.PhotoError {
            showPermissionDenied = true
        } catch {
            wallpaperError = error.localizedDescription
        }
    }

    private func moveTodos(in subset: [TodoItem], from source: IndexSet, to destination: Int) {
        var ordered = subset
        ordered.move(fromOffsets: source, toOffset: destination)
        for (index, todo) in ordered.enumerated() {
            todo.sortOrder = index
        }
        // Push completed todos after incomplete ones
        let incompleteCount = incompleteTodos.count
        for (index, todo) in completedTodos.enumerated() {
            if todo.isCompleted {
                todo.sortOrder = incompleteCount + index
            }
        }
    }
}

// MARK: - Todo Row

/// Individual todo row with glassmorphic card style
struct TodoRow: View {
    let todo: TodoItem
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            // Checkbox
            Button {
                withAnimation(.spring(duration: 0.4, bounce: 0.3)) {
                    todo.isCompleted.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .stroke(
                            todo.isCompleted
                                ? Color.clear
                                : Color.white.opacity(0.3),
                            lineWidth: 2
                        )
                        .frame(width: 26, height: 26)

                    if todo.isCompleted {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.cyan, .green],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 26, height: 26)

                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)

            // Title
            Text(todo.title)
                .font(.body)
                .foregroundStyle(todo.isCompleted ? .white.opacity(0.4) : .white)
                .strikethrough(todo.isCompleted, color: .white.opacity(0.3))
                .lineLimit(2)

            Spacer()

            // Delete
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.3))
                    .padding(6)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial.opacity(todo.isCompleted ? 0.5 : 1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit()
        }
    }
}

#Preview {
    TodoListView()
        .modelContainer(for: TodoItem.self, inMemory: true)
}
