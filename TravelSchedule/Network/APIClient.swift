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
}
