//
//  StoryItem.swift
//  TravelSchedule
//
//  Created by Alexander Agafonov on 08.09.2025.
//

import Foundation

struct StoryItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let imageName: String
}
