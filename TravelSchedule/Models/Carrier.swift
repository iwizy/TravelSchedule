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
    let email: String?
    let phoneE164: String?
    let phoneDisplay: String?
}

extension Carrier {
    static let mock = Carrier(
        id: "rzd",
        name: "ОАО «РЖД»",
        logoAsset: "rzd_logo",
        email: "i.lozgkina@yandex.ru",
        phoneE164: "+79043292771",
        phoneDisplay: "+7 (904) 329-27-71"
    )
}
