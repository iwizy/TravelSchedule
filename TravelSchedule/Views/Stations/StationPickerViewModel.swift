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
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Загрузка
    func load(apiClient: APIClient, city: City) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        print("➡️ [StationPickerVM] load start city=\(city.title) (\(city.id))")

        do {
            let stations = try await apiClient.getStationsOfCity(cityId: city.id)

            self.all = stations.sorted {
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
            applySearch()
            print("✅ [StationPickerVM] load success stations=\(self.all.count)")
        } catch {
            self.errorMessage = error.localizedDescription
            self.filtered = []
            print("❌ [StationPickerVM] load error: \(error)")
        }

        isLoading = false
    }

    // MARK: - Поиск
    func applySearch() {
        let q = normalize(searchText)
        guard !q.isEmpty else {
            filtered = all
            return
        }

        filtered = all.filter { station in
            normalize(station.title).contains(q)
        }

        filtered.sort { a, b in
            let na = normalize(a.title), nb = normalize(b.title)
            let pa = na.hasPrefix(q),      pb = nb.hasPrefix(q)
            if pa != pb { return pa && !pb }
            return na < nb
        }
    }

    func setInitialQuery(_ q: String?) {
        guard let q, !q.isEmpty else { return }
        searchText = q
        applySearch()
    }

    // MARK: - Нормализация строки
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
