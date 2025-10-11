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
    
    private func normalizeCity(_ s: String?) -> String {
        let base = (s ?? "")
            .lowercased()
            .replacingOccurrences(of: "ё", with: "е")
            .replacingOccurrences(of: "й", with: "и")
        let allowed = base.unicodeScalars.filter {
            CharacterSet.alphanumerics.union(CharacterSet(charactersIn: " -")).contains($0)
        }
        let joined = String(String.UnicodeScalarView(allowed))
        return joined
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
    }
    
    private func resolveSettlement(
        catalog: Components.Schemas.AllStationsResponse,
        cityId: String?,
        cityTitle: String?
    ) -> Components.Schemas.Settlement? {
        let wantedId = (cityId ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let wantedTitleRaw = (cityTitle ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let wanted = wantedTitleRaw.lowercased()
        let wantedNorm = normalizeCity(wantedTitleRaw)
        
        func loop(_ block: (Components.Schemas.Settlement) -> Bool) -> Components.Schemas.Settlement? {
            for country in (catalog.countries ?? []) {
                for region in (country.regions ?? []) {
                    for settlement in (region.settlements ?? []) {
                        if block(settlement) { return settlement }
                    }
                }
            }
            return nil
        }
        
        if !wantedId.isEmpty, wantedId.hasPrefix("c"),
           let s = loop({ $0.codes?.yandex_code == wantedId }) {
            print("🔎 [API] settle resolve: by id=\(wantedId)")
            return s
        }
        
        if !wanted.isEmpty,
           let s = loop({
               ($0.title ?? "")
                   .trimmingCharacters(in: .whitespacesAndNewlines)
                   .lowercased() == wanted
           }) {
            print("🔎 [API] settle resolve: by exact title='\(wantedTitleRaw)'")
            return s
        }
        
        if !wanted.isEmpty,
           let s = loop({
               ($0.title ?? "")
                   .trimmingCharacters(in: .whitespacesAndNewlines)
                   .lowercased()
                   .contains(wanted)
           }) {
            print("🔎 [API] settle resolve: by contains title='\(wantedTitleRaw)'")
            return s
        }
        
        if !wantedNorm.isEmpty,
           let s = loop({ normalizeCity($0.title) == wantedNorm }) {
            print("🔎 [API] settle resolve: by normalized title='\(wantedTitleRaw)'")
            return s
        }
        
        print("⚠️ [API] settle resolve failed for id='\(wantedId)' title='\(wantedTitleRaw)'")
        return nil
    }
    
    func getStationsOfCity(cityId: String) async throws -> [StationLite] {
        return try await logRequest("stations_of_city", params: ["cityId": cityId]) {
            
            let catalog: Components.Schemas.AllStationsResponse
            if let cached = self.getStationsListCachedV2() {
                catalog = cached
            } else {
                let loaded = try await self.getStationsList(forceReload: false)
                self.setStationsListCacheV2(loaded)
                catalog = loaded
            }
            
            guard let settlement = self.resolveSettlement(catalog: catalog, cityId: cityId, cityTitle: nil) else {
                print("❌ [API] stations_of_city: settlement not resolved for cityId=\(cityId)")
                return []
            }
            
            let stations: [Components.Schemas.Station] = settlement.stations ?? []
            let withCode = stations.filter { ($0.codes?.yandex_code ?? "").isEmpty == false }.count
            
            let result: [StationLite] = stations.compactMap { st -> StationLite? in
                let sCode = st.codes?.yandex_code ?? st.code
                guard let s = sCode, !s.isEmpty else { return nil }
                let title = st.title ?? "—"
                return StationLite(
                    id: s,
                    title: title,
                    transportType: nil,
                    stationType: nil,
                    lat: nil,
                    lon: nil,
                    cityId: settlement.codes?.yandex_code
                )
            }
            
            print("✅ [API] stations_of_city(cId=\(cityId)): '\(settlement.title ?? cityId)' total=\(stations.count) withCode=\(withCode) result=\(result.count)")
            if result.isEmpty {
                let sample = stations.prefix(10).map {
                    "codes.yandex_code=\($0.codes?.yandex_code ?? "nil") code=\($0.code ?? "nil") title=\($0.title ?? "nil")"
                }
                print("🔍 [API] stations_of_city: sample(10)=\(sample)")
            }
            return result
        }
    }
    
    
    func getStationsOfCity(cityTitle: String, cityId: String) async throws -> [StationLite] {
        if cityId.isEmpty == false {
            return try await getStationsOfCity(cityId: cityId)
        }
        
        let titleTrimmed = cityTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard titleTrimmed.isEmpty == false else { return [] }
        
        return try await logRequest("stations_of_city", params: ["cityTitle": titleTrimmed]) {
            
            let catalog: Components.Schemas.AllStationsResponse
            if let cached = self.getStationsListCachedV2() {
                catalog = cached
            } else {
                let loaded = try await self.getStationsList(forceReload: false)
                self.setStationsListCacheV2(loaded)
                catalog = loaded
            }
            
            guard let settlement = self.resolveSettlement(catalog: catalog, cityId: nil, cityTitle: titleTrimmed) else {
                print("❌ [API] stations_of_city: settlement not resolved for title='\(titleTrimmed)'")
                return []
            }
            
            let stations: [Components.Schemas.Station] = settlement.stations ?? []
            let withCode = stations.filter { ($0.codes?.yandex_code ?? "").isEmpty == false }.count
            
            let result: [StationLite] = stations.compactMap { st -> StationLite? in
                let sCode = st.codes?.yandex_code ?? st.code
                guard let s = sCode, !s.isEmpty else { return nil }
                let title = st.title ?? "—"
                return StationLite(
                    id: s,
                    title: title,
                    transportType: nil,
                    stationType: nil,
                    lat: nil,
                    lon: nil,
                    cityId: settlement.codes?.yandex_code
                )
            }
            
            print("✅ [API] stations_of_city(title='\(titleTrimmed)'): '\(settlement.title ?? titleTrimmed)' total=\(stations.count) withCode=\(withCode) result=\(result.count)")
            if result.isEmpty {
                let sample = stations.prefix(10).map {
                    "codes.yandex_code=\($0.codes?.yandex_code ?? "nil") code=\($0.code ?? "nil") title=\($0.title ?? "nil")"
                }
                print("🔍 [API] stations_of_city(title): sample(10)=\(sample)")
            }
            return result
        }
    }
}
