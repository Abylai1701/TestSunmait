//
//  ContentView.swift
//  Sunmait
//
//  Created by Abylaikhan Abilkayr on 21.11.2025.
//

import SwiftUI
import SwiftData
import PhotosUI

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = CaloriesViewModel()
    
    var body: some View {
        NavigationView {
            content
                .navigationTitle("Калькулятор калорий")
                .alert(viewModel.deleteAlertTitle, isPresented: $viewModel.showDeleteAlert) {
                    Button("Отмена", role: .cancel) {
                        viewModel.cancelDeleteItem()
                    }
                    Button("Удалить", role: .destructive) {
                        viewModel.confirmDeleteItem()
                    }
                } message: {
                    Text(viewModel.deleteAlertMessage)
                }
                .alert("Продукт уже добавлен", isPresented: $viewModel.showDuplicateAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Продукт с таким названием уже существует в списке.")
                }
                .sheet(item: $viewModel.editingItem) { item in
                    EditFoodItemView(item: item)
                        .onDisappear {
                            viewModel.updateData()
                        }
                }
                .task {
                    viewModel.setup(modelContext: modelContext)
                }
                .hideKeyboardOnTap()
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Text("Калорий сегодня")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("\(viewModel.todayTotalCalories)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .scaleEffect(viewModel.caloriesAnimationScale)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.caloriesAnimationScale)
                
                VStack(spacing: 8) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray5))
                                .frame(height: 12)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .green],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * viewModel.progressAnimation, height: 12)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.progressAnimation)
                        }
                    }
                    .frame(height: 12)
                    
                    Text("\(viewModel.todayTotalCalories) / \(viewModel.dailyCaloriesGoal) ккал")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
            .background(Color(.systemGroupedBackground))
            
            VStack(spacing: 12) {
                TextField("Название продукта", text: $viewModel.foodName)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        viewModel.addFoodItem()
                    }
                
                HStack(spacing: 12) {
                    TextField("Калории", text: $viewModel.caloriesInput)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .onSubmit {
                            viewModel.addFoodItem()
                        }
                    
                    PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                        Image(systemName: "photo.badge.plus")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                    .disabled(!viewModel.canAddFoodItem)
                    
                    Button(action: {
                        viewModel.addFoodItem()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                    .disabled(!viewModel.canAddFoodItem)
                }
            }
            .padding()
            .onChange(of: viewModel.selectedPhoto) { oldValue, newValue in
                viewModel.handlePhotoSelection(newValue)
            }
            
            if viewModel.todayItems.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("Нет добавленных продуктов")
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                List {
                    ForEach(viewModel.todayItems) { item in
                        FoodItemRow(item: item)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    viewModel.requestDeleteItem(item)
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                                
                                Button {
                                    viewModel.openEditSheet(for: item)
                                } label: {
                                    Label("Редактировать", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}


#Preview {
    MainView()
        .modelContainer(for: FoodItem.self, inMemory: true)
}
