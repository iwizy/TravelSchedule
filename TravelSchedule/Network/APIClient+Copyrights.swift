//
//  APIClient+Copyrights.swift
//  TravelSchedule
//
//  Сервис копирайта

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

extension APIClient {
    func getCopyrights() async throws -> Components.Schemas.CopyrightsResponse {
        let output = try await client.getCopyrights(query: .init(apikey: apikey))
        switch output {
        case .ok(let ok):
            return try ok.body.json
        default:
            throw URLError(.badServerResponse)
        }
    }
}
