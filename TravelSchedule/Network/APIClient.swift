//
//  APIClient.swift
//  TravelSchedule
//
//  Клиент API

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

actor APIClient {

    private let client: Client
    private let apikey: String

    init(
        serverURL: URL,
        apikey: String,
        transport: any ClientTransport = URLSessionTransport()
    ) {
        self.client = Client(serverURL: serverURL, transport: transport)
        self.apikey = apikey
    }

    // MARK: - Copyrights
    func getCopyrights() async throws -> Components.Schemas.CopyrightsResponse {
        let output = try await client.getCopyrights(query: .init(apikey: apikey))
        switch output {
        case .ok(let ok):
            return try ok.body.json
        default:
            throw URLError(.badServerResponse)
        }
    }

    // MARK: - Stations List
    func getStationsList() async throws -> Components.Schemas.AllStationsResponse {
        let output = try await client.getStationsList(query: .init(apikey: apikey))
        switch output {
        case .ok(let ok):
            switch ok.body {
            case .json(let model):
                return model
            case .html(let body):
                var data = Data()
                for try await chunk in body {
                    data.append(contentsOf: chunk)
                }
                return try JSONDecoder().decode(Components.Schemas.AllStationsResponse.self, from: data)
            }
        default:
            throw URLError(.badServerResponse)
        }
    }

    // MARK: - TODO
    // - getScheduleBetweenStations(...)
    // - getScheduleOnStation(...)
    // - getThread(...)
    // - getCarriers(...)
    // - getNearestSettlement(...)
    // - getNearestStations(...)
}
