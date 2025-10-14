//
//  Carrier.swift
//  TravelSchedule
//

import Foundation

struct Carrier: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let name: String
    let logoAsset: String
    let logoURL: URL?
    let email: String?
    let phoneE164: String?
    let phoneDisplay: String?
}
