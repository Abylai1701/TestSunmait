//
//  CaloriesViewModel.swift
//  Sunmait
//
//  Created by Abylaikhan Abilkayr on 21.11.2025.
//

import Foundation
import SwiftData
import SwiftUI
import PhotosUI

@MainActor
final class CaloriesViewModel: ObservableObject {
    @Published var foodName: String = ""
    @Published var caloriesInput: String = ""
    @Published var showDeleteAlert: Bool = false
    @Published var showDuplicateAlert: Bool = false
    @Published var itemToDelete: FoodItem?
    @Published var editingItem: FoodItem?
    @Published var showEditSheet: Bool = false
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var pendingImageData: Data?
    @Published var caloriesAnimationScale: CGFloat = 1.0
    @Published var progressAnimation: Double = 0.0
    @Published var todayItems: [FoodItem] = []
    @Published var todayTotalCalories: Int = 0
    
    private var dataManager: DataManager?
    private var previousTotalCalories: Int = 0
    private var refreshTask: Task<Void, Never>?
    
    let dailyCaloriesGoal: Int = 2000
        
    var canAddFoodItem: Bool {
        !foodName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var deleteAlertTitle: String {
        "Удалить продукт?"
    }
    
    var deleteAlertMessage: String {
        if let item = itemToDelete {
            return "Вы уверены, что хотите удалить \"\(item.name)\"?"
        }
        return ""
    }
    
    // MARK: - Deinit

    deinit {
        refreshTask?.cancel()
    }
    
    // MARK: - Public Methods
    
    func setup(modelContext: ModelContext) {
        self.dataManager = DataManager(modelContext: modelContext)
        startRefreshing()
        updateData()
    }
    
    func updateData() {
        guard let dataManager = dataManager else { return }
        
        let newTodayItems = dataManager.fetchTodayItems()
        let newTotalCalories = dataManager.calculateTodayTotalCalories()
        
        todayItems = newTodayItems
        todayTotalCalories = newTotalCalories
        updateProgressBar(for: newTotalCalories)
    }

    
    func updateProgressBar(for totalCalories: Int) {
        let progress = min(Double(totalCalories) / Double(dailyCaloriesGoal), 1.0)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            progressAnimation = progress
        }
        
        if totalCalories != previousTotalCalories {
            triggerCaloriesAnimation()
            previousTotalCalories = totalCalories
        }
    }
    
    func addFoodItem() {
        guard let dataManager = dataManager else { return }
        
        let trimmedName = foodName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let calories = Int(caloriesInput.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        
        if let duplicate = dataManager.checkForDuplicate(name: trimmedName, in: todayItems) {
            showDuplicateAlert = true
            return
        }
                
        let newItem = FoodItem(name: trimmedName, calories: calories, imageData: pendingImageData)
        dataManager.insert(newItem)
        clearInputFields()
        updateData()
    }
    
    func requestDeleteItem(_ item: FoodItem) {
        itemToDelete = item
        showDeleteAlert = true
    }
    
    func confirmDeleteItem() {
        guard let dataManager = dataManager else { return }
        
        if let item = itemToDelete {
            dataManager.delete(item)
            itemToDelete = nil
            updateData()
        }
    }
    
    func cancelDeleteItem() {
        itemToDelete = nil
    }
    
    func openEditSheet(for item: FoodItem) {
        editingItem = item
        showEditSheet = true
    }
    
    func handlePhotoSelection(_ photo: PhotosPickerItem?) {
        selectedPhoto = photo
        Task {
            if let data = try? await photo?.loadTransferable(type: Data.self) {
                pendingImageData = data
            }
        }
    }
    
    func clearInputFields() {
        foodName = ""
        caloriesInput = ""
        pendingImageData = nil
        selectedPhoto = nil
    }
    
    // MARK: - Private Methods

    private func triggerCaloriesAnimation() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            caloriesAnimationScale = 1.2
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                self.caloriesAnimationScale = 1.0
            }
        }
    }
    
    private func startRefreshing() {
        refreshTask?.cancel()
        refreshTask = Task {
            while !Task.isCancelled {
                updateData()
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }
}
