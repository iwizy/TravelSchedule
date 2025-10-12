//
//  APIClient+Cities.swift
//  TravelSchedule
//

import Foundation

extension APIClient {
    func getRussianCities() async throws -> [City] {
        let catalog = try await getStationsListCached()
        
        let countries = catalog.countries ?? []
        let ruCountry =
        countries.first(where: { ($0.codes?.yandex == "225") }) ??
        countries.first(where: { ($0.title ?? "").localizedCaseInsensitiveContains("росси") })
        
        guard let country = ruCountry else { return [] }
        let countryTitle = (country.title ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        var seen = Set<String>()
        var result: [City] = []
        
        for region in (country.regions ?? []) {
            let regionTitle = (region.title ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            for s in (region.settlements ?? []) {
                guard
                    let rawTitle = s.title?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                    !rawTitle.isEmpty
                else { continue }
                
                let rawCode = (s.codes?.yandex_code ?? s.codes?.yandex)?
                    .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                guard let rawCode, !rawCode.isEmpty else { continue }
                
                let cityId = rawCode.hasPrefix("c") ? rawCode : "c\(rawCode)"
                guard seen.insert(cityId).inserted else { continue }
                
                var lat: Double? = nil
                var lon: Double? = nil
                if let stations = s.stations {
                    if let st = stations.first(where: { $0.lat != nil && $0.lng != nil }) {
                        lat = st.lat
                        lon = st.lng
                    }
                }
                
                result.append(
                    City(
                        id: cityId,
                        title: rawTitle,
                        region: regionTitle,
                        country: countryTitle,
                        lat: lat,
                        lon: lon
                    )
                )
            }
        }
        
        result.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        
#if DEBUG
        let sample = result.prefix(10).map(\.title)
        print("✅ [API] russian cities=\(result.count) sample(10)=\(sample) missingCodes=0")
#endif
        
        return result
    }
}
