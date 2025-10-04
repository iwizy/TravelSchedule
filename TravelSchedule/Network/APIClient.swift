//
//  APIClient.swift
//  TravelSchedule
//
//  Клиент API

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

actor APIClient {
    let client: Client
    let apikey: String
    
    init(
        serverURL: URL,
        apikey: String,
        transport: any ClientTransport = URLSessionTransport()
    ) {
        self.client = Client(serverURL: serverURL, transport: transport)
        self.apikey = apikey
    }
    
    // MARK: - Единое логирование всех API-запросов
    @discardableResult
    func logRequest<T>(
        _ name: String,
        params: [String: CustomStringConvertible] = [:],
        _ block: () async throws -> T
    ) async rethrows -> T {
        let started = Date()
        let paramsText = params.isEmpty
        ? ""
        : " " + params.map { "\($0.key)=\($0.value)" }.joined(separator: " ")
        print("➡️ [API] \(name) start\(paramsText)")
        do {
            let value = try await block()
            let elapsed = String(format: "%.3f", Date().timeIntervalSince(started))
            print("✅ [API] \(name) success (\(elapsed)s)")
            return value
        } catch {
            let elapsed = String(format: "%.3f", Date().timeIntervalSince(started))
            print("❌ [API] \(name) error (\(elapsed)s): \(error)")
            throw error
        }
    }
}
