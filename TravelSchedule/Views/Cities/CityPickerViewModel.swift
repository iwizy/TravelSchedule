//
//  CityPickerViewModel.swift
//  TravelSchedule
//

import Foundation

// MARK: CityPickerViewModel.OK

@MainActor
final class CityPickerViewModel: ObservableObject {
    
    // MARK: StateMachine
    enum State: Equatable {
        case idle
        case loading
        case loaded([City])
        case error(String)
    }
    
    // MARK: Published
    @Published var state: State = .idle
    @Published var filtered: [City] = []
    @Published var searchText: String = ""
    
    // MARK: Storage
    private var allCitiesStore: [City] = []
    
    // MARK: Public API
    func load(apiClient: APIClient, force: Bool = false) async {
        guard state != .loading else { return }
        state = .loading
        print("➡️ [CityPickerVM] load start (force=\(force))")
        
        do {
            let cities = try await apiClient.getRussianCities(force: force)
            let sorted = cities.sorted {
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
            allCitiesStore = sorted
            applySearch()
            state = .loaded(sorted)
            ErrorCenter.shared.serverError = false
            print("✅ [CityPickerVM] load success cities=\(sorted.count)")
        } catch {
            allCitiesStore = []
            filtered = []
            
            if let httpErr = error as? APIClient.ServerHTTPError {
                ErrorCenter.shared.serverError = true
                state = .error("HTTP \(httpErr.statusCode)")
                print("❌ [CityPickerVM] load error: ServerHTTPError(statusCode: \(httpErr.statusCode))")
                await apiClient.invalidateStationsListCache()
            } else {
                state = .error(error.localizedDescription)
                print("❌ [CityPickerVM] load error: \(error)")
            }
        }
    }
    
    // MARK: Search
    func applySearch() {
        let q = normalize(searchText)
        guard !q.isEmpty else {
            filtered = allCitiesStore
            return
        }
        
        filtered = allCitiesStore.filter { city in
            normalize(city.title).contains(q)
        }
        
        filtered.sort { a, b in
            let na = normalize(a.title), nb = normalize(b.title)
            let pa = na.hasPrefix(q), pb = nb.hasPrefix(q)
            if pa != pb { return pa && !pb }
            return na < nb
        }
    }
    
    func setInitialQuery(_ query: String?) {
        guard let q = query, !q.isEmpty else { return }
        searchText = q
        applySearch()
    }
    
    // MARK: Helpers
    private func normalize(_ s: String) -> String {
        let replacedYo = s
            .replacingOccurrences(of: "ё", with: "е")
            .replacingOccurrences(of: "Ё", with: "Е")
        
        let folded = replacedYo
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.diacriticInsensitive, .caseInsensitive],
                     locale: Locale(identifier: "ru_RU"))
            .lowercased()
        
        let components = folded.split(whereSeparator: { $0.isWhitespace })
        return components.joined(separator: " ")
    }
}
