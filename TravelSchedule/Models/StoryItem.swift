//
//  StoryItem.swift
//  TravelSchedule
//

import Foundation

struct StoryItem: Identifiable, Hashable, Sendable {
    let id = UUID()
    let title: String
    let imageName: String
}
