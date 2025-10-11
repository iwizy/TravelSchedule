//
//  APIClient+Environment.swift
//  TravelSchedule
//

import SwiftUI

private struct APIClientKey: EnvironmentKey {
    static let defaultValue: APIClient = APIClient(
        apikey: Constants.apiKey,
        serverURL: URL(string: Constants.apiURL)!
    )
}

extension EnvironmentValues {
    var apiClient: APIClient {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
}

