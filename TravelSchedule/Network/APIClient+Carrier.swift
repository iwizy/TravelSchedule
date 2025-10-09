//
//  APIClient+Carrier.swift
//  TravelSchedule
//

import Foundation

extension APIClient {
    struct CarrierInfo: Codable {
        let code: String
        let title: String
        let phone: String?
        let phoneDisplay: String?
        let phoneE164: String?
        let email: String?
        let logoURL: URL?
    }
    
    func getCarrierInfo(code: String) async throws -> CarrierInfo {
        let (data, _) = try await URLSession.shared.data(from: URL(string: "https://api.rasp.yandex.net/v3/carrier/?apikey=\(apikey)&code=\(code)")!)
        let decoded = try JSONDecoder().decode(CarrierInfo.self, from: data)
        return decoded
    }
}
