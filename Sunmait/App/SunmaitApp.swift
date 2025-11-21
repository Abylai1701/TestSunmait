//
//  SunmaitApp.swift
//  Sunmait
//
//  Created by Abylaikhan Abilkayr on 21.11.2025.
//

import SwiftUI
import SwiftData

@main
struct SunmaitApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(.light)
        }
        .modelContainer(for: FoodItem.self)
    }
}
