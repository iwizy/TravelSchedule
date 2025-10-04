//
//  StationPickerViewModel.swift
//  TravelSchedule
//
//  ВМ экрана станций

import Foundation

@MainActor
final class StationPickerViewModel: ObservableObject {
    @Published var all: [Station] = []
    @Published var filtered: [Station] = []
    @Published var searchText: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func load(apiClient: APIClient, city: City) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        print("➡️ [StationPickerVM] load start city=\(city.title) (\(city.id))")
        do {
            let stations = try await apiClient.getStationsOfCity(cityId: city.id)
            self.all = stations
            applySearch()
            print("✅ [StationPickerVM] load success stations=\(stations.count)")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ [StationPickerVM] load error: \(error)")
        }
        isLoading = false
    }
    
    func setInitialQuery(_ q: String?) {
        if let q, !q.isEmpty {
            searchText = q
            applySearch()
        }
    }
    
    func applySearch() {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty {
            filtered = all
        } else {
            filtered = all.filter { $0.title.lowercased().contains(q) }
        }
    }
}
