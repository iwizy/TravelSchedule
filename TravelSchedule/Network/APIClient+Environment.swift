//
//  APIClient+Environment.swift
//  TravelSchedule
//
//  Расширение клиента

import SwiftUI

private struct APIClientKey: EnvironmentKey {
    static let defaultValue: APIClient = APIClient(
        serverURL: URL(string: Constants.apiURL)!,
        apikey: Constants.apiKey
    )
}

extension EnvironmentValues {
    var apiClient: APIClient {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
}
