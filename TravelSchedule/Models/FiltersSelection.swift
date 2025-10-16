//
//  FiltersSelection.swift
//  TravelSchedule
//

import SwiftUI

// MARK: - FiltersSelection model
public struct FiltersSelection: Hashable, Sendable {
    
    // MARK: - TimeBand (filter options)
    public enum TimeBand: CaseIterable, Hashable, Sendable {
        case morning, day, evening, night
        
        public var title: String {
            switch self {
            case .morning: return String(localized: "filters.morning")
            case .day:     return String(localized: "filters.day")
            case .evening: return String(localized: "filters.evening")
            case .night:   return String(localized: "filters.night")
            }
        }
    }
    
    // MARK: - Properties
    public var timeBands: Set<TimeBand> = []
    public var transfers: Bool? = nil
    
    // MARK: - Init
    public init(timeBands: Set<TimeBand> = [], transfers: Bool? = nil) {
        self.timeBands = timeBands
        self.transfers = transfers
    }
    
    // MARK: - Computed
    public var canApply: Bool { !timeBands.isEmpty && transfers != nil }
}
