//
//  ThreadService.swift
//  TravelSchedule
//
//  Created by Alexander Agafonov on 23.08.2025.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias ThreadStationsResponse = Components.Schemas.ThreadStationsResponse

protocol ThreadServiceProtocol {
    func getThread(
        uid: String,
        from: String?,
        to: String?,
        date: String?,
        showSystems: String?
    ) async throws -> ThreadStationsResponse
}

final class ThreadService: ThreadServiceProtocol {
    private let client: Client
    private let apikey: String

    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }

    func getThread(
        uid: String,
        from: String? = nil,
        to: String? = nil,
        date: String? = nil,
        showSystems: String? = nil
    ) async throws -> ThreadStationsResponse {
        let response = try await client.getThread(query: .init(
            apikey: apikey,
            uid: uid,
            from: from,
            to: to,
            date: date,
            show_systems: showSystems
        ))
        return try response.ok.body.json
    }
}
