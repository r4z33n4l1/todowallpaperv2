//
//  TodoStore.swift
//  todowallpaper2
//
//  Created by Razeen Ali on 2026-03-22.
//

import SwiftData
import Foundation

/// Shared business logic for managing todos across app, widget, and intents.
/// This class provides reusable methods that don't depend on SwiftUI environment.
class TodoStore {
    
    /// Fetches all todos sorted by sortOrder
    static func fetchTodos(from context: ModelContext) throws -> [TodoItem] {
        let descriptor = FetchDescriptor<TodoItem>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        return try context.fetch(descriptor)
    }
    
    /// Fetches incomplete todos only
    static func fetchIncompleteTodos(from context: ModelContext) throws -> [TodoItem] {
        let descriptor = FetchDescriptor<TodoItem>(
            predicate: #Predicate<TodoItem> { !$0.isCompleted },
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        return try context.fetch(descriptor)
    }
    
    /// Adds a new todo with automatic sort order
    static func addTodo(title: String, to context: ModelContext) throws {
        let allTodos = try fetchTodos(from: context)
        let maxOrder = allTodos.map(\.sortOrder).max() ?? -1
        let todo = TodoItem(title: title, sortOrder: maxOrder + 1)
        context.insert(todo)
        try context.save()
    }
    
    /// Toggles the completion state of a todo
    static func toggleTodo(_ todo: TodoItem, in context: ModelContext) throws {
        todo.isCompleted.toggle()
        try context.save()
    }
    
    /// Deletes a todo
    static func deleteTodo(_ todo: TodoItem, from context: ModelContext) throws {
        context.delete(todo)
        try context.save()
    }
    
    /// Reorders todos based on a new array order
    static func reorderTodos(_ todos: [TodoItem], in context: ModelContext) throws {
        for (index, todo) in todos.enumerated() {
            todo.sortOrder = index
        }
        try context.save()
    }
    
    /// Calculates completion statistics
    static func calculateStats(for todos: [TodoItem]) -> (completed: Int, total: Int, progress: Double) {
        let completed = todos.filter(\.isCompleted).count
        let total = todos.count
        let progress = total > 0 ? Double(completed) / Double(total) : 0
        return (completed, total, progress)
    }
}
