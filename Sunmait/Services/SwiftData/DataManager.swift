//
//  DataManager.swift
//  Sunmait
//
//  Created by Abylaikhan Abilkayr on 21.11.2025.
//

import Foundation
import SwiftData

@MainActor
final class DataManager {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func insert(_ item: FoodItem) {
        modelContext.insert(item)
        try? modelContext.save()
    }
    
    func delete(_ item: FoodItem) {
        modelContext.delete(item)
        try? modelContext.save()
    }
    
    func fetchAllFoodItems() -> [FoodItem] {
        let descriptor = FetchDescriptor<FoodItem>(
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func fetchTodayItems() -> [FoodItem] {
        let calendar = Calendar.current
        let allItems = fetchAllFoodItems()
        return allItems.filter { calendar.isDate($0.dateAdded, inSameDayAs: Date()) }
    }
    
    func calculateTodayTotalCalories() -> Int {
        let calendar = Calendar.current
        let allItems = fetchAllFoodItems()
        return allItems
            .filter { calendar.isDate($0.dateAdded, inSameDayAs: Date()) }
            .reduce(0) { $0 + $1.calories }
    }
    
    func checkForDuplicate(name: String, in items: [FoodItem]) -> FoodItem? {
        items.first { item in
            item.name.lowercased() == name.lowercased()
        }
    }
}

