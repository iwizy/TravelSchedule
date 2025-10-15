//
//  StoriesModels.swift
//  TravelSchedule
//

import Foundation

// MARK: - StoryMedia model
struct StoryMedia: Identifiable, Hashable, Sendable {
    let id: UUID
    let imageName: String
    let title: String?
    let subtitle: String?
    let duration: TimeInterval
    
    init(
        id: UUID = UUID(),
        imageName: String,
        title: String? = nil,
        subtitle: String? = nil,
        duration: TimeInterval = 6
    ) {
        self.id = id
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
        self.duration = duration
    }
}

// MARK: - StoryGroup model
struct StoryGroup: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let avatar: String
    var items: [StoryMedia]
    
    init(
        id: UUID = UUID(),
        title: String,
        avatar: String,
        items: [StoryMedia]
    ) {
        self.id = id
        self.title = title
        self.avatar = avatar
        self.items = items
    }
}
