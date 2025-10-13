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
    
    static var forceServerErrorEnabled: Bool {
#if DEBUG
        return ProcessInfo.processInfo.environment["FORCE_SERVER_ERROR"] == "1"
#else
        return false
#endif
    }
    
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
        if Self.forceServerErrorEnabled {
            throw ServerHTTPError(statusCode: 500)
        }
        
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

extension APIClient {
    struct ServerHTTPError: Error {
        let statusCode: Int
    }
    
    func ensureHTTP200(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard http.statusCode == 200 else {
            throw ServerHTTPError(statusCode: http.statusCode)
        }
    }
}
