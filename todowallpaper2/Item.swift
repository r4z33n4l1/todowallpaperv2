//
//  TodoItem.swift
//  todowallpaper2
//
//  Created by Razeen Ali on 2026-03-22.
//

import Foundation
import SwiftData

@Model
class TodoItem {
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    var sortOrder: Int
    
    init(title: String, isCompleted: Bool = false, sortOrder: Int = 0) {
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = Date()
        self.sortOrder = sortOrder
    }
}
