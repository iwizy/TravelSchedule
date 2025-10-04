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
        return try await logRequest(
            "stations_list",
            params: ["apikey": apikey]
        ) {
            let output = try await client.getStationsList(query: .init(apikey: apikey))
            switch output {
            case .ok(let ok):
                switch ok.body {
                case .json(let model):
                    let count = model.countries?.count ?? 0
                    print("ℹ️ [API] stations_list countries=\(count)")
                    return model
                    
                case .html(let body):
                    var data = Data()
                    for try await chunk in body {
                        data.append(contentsOf: chunk)
                    }
                    let model = try JSONDecoder().decode(Components.Schemas.AllStationsResponse.self, from: data)
                    let count = model.countries?.count ?? 0
                    print("ℹ️ [API] stations_list (html) countries=\(count)")
                    return model
                }
                
            default:
                throw URLError(.badServerResponse)
            }
        }
    }
}
