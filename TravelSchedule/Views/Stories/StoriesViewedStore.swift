//
//  StoriesViewedStore.swift
//  TravelSchedule
//
//  Хранилище просмотренных историй

import SwiftUI

final class StoriesViewedStore: ObservableObject {
    @AppStorage("stories.viewed.ids") private var viewedCSV: String = ""
    @Published private(set) var viewed: Set<UUID> = []

    init() {
        viewed = Set(viewedCSV.split(separator: ",").compactMap { UUID(uuidString: String($0)) })
    }

    func isViewed(_ id: UUID) -> Bool { viewed.contains(id) }

    func markViewed(_ id: UUID) {
        guard !viewed.contains(id) else { return }
        viewed.insert(id)
        viewedCSV = viewed.map(\.uuidString).joined(separator: ",")
        objectWillChange.send()
    }

    func markRangeViewed(ids: [UUID], through index: Int) {
        guard ids.indices.contains(index) else { return }
        for i in 0...index { markViewed(ids[i]) }
    }
}
