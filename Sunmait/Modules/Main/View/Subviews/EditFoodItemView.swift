//
//  EditFoodItemView.swift
//  Sunmait
//
//  Created by Abylaikhan Abilkayr on 21.11.2025.
//

import SwiftUI
import SwiftData
import PhotosUI

struct EditFoodItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FoodItem.dateAdded, order: .reverse) private var allFoodItems: [FoodItem]
    @Bindable var item: FoodItem
    
    @State private var name: String = ""
    @State private var calories: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showDuplicateAlert = false
    @State private var currentItemImage: Image?
    
    var body: some View {
        let itemImage = currentItemImage
        
        return NavigationView {
            Form {
                Section("Информация о продукте") {
                    TextField("Название", text: $name)
                    
                    TextField("Калории", text: $calories)
                        .keyboardType(.numberPad)
                }
                
                Section("Фото продукта") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Group {
                            if let image = itemImage {
                                HStack {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    Text("Изменить фото")
                                        .foregroundColor(.accentColor)
                                }
                            } else {
                                Label("Добавить фото", systemImage: "photo")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    
                    if item.imageData != nil {
                        Button(role: .destructive) {
                            item.imageData = nil
                        } label: {
                            Label("Удалить фото", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        saveChanges()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                name = item.name
                calories = String(item.calories)
                updateCurrentImage()
            }
            .onChange(of: selectedPhoto) { oldValue, newValue in
                Task { @MainActor in
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        item.imageData = data
                        updateCurrentImage()
                    }
                }
            }
            .onChange(of: item.imageData) { oldValue, newValue in
                updateCurrentImage()
            }
            .alert("Продукт уже добавлен", isPresented: $showDuplicateAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Продукт с таким названием уже существует в списке.")
            }
        }
    }
    
    private func updateCurrentImage() {
        currentItemImage = item.image
    }
    
    private func saveChanges() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let calendar = Calendar.current
        let todayItems = allFoodItems.filter { calendar.isDate($0.dateAdded, inSameDayAs: Date()) }
        
        let duplicate = todayItems.first { foodItem in
            foodItem.name.lowercased() == trimmedName.lowercased() && foodItem.id != item.id
        }
        
        if duplicate != nil {
            showDuplicateAlert = true
            return
        }
        
        if let caloriesValue = Int(calories) {
            item.name = trimmedName
            item.calories = caloriesValue
            dismiss()
        }
    }
}
