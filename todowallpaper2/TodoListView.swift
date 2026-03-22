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

    @State private var newTodoTitle = ""
    @State private var showingWallpaperPreview = false
    @State private var editingTodo: TodoItem?
    @State private var editText = ""
    @State private var isAddExpanded = false
    @FocusState private var isInputFocused: Bool

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
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            // Incomplete section
                            if !incompleteTodos.isEmpty {
                                sectionHeader("Tasks", count: incompleteTodos.count)
                                ForEach(incompleteTodos) { todo in
                                    TodoRow(todo: todo, onEdit: {
                                        editingTodo = todo
                                        editText = todo.title
                                    }, onDelete: {
                                        withAnimation(.spring(duration: 0.3)) {
                                            modelContext.delete(todo)
                                        }
                                    })
                                    .transition(.asymmetric(
                                        insertion: .scale.combined(with: .opacity),
                                        removal: .slide.combined(with: .opacity)
                                    ))
                                }
                            }

                            // Completed section
                            if !completedTodos.isEmpty {
                                sectionHeader("Completed", count: completedTodos.count)
                                ForEach(completedTodos) { todo in
                                    TodoRow(todo: todo, onEdit: {
                                        editingTodo = todo
                                        editText = todo.title
                                    }, onDelete: {
                                        withAnimation(.spring(duration: 0.3)) {
                                            modelContext.delete(todo)
                                        }
                                    })
                                    .transition(.asymmetric(
                                        insertion: .scale.combined(with: .opacity),
                                        removal: .slide.combined(with: .opacity)
                                    ))
                                }
                            }

                            // Empty state
                            if todos.isEmpty {
                                emptyState
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 100) // space for input bar
                    }
                    .scrollDismissesKeyboard(.interactively)
                }

                // Floating add bar
                VStack {
                    Spacer()
                    addTodoBar
                }
            }
            .navigationTitle("Todo Wallpaper")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingWallpaperPreview = true
                    } label: {
                        Image(systemName: "photo.on.rectangle")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.cyan)
                            .font(.title3)
                    }
                    .disabled(todos.isEmpty)
                }
            }
            .sheet(isPresented: $showingWallpaperPreview) {
                WallpaperPreviewView(todos: todos)
            }
            .alert("Edit Todo", isPresented: Binding(
                get: { editingTodo != nil },
                set: { if !$0 { editingTodo = nil } }
            )) {
                TextField("Title", text: $editText)
                Button("Cancel", role: .cancel) {
                    editingTodo = nil
                }
                Button("Save") {
                    saveEdit()
                }
            }
        }
        .preferredColorScheme(.dark)
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
                showingWallpaperPreview = true
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
            .disabled(todos.isEmpty)
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

    private func sectionHeader(_ title: String, count: Int) -> some View {
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

            Text("Add your first task below")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.3))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    // MARK: - Add Todo Bar

    private var addTodoBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "plus")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.cyan.opacity(isInputFocused ? 1 : 0.6))
                    .animation(.easeInOut(duration: 0.2), value: isInputFocused)

                TextField("Add a new task...", text: $newTodoTitle)
                    .font(.body)
                    .foregroundStyle(.white)
                    .focused($isInputFocused)
                    .onSubmit(addTodo)
                    .tint(.cyan)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isInputFocused
                                    ? Color.cyan.opacity(0.4)
                                    : Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
            }

            if !newTodoTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                Button(action: addTodo) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.cyan)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        }
        .animation(.spring(duration: 0.3), value: newTodoTitle.isEmpty)
    }

    // MARK: - Actions

    private func addTodo() {
        let title = newTodoTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }

        withAnimation(.spring(duration: 0.4)) {
            let maxOrder = todos.map(\.sortOrder).max() ?? -1
            let todo = TodoItem(title: title, sortOrder: maxOrder + 1)
            modelContext.insert(todo)
            newTodoTitle = ""
        }
    }

    private func saveEdit() {
        guard let todo = editingTodo else { return }
        let trimmed = editText.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            todo.title = trimmed
        }
        editingTodo = nil
    }
}

/// Individual todo row with glassmorphic card style
struct TodoRow: View {
    let todo: TodoItem
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var isPressed = false

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
        .onTapGesture(count: 2) {
            onEdit()
        }
    }
}

#Preview {
    TodoListView()
        .modelContainer(for: TodoItem.self, inMemory: true)
}
