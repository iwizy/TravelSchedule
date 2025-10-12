//
//  APIClient+StationsList.swift
//  TravelSchedule
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

extension APIClient {
    func getStationsList() async throws -> Components.Schemas.AllStationsResponse {
        try await logRequest("stations_list", params: [
            "lang": "ru_RU",
            "format": "json"
        ]) {
            do {
                let output = try await client.getStationsList(
                    query: .init(
                        lang: "ru_RU",
                        format: "json"
                    )
                )

                switch output {
                case .ok(let ok):
                    switch ok.body {
                    case .json(let model):
#if DEBUG
                        let count = model.countries?.count ?? 0
                        print("ℹ️ [API] stations_list (codegen) countries=\(count)")
#endif
                        return model
                    default:
#if DEBUG
                        print("⚠️ [API] stations_list: unexpected content type in codegen — fallback")
#endif
                        break
                    }
                default:
#if DEBUG
                    print("⚠️ [API] stations_list: non-200 in codegen — fallback")
#endif
                    break
                }
            } catch {
#if DEBUG
                print("⚠️ [API] stations_list codegen failed → fallback. error=\(error as NSError)")
#endif
            }

            return try await Self.fetchStationsListFallback(
                session: self.session,
                apikey: self.apikey,
                baseURLString: Constants.apiURL
            )
        }
    }

    private static func fetchStationsListFallback(
        session: URLSession,
        apikey: String,
        baseURLString: String
    ) async throws -> Components.Schemas.AllStationsResponse {
        guard var comps = URLComponents(string: baseURLString) else {
            throw URLError(.badURL)
        }
        var path = comps.path
        if !path.hasSuffix("/") { path.append("/") }
        path.append("stations_list/")
        comps.path = path

        comps.queryItems = [
            .init(name: "apikey", value: apikey),
            .init(name: "format", value: "json"),
            .init(name: "lang", value: "ru_RU")
        ]

        guard let url = comps.url else { throw URLError(.badURL) }

#if DEBUG
        print("🔎 [HTTP] stations_list → \(url.absoluteString)")
#endif

        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        let model = try decoder.decode(Components.Schemas.AllStationsResponse.self, from: data)

#if DEBUG
        let count = model.countries?.count ?? 0
        print("ℹ️ [API] stations_list (fallback) countries=\(count)")
#endif

        return model
    }
}
