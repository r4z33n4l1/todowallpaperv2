//
//  ContentView.swift
//  todowallpaper2
//
//  Created by Razeen Ali on 2026-03-22.
//

import SwiftUI
import SwiftData

// This file is kept as the original SwiftData template example.
// The actual app uses TodoListView as the main interface.
// You can delete this file if you don't need the reference.

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [TodoItem]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        VStack(spacing: 20) {
                            Text("Todo Item")
                                .font(.title)
                            Text(item.title)
                                .font(.headline)
                            Text("Created: \(item.createdAt, format: Date.FormatStyle(date: .numeric, time: .standard))")
                                .font(.caption)
                            Text("Completed: \(item.isCompleted ? "Yes" : "No")")
                        }
                        .padding()
                    } label: {
                        HStack {
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                            Text(item.title)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = TodoItem(title: "Sample Todo \(items.count + 1)", sortOrder: items.count)
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TodoItem.self, inMemory: true)
}

