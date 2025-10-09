//
//  FiltersSelection.swift
//  TravelSchedule
//


import SwiftUI

public struct FiltersSelection: Hashable {
    public enum TimeBand: CaseIterable, Hashable {
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
    public var timeBands: Set<TimeBand> = []
    public var transfers: Bool? = nil
    
    public init(timeBands: Set<TimeBand> = [], transfers: Bool? = nil) {
        self.timeBands = timeBands
        self.transfers = transfers
    }
    
    public var canApply: Bool { !timeBands.isEmpty && transfers != nil }
}
