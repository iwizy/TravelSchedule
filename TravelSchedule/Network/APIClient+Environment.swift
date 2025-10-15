//
//  APIClient+Environment.swift
//  TravelSchedule
//

import SwiftUI

// MARK: - APIClient EnvironmentKey
private struct APIClientKey: EnvironmentKey {
    static let defaultValue: APIClient = {
        let baseURL: URL = {
            if let url = URL(string: Constants.apiURL) {
                return url
            }
            preconditionFailure("Invalid Constants.apiURL: \(Constants.apiURL)")
        }()
        return APIClient(
            apikey: Constants.apiKey,
            serverURL: baseURL
        )
    }()
}

// MARK: - EnvironmentValues extension
extension EnvironmentValues {
    var apiClient: APIClient {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
}

// MARK: - View extension
extension View {
    func apiClient(_ client: APIClient) -> some View {
        environment(\.apiClient, client)
    }
}
