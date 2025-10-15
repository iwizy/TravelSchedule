//
//  CityPickerViewModel.swift
//  TravelSchedule
//

import Foundation

// MARK: - ViewModel

@MainActor
final class CityPickerViewModel: ObservableObject {
    
    // MARK: - State
    
    @Published var allCities: [City] = []
    @Published var filtered: [City] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Public API
    
    func load(apiClient: APIClient, force: Bool = false) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        print("➡️ [CityPickerVM] load start (force=\(force))")
        
        defer { isLoading = false }
        
        do {
            let cities = try await apiClient.getRussianCities(force: force)
            self.allCities = cities.sorted {
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
            applySearch()
            ErrorCenter.shared.serverError = false
            print("✅ [CityPickerVM] load success cities=\(self.allCities.count)")
        } catch {
            self.allCities = []
            self.filtered = []
            
            if let httpErr = error as? APIClient.ServerHTTPError {
                ErrorCenter.shared.serverError = true
                self.errorMessage = "HTTP \(httpErr.statusCode)"
                print("❌ [CityPickerVM] load error: ServerHTTPError(statusCode: \(httpErr.statusCode))")
                await apiClient.invalidateStationsListCache()
            } else {
                self.errorMessage = error.localizedDescription
                print("❌ [CityPickerVM] load error: \(error)")
            }
        }
    }
    
    func applySearch() {
        let q = normalize(searchText)
        guard !q.isEmpty else {
            filtered = allCities
            return
        }
        
        filtered = allCities.filter { city in
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
    
    // MARK: - Helpers
    
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
