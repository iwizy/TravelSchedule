//
//  APIClient.swift
//  TravelSchedule
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

actor APIClient {
    
    let apikey: String
    let serverURL: URL
    let session: URLSession
    let client: Client
    
    private var stationsListCache: Components.Schemas.AllStationsResponse?
    
    init(
        apikey: String,
        serverURL: URL,
        session: URLSession = .shared
    ) {
        self.apikey = apikey
        self.serverURL = serverURL
        self.session = session
        let transport = URLSessionTransport(configuration: .init(session: session))
        self.client = Client(
            serverURL: serverURL,
            transport: transport
        )
    }
    
    @discardableResult
    func logRequest<T>(
        _ name: String,
        params: [String: Any] = [:],
        _ work: @Sendable () async throws -> T
    ) async throws -> T {
        let t0 = Date()
        do {
            let value = try await work()
            return value
        } catch {
            throw error
        }
    }
    
    func getStationsListCached(force: Bool = false) async throws -> Components.Schemas.AllStationsResponse {
        if !force, let cached = stationsListCache {
            return cached
        }
        let fresh = try await getStationsList()
        stationsListCache = fresh
        return fresh
    }
    
    func invalidateStationsListCache() {
        stationsListCache = nil
    }
}
