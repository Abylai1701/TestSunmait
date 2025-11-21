//
//  FoodParser.swift
//  Sunmait
//
//  Created by Abylaikhan Abilkayr on 21.11.2025.
//

import Foundation

struct FoodParser {
    static func parse(_ input: String) -> (name: String, calories: Int)? {
        let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else { return nil }
        
        let regex = try! NSRegularExpression(pattern: "\\d+", options: [])
        let range = NSRange(trimmedInput.startIndex..<trimmedInput.endIndex, in: trimmedInput)
        
        guard let match = regex.firstMatch(in: trimmedInput, options: [], range: range) else {
            return (trimmedInput, 0)
        }
        
        if let numberRange = Range(match.range, in: trimmedInput),
           let calories = Int(trimmedInput[numberRange]) {
            
            let name = trimmedInput
                .replacingOccurrences(of: String(trimmedInput[numberRange]), with: "")
                .replacingOccurrences(of: "·", with: "")
                .replacingOccurrences(of: "ккал", with: "", options: .caseInsensitive)
                .replacingOccurrences(of: "kcal", with: "", options: .caseInsensitive)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if name.isEmpty {
                return nil
            }
            
            return (name, calories)
        }
        
        return nil
    }
}
