//
//  CarrierMock.swift
//  TravelSchedule
//
//  Мок перевозчика для превью

import Foundation

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
