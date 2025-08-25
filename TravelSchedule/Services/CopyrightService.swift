//
//  CopyrightService.swift
//  TravelSchedule
//
//  Created by Alexander Agafonov on 24.08.2025.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias CopyrightsResponse = Components.Schemas.CopyrightsResponse

protocol CopyrightServiceProtocol {
    func getCopyrights() async throws -> CopyrightsResponse
}

final class CopyrightService: CopyrightServiceProtocol {
    private let client: Client
    private let apikey: String

    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }

    func getCopyrights() async throws -> CopyrightsResponse {
        let output = try await client.getCopyrights(query: .init(
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
