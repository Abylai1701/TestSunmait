//
//  FoodItemRow.swift
//  Sunmait
//
//  Created by Abylaikhan Abilkayr on 21.11.2025.
//

import SwiftUI

struct FoodItemRow: View {
    let item: FoodItem
    @State private var appearAnimation = false
    
    var body: some View {
        HStack(spacing: 16) {
            if let image = item.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .opacity(appearAnimation ? 1 : 0)
                    .scaleEffect(appearAnimation ? 1 : 0.8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundColor(.secondary)
                    }
                    .opacity(appearAnimation ? 1 : 0)
                    .scaleEffect(appearAnimation ? 1 : 0.8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(x: appearAnimation ? 0 : -20)
                
                Text("\(item.calories) ккал")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(x: appearAnimation ? 0 : -20)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                appearAnimation = true
            }
        }
    }
}
