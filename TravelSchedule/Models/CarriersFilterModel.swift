//
//  CarriersFilterModel.swift
//  TravelSchedule
//

import SwiftUI
import Combine

// MARK: - ViewModel (filters)
@MainActor
final class CarriersFilterModel: ObservableObject {
    @Published var appliedFilters: FiltersSelection? = nil
}
