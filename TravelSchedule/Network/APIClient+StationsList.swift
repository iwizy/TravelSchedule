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
                        return model
                    default:
                        break
                    }
                default:
                    break
                }
            } catch {
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

        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        let model = try decoder.decode(Components.Schemas.AllStationsResponse.self, from: data)
        return model
    }
}
