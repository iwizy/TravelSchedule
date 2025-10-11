//
//  APIClient+Cities.swift
//  TravelSchedule
//

import Foundation

extension APIClient {
    func getRussianCities() async throws -> [City] {
        let all = try await getStationsListCached()
        
        let ru = (all.countries ?? []).first { country in
            let code = country.codes?.yandex_code ?? ""
            if code == "225" || code == "c146" { return true }
            return normalize(country.title ?? "").contains("росси")
        }
        
        guard let country = ru else {
            print("⚠️ [API] russian_cities: Russia not found in countries")
            return []
        }
        
        var items: [City] = []
        for region in (country.regions ?? []) {
            let regionTitle = region.title ?? ""
            
            for settlement in (region.settlements ?? []) {
                let titleFromStations = settlement.stations?.first?.title
                let displayTitle = (settlement.title ?? titleFromStations ?? "—")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                guard !displayTitle.isEmpty else { continue }
                
                let id = makeCityID(
                    countryTitle: country.title ?? "",
                    regionTitle: regionTitle,
                    settlement: settlement
                )
                
                let types: Set<String> = Set((settlement.stations ?? []).compactMap { $0.transport_type })
                
                items.append(
                    City(
                        id: id,
                        title: displayTitle,
                        region: regionTitle,
                        country: country.title,
                        lat: nil,
                        lon: nil,
                        transportTypes: types
                    )
                )
            }
        }
        
        var seen = Set<String>()
        let unique = items.filter { city in
            if seen.contains(city.id) { return false }
            seen.insert(city.id)
            return true
        }
        
        let sorted = unique.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        
        let sample = sorted.prefix(10).map { $0.title }.joined(separator: ", ")
        print("ℹ️ [API] russian_cities total=\(items.count) unique=\(sorted.count); sample: \(sample)")
        
        return sorted
    }
    
    func makeCityID(
        countryTitle: String,
        regionTitle: String,
        settlement: Components.Schemas.Settlement
    ) -> String {
        if let code = settlement.codes?.yandex_code,
           !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return code
        }
        let countryNorm = normalize(countryTitle)
        let regionNorm  = normalize(regionTitle)
        let title = (settlement.title ?? settlement.stations?.first?.title ?? "")
        let settlNorm   = normalize(title)
        return "\(countryNorm)|\(regionNorm)|\(settlNorm)"
    }
    
    func normalize(_ s: String) -> String {
        let yo = s.replacingOccurrences(of: "ё", with: "е").replacingOccurrences(of: "Ё", with: "Е")
        return yo
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "ru_RU"))
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
