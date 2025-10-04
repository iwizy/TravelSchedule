//
//  APIClient+StationsOfCity.swift
//  TravelSchedule
//
//  Created by Alexander Agafonov on 04.10.2025.
//

import Foundation

extension APIClient {
    func getStationsOfCity(cityId: String) async throws -> [Station] {
        return try await logRequest("stations_of_city", params: ["cityId": cityId]) {
            let all = try await getStationsList()
            guard let russia = (all.countries ?? []).first(where: { $0.codes?.yandex_code == "c146" }) else {
                print("⚠️ [API] Country c146 (Россия) not found")
                return []
            }

            for region in (russia.regions ?? []) {
                for settlement in (region.settlements ?? []) {
                    guard settlement.codes?.yandex_code == cityId else { continue }
                    let rawStations = settlement.stations ?? []
                    let mapped: [Station] = rawStations.compactMap { s in
                        guard let sid = s.codes?.yandex_code, let title = s.title else { return nil }
                        return Station(
                            id: sid,
                            title: title,
                            transportType: s.transport_type,
                            stationType: s.station_type,
                            lat: s.lat,
                            lon: s.lng,
                            cityId: cityId
                        )
                    }
                    print("ℹ️ [API] stations_of_city cityId=\(cityId) count=\(mapped.count)")
                    return mapped.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
                }
            }

            print("ℹ️ [API] stations_of_city cityId=\(cityId) not found")
            return []
        }
    }
}
