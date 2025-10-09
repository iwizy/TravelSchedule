//
//  CityPickerViewModel.swift
//  TravelSchedule
//

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
            self.allCities = cities.sorted {
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
            applySearch()
            print("✅ [CityPickerVM] load success cities=\(self.allCities.count)")
        } catch {
            self.errorMessage = error.localizedDescription
            self.filtered = []
            print("❌ [CityPickerVM] load error: \(error)")
        }

        isLoading = false
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
