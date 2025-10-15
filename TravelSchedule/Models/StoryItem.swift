//
//  StoryItem.swift
//  TravelSchedule
//

import Foundation

// MARK: - StoryItem model
struct StoryItem: Identifiable, Hashable, Sendable {
    let id = UUID()
    let title: String
    let imageName: String
}
