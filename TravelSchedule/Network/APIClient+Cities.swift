//
//  APIClient+Cities.swift
//  TravelSchedule
//

import Foundation

extension APIClient {
    func getRussianCities() async throws -> [City] {
        let all = try await getStationsList()
        
        let countries = all.countries ?? []
        print("ℹ️ [API] countries total=\(countries.count)")
        
        let codeCandidates: Set<String> = ["c146", "225", "ru", "RU"]
        if let byCode = countries.first(where: { codeCandidates.contains($0.codes?.yandex_code ?? "") }) {
            print("ℹ️ [API] Russia matched by code: \(byCode.codes?.yandex_code ?? "?") title=\(byCode.title ?? "?")")
            return try await buildCities(from: byCode)
        }
        
        let titleCandidates: Set<String> = [
            "россия", "russia", "russian federation", "российская федерация"
        ]
        if let byTitle = countries.first(where: { titleCandidates.contains(($0.title ?? "").lowercased()) }) {
            print("ℹ️ [API] Russia matched by title: \(byTitle.title ?? "?")")
            return try await buildCities(from: byTitle)
        }
        
        let preview = countries.prefix(10).map { c in
            "\((c.codes?.yandex_code) ?? "?") – \((c.title) ?? "?")"
        }.joined(separator: " | ")
        print("🔎 [API] countries preview(10): \(preview)")
        
        if let bySubstr = countries.first(where: {
            let t = ($0.title ?? "").lowercased()
            return t.contains("ros") || t.contains("rus")
        }) {
            print("ℹ️ [API] Russia matched by substring: \(bySubstr.title ?? "?") code=\(bySubstr.codes?.yandex_code ?? "?")")
            return try await buildCities(from: bySubstr)
        }
        
        print("⚠️ [API] Russia not found by any heuristic; returning empty list")
        return []
    }
    
    // MARK: - Helpers
    private func buildCities(from country: Components.Schemas.Country) async throws -> [City] {
        var cities: [City] = []
        
        for region in (country.regions ?? []) {
            let regionTitle = region.title
            for settlement in (region.settlements ?? []) {
                guard
                    let code = settlement.codes?.yandex_code,
                    let title = settlement.title
                else { continue }
                
                var firstLat: Double? = nil
                var firstLon: Double? = nil
                
                var types = Set<String>()
                if let stations = settlement.stations {
                    if let first = stations.first {
                        firstLat = first.lat
                        firstLon = first.lng
                    }
                    for st in stations {
                        if let t = st.transport_type, !t.isEmpty {
                            types.insert(t)
                        }
                    }
                }
                
                let city = City(
                    id: code,
                    title: title,
                    region: regionTitle,
                    country: country.title,
                    lat: firstLat,
                    lon: firstLon,
                    transportTypes: types
                )
                cities.append(city)
            }
        }
        
        cities.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        print("ℹ️ [API] russian_cities count=\(cities.count)")
        return cities
    }
}
