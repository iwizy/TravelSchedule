//
//  CarriersFilterModel.swift
//  TravelSchedule
//
//  Модель фильтров перевозчика

import SwiftUI
import Combine

final class CarriersFilterModel: ObservableObject {
    @Published var appliedFilters: FiltersSelection? = nil
}
