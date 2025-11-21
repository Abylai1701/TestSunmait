//
//  FoodItem.swift
//  Sunmait
//
//  Created by Abylaikhan Abilkayr on 21.11.2025.
//

import SwiftData
import SwiftUI
import UIKit

@Model
final class FoodItem {
    var name: String
    var calories: Int
    var dateAdded: Date
    var imageData: Data?
    
    init(name: String, calories: Int, dateAdded: Date = Date(), imageData: Data? = nil) {
        self.name = name
        self.calories = calories
        self.dateAdded = dateAdded
        self.imageData = imageData
    }
    
    var image: Image? {
        guard let imageData = imageData,
              let uiImage = UIImage(data: imageData) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
}

