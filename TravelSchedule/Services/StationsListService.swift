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
            apikey: apikey
        ))

        switch output {
        case .ok(let ok):
            return try ok.body.json
        default:
            throw URLError(.badServerResponse)
        }
    }
}
