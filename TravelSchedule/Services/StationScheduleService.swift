//
//  StationScheduleService.swift
//  TravelSchedule
//
//  Created by Alexander Agafonov on 23.08.2025.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias StationScheduleResponse = Components.Schemas.ScheduleResponse

protocol StationScheduleServiceProtocol {
    func getScheduleOnStation(
        station: String,
        date: String?,
        transportTypes: String?,
        event: String?,
        direction: String?,
        system: String?,
        resultTimezone: String?
    ) async throws -> StationScheduleResponse
}

final class StationScheduleService: StationScheduleServiceProtocol {
    private let client: Client
    private let apikey: String

    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }

    func getScheduleOnStation(
        station: String,
        date: String? = nil,
        transportTypes: String? = nil,
        event: String? = nil,
        direction: String? = nil,
        system: String? = nil,
        resultTimezone: String? = nil
    ) async throws -> StationScheduleResponse {
        let response = try await client.getScheduleOnStation(query: .init(
            apikey: apikey,
            station: station,
            date: date,
            transport_types: transportTypes,
            event: event,
            direction: direction,
            system: system,
            result_timezone: resultTimezone
        ))
        return try response.ok.body.json
    }
}
