//
//  StoriesViewedStore.swift
//  TravelSchedule
//

import SwiftUI

// MARK: - StoriesViewedStore
@MainActor
final class StoriesViewedStore: ObservableObject {
    @Published private(set) var viewedMedia = Set<UUID>()
    @Published private(set) var lastIndexByGroup: [UUID:Int] = [:]
    
    // MARK: - Queries
    func isViewed(media id: UUID) -> Bool { viewedMedia.contains(id) }
    func hasUnviewed(in group: StoryGroup) -> Bool {
        group.items.contains { !viewedMedia.contains($0.id) }
    }
    func firstUnviewedIndex(in group: StoryGroup) -> Int? {
        group.items.firstIndex { !viewedMedia.contains($0.id) }
    }
    
    // MARK: - Updates
    func markViewed(media id: UUID) { viewedMedia.insert(id); persist() }
    func setLastIndex(groupID: UUID, index: Int) { lastIndexByGroup[groupID] = index; persist() }
    
    // MARK: - Persistence
    private let viewedKey = "stories.viewedMedia.v2"
    private let lastIdxKey = "stories.lastIndexByGroup.v2"
    
    init() { restore() }
    
    private func persist() {
        UserDefaults.standard.set(viewedMedia.map(\.uuidString), forKey: viewedKey)
        let dict = Dictionary(uniqueKeysWithValues: lastIndexByGroup.map { ($0.key.uuidString, $0.value) })
        UserDefaults.standard.set(dict, forKey: lastIdxKey)
    }
    
    private func restore() {
        if let ids = UserDefaults.standard.array(forKey: viewedKey) as? [String] {
            viewedMedia = Set(ids.compactMap(UUID.init(uuidString:)))
        }
        if let dict = UserDefaults.standard.dictionary(forKey: lastIdxKey) as? [String:Int] {
            lastIndexByGroup = Dictionary(uniqueKeysWithValues: dict.compactMap {
                guard let uuid = UUID(uuidString: $0.key) else { return nil }
                return (uuid, $0.value)
            })
        }
    }
}
