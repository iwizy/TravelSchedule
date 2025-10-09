//
//  APIClient+StationsOfCity.swift
//  TravelSchedule
//

import Foundation

extension APIClient {
    func getStationsOfCity(cityId: String, cityTitle: String? = nil) async throws -> [Station] {
        return try await logRequest("stations_of_city", params: ["cityId": cityId, "cityTitle": cityTitle ?? ""]) {
            let all = try await getStationsList()

            guard let russia = (all.countries ?? []).first(where: { country in
                let title = (country.title ?? "").folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "ru_RU"))
                let code  = country.codes?.yandex_code ?? ""
                return title.contains("росс") || code == "225" || code == "c146"
            }) else {
                print("⚠️ [API] Country (Россия) not found in stations_list")
                return []
            }

            let settlements: [Components.Schemas.Settlement] = (russia.regions ?? []).flatMap { $0.settlements ?? [] }

            if let byCode = settlements.first(where: { $0.codes?.yandex_code == cityId }) {
                let mapped = mapStations(byCode.stations, fallbackCityId: cityId)
                print("ℹ️ [API] settlements match by code \(cityId): '\(byCode.title ?? "?")', stations=\(mapped.count)")
                if !mapped.isEmpty { return mapped }
            } else {
                print("🔎 [API] no settlement by code \(cityId)")
            }

            if let title = cityTitle?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty {
                let normTitle = normalize(title)
                let matches = settlements.filter { normalize($0.title ?? "") == normTitle }

                if !matches.isEmpty {
                    let preview = matches.map { "\($0.codes?.yandex_code ?? "?"):\($0.title ?? "?")(\($0.stations?.count ?? 0))" }
                        .joined(separator: " | ")
                    print("ℹ️ [API] settlements match by title '\(title)': \(matches.count) → \(preview)")

                    let aggregated: [Station] = matches
                        .flatMap { mapStations($0.stations, fallbackCityId: $0.codes?.yandex_code ?? cityId) }
                        .reduce(into: [String: Station]()) { dict, station in
                            dict[station.id] = dict[station.id] ?? station
                        }
                        .map { $0.value }
                        .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }

                    print("ℹ️ [API] aggregated stations by title '\(title)' = \(aggregated.count)")
                    if !aggregated.isEmpty { return aggregated }
                } else {
                    print("🔎 [API] no settlements match by title '\(title)'")
                }
            }

            print("ℹ️ [API] stations_of_city cityId=\(cityId) result=0")
            return []
        }
    }

    // MARK: - helpers
    private func mapStations(_ raw: [Components.Schemas.Station]?, fallbackCityId: String) -> [Station] {
        let items: [Station] = (raw ?? []).compactMap { s in
            guard let sid = s.codes?.yandex_code, let title = s.title else { return nil }
            return Station(
                id: sid,
                title: title,
                transportType: s.transport_type,
                stationType: s.station_type,
                lat: s.lat,
                lon: s.lng,
                cityId: fallbackCityId
            )
        }
        return items.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    private func normalize(_ s: String) -> String {
        let replacedYo = s.replacingOccurrences(of: "ё", with: "е").replacingOccurrences(of: "Ё", with: "Е")
        return replacedYo.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "ru_RU")).lowercased()
    }
}
