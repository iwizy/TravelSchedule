//
//  Carrier.swift
//  TravelSchedule
//
//  Модель перевозчика

import Foundation

struct Carrier: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let logoAsset: String
    let logoURL: URL?
    let email: String?
    let phoneE164: String?
    let phoneDisplay: String?
}
