//
//  APIClient+StationsList.swift
//  TravelSchedule
//

import Foundation

extension APIClient {

    private static var __stationsListCacheV2: Components.Schemas.AllStationsResponse?
    private static let __stationsListCacheLock = NSLock()

    func getStationsListCachedV2() -> Components.Schemas.AllStationsResponse? {
        Self.__stationsListCacheLock.lock()
        defer { Self.__stationsListCacheLock.unlock() }
        return Self.__stationsListCacheV2
    }

    func setStationsListCacheV2(_ value: Components.Schemas.AllStationsResponse) {
        Self.__stationsListCacheLock.lock()
        Self.__stationsListCacheV2 = value
        Self.__stationsListCacheLock.unlock()
    }

    func invalidateStationsListCacheV2() {
        setStationsListCacheV2(.init())
    }

    func getStationsList(forceReload: Bool = false) async throws -> Components.Schemas.AllStationsResponse {
        if !forceReload, let cached = getStationsListCachedV2() {
            return cached
        }

        return try await logRequest(
            "stations_list",
            params: ["format": "json", "lang": "ru_RU"]
        ) {
            var comps = URLComponents(url: self.serverURL, resolvingAgainstBaseURL: false)!
            comps.path = "/v3.0/stations_list/"
            comps.queryItems = [
                URLQueryItem(name: "apikey", value: self.apikey),
                URLQueryItem(name: "format", value: "json"),
                URLQueryItem(name: "lang", value: "ru_RU"),
            ]
            guard let url = comps.url else { throw URLError(.badURL) }

            print("🔎 [HTTP] stations_list → \(url.absoluteString)")

            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            guard (200..<300).contains(http.statusCode) else {
                let body = String(data: data, encoding: .utf8) ?? ""
                print("⚠️ [API] stations_list HTTP \(http.statusCode). Body:\n\(body)")
                throw URLError(.badServerResponse)
            }

            let decoder = JSONDecoder()
            let model = try decoder.decode(Components.Schemas.AllStationsResponse.self, from: data)
            print("ℹ️ [API] stations_list countries=\(model.countries?.count ?? 0)")

            setStationsListCacheV2(model)
            return model
        }
    }
}
