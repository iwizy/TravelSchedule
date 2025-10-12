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
#if DEBUG
        let kv = params.map { "\($0.key)=\($0.value)" }.joined(separator: " ")
        print("➡️ [API] \(name) start \(kv)")
#endif
        let t0 = Date()
        do {
            let value = try await work()
#if DEBUG
            let dt = Date().timeIntervalSince(t0)
            print("✅ [API] \(name) done (\(String(format: "%.3f", dt))s)")
#endif
            return value
        } catch {
#if DEBUG
            let dt = Date().timeIntervalSince(t0)
            print("❌ [API] \(name) error (\(String(format: "%.3f", dt))s): \(error as NSError)")
#endif
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
