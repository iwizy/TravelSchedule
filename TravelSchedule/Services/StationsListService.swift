//
//  StationsListService.swift
//  TravelSchedule
//
//  Created by Alexander Agafonov on 24.08.2025.
//


import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias AllStationsResponse = Components.Schemas.AllStationsResponse

protocol StationsListServiceProtocol {
    func getStationsList() async throws -> AllStationsResponse
}

final class StationsListService: StationsListServiceProtocol {
    private let client: Client
    private let apikey: String

    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }

    func getStationsList() async throws -> AllStationsResponse {
        let output = try await client.getStationsList(query: .init(
            apikey: apikey,
            lang: "ru_RU",
            format: "json"
        ))

        switch output {
        case .ok(let ok):
            switch ok.body {
            case .json(let payload):
                // Нормальный случай: Content-Type: application/json
                return payload

            case .html(let body):
                var data = Data()
                for try await chunk in body {
                    data.append(contentsOf: chunk)   // добавляем байты, а не Data
                }
                return try JSONDecoder().decode(AllStationsResponse.self, from: data)
            }

        default:
            throw URLError(.badServerResponse)
        }
    }
}
