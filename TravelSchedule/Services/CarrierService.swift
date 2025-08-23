//
//  CarrierService.swift
//  TravelSchedule
//
//  Created by Alexander Agafonov on 23.08.2025.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias CarrierResponse = Components.Schemas.CarrierResponse

protocol CarrierServiceProtocol {
    func getCarrier(code: String, system: String?) async throws -> CarrierResponse
}

final class CarrierService: CarrierServiceProtocol {
    private let client: Client
    private let apikey: String

    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }

    func getCarrier(code: String, system: String? = nil) async throws -> CarrierResponse {
        let response = try await client.getCarrier(query: .init(
            apikey: apikey,
            code: code,
            system: system
        ))
        return try response.ok.body.json
    }
}
