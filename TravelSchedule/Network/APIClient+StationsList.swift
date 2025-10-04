//
//  APIClient+StationsList.swift
//  TravelSchedule
//
//  Сервис списка станция

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

extension APIClient {
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
}
