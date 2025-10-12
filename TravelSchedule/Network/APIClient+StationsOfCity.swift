//
//  APIClient+StationsOfCity.swift
//  TravelSchedule
//

import Foundation

extension APIClient {
    struct StationLite: Hashable, Codable {
        let id: String
        let title: String
        let transportType: String?
        let stationType: String?
        let lat: Double?
        let lon: Double?
        let cityId: String?
    }
    
    func getStationsOfCity(
        cityTitle: String,
        cityId: String?
    ) async throws -> [StationLite] {
        
        try await logRequest("stations_of_city", params: [
            "cityTitle": cityTitle,
            "cityId": cityId ?? ""
        ]) {
            let catalog = try await getStationsListCached()
            let countries = catalog.countries ?? []
            
            func normalizeCityCode(_ raw: String?) -> String? {
                guard var s = raw?.trimmingCharacters(in: .whitespacesAndNewlines),
                      !s.isEmpty else { return nil }
                while let first = s.first, first.isLetter { s.removeFirst() }
                return s.isEmpty ? nil : s
            }
            
            func normalizeStationCode(_ raw: String?) -> String? {
                guard let raw, !raw.isEmpty else { return nil }
                let digits = raw.filter(\.isNumber)
                guard !digits.isEmpty else { return nil }
                return "s\(digits)"
            }
            
            func makeStationLite(from st: Components.Schemas.Station, cityId: String?) -> StationLite? {
                let rawCode = st.code
                ?? st.codes?.yandex
                ?? st.codes?.yandex_code
                
                guard let id = normalizeStationCode(rawCode) else { return nil }
                
                let title = (st.title ?? "—").trimmingCharacters(in: .whitespacesAndNewlines)
                return StationLite(
                    id: id,
                    title: title,
                    transportType: st.transport_type,
                    stationType: st.station_type,
                    lat: st.lat,
                    lon: st.lng,
                    cityId: cityId
                )
            }
            
            func collectStations(where predicate: (Components.Schemas.Settlement) -> Bool,
                                 cityIdForResult: String?) -> ([StationLite], Int, Int) {
                var acc: [StationLite] = []
                var matchedSettlements = 0
                var rawStationsSeen = 0
                
                for country in countries {
                    for region in (country.regions ?? []) {
                        for settlement in (region.settlements ?? []) where predicate(settlement) {
                            matchedSettlements += 1
                            let stations = settlement.stations ?? []
                            rawStationsSeen += stations.count
                            for st in stations {
                                if let lite = makeStationLite(from: st, cityId: cityIdForResult) {
                                    acc.append(lite)
                                }
                            }
                        }
                    }
                }
                return (acc, matchedSettlements, rawStationsSeen)
            }
            
            let normalizedId = normalizeCityCode(cityId)
            if let code = normalizedId {
                let (byCode, matched, rawCount) = collectStations(where: { settlement in
                    let sc = settlement.codes
                    let sCode = sc?.yandex_code ?? sc?.yandex
                    if let sCode, let norm = normalizeCityCode(sCode) {
                        return norm == code
                    }
                    return false
                }, cityIdForResult: code)
                
                if !byCode.isEmpty {
                    return byCode
                }
            }
            
            let qTitle = cityTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            let qLower = qTitle.lowercased()
            
            let (byExact, exactMatched, exactRaw) = collectStations(where: { s in
                let t = (s.title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                return t.compare(qTitle, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
            }, cityIdForResult: normalizedId)
            
            if !byExact.isEmpty {
                return byExact
            }
            
            let (byContains, containsMatched, containsRaw) = collectStations(where: { s in
                let t = (s.title ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                return t.contains(qLower)
            }, cityIdForResult: normalizedId)
            return byContains
        }
    }
}
