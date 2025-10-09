//
//  NearestSettlementService.swift
//  TravelSchedule
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias NearestSettlementResponse = Components.Schemas.NearestSettlementResponse

protocol NearestSettlementServiceProtocol {
  func getNearestSettlement(lat: Double, lng: Double, distance: Int?) async throws -> NearestSettlementResponse
}

final class NearestSettlementService: NearestSettlementServiceProtocol {
  private let client: Client
  private let apikey: String

  init(client: Client, apikey: String) {
    self.client = client
    self.apikey = apikey
  }

  func getNearestSettlement(lat: Double, lng: Double, distance: Int? = nil) async throws -> NearestSettlementResponse {
    let response = try await client.getNearestSettlement(query: .init(
      apikey: apikey,
      lat: lat,
      lng: lng,
      distance: distance
    ))
    return try response.ok.body.json
  }
}
