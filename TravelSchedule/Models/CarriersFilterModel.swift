//
//  CarriersFilterModel.swift
//  TravelSchedule
//

import SwiftUI
import Combine

@MainActor
final class CarriersFilterModel: ObservableObject {
    @Published var appliedFilters: FiltersSelection? = nil
}
