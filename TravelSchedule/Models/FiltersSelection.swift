//
//  FiltersSelection.swift
//  TravelSchedule
//
//  Модель фильтров

import SwiftUI

public struct FiltersSelection: Hashable {
    public enum TimeBand: CaseIterable, Hashable {
        case morning, day, evening, night
        public var title: String {
            switch self {
            case .morning: return "Утро 06:00 – 12:00"
            case .day:     return "День 12:00 – 18:00"
            case .evening: return "Вечер 18:00 – 00:00"
            case .night:   return "Ночь 00:00 – 06:00"
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
