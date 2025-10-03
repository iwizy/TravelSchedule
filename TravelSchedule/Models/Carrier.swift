//
//  Carrier.swift
//  TravelSchedule
//
//  Модель перевозчика



struct Carrier: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let logoAsset: String
    let email: String?
    let phoneE164: String?
    let phoneDisplay: String?
}
