//
//  CityPickerViewModel.swift
//  TravelSchedule
//
//  Вьюмодель экрана выбора города

import Foundation

@MainActor
final class CityPickerViewModel: ObservableObject {
    @Published var allCities: [City] = []
    @Published var filtered: [City] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func load(apiClient: APIClient) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        print("➡️ [CityPickerVM] load start")
        do {
            let cities = try await apiClient.getRussianCities()
            self.allCities = cities
            applySearch()
            print("✅ [CityPickerVM] load success cities=\(cities.count)")
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ [CityPickerVM] load error: \(error)")
        }
        isLoading = false
    }
    
    func setInitialQuery(_ q: String) {
        if !q.isEmpty {
            searchText = q
            applySearch()
        }
    }
    
    func applySearch() {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty {
            filtered = allCities
        } else {
            filtered = allCities.filter { city in
                let target = "\(city.title) \(city.region ?? "")".lowercased()
                return target.contains(q)
            }
        }
    }
}
