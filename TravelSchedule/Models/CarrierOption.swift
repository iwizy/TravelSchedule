//
//  CarrierOption.swift
//  TravelSchedule
//
//  Модель перевозчиков

import Foundation

struct CarrierOption: Identifiable, Hashable {
    let id = UUID()
    let carrierName: String
    let logoName: String
    let dateText: String
    let depart: String
    let arrive: String
    let durationText: String
    let transferNote: String?
    let email: String?
    let phoneE164: String?
    let phoneDisplay: String?
    var logoURL: URL? = nil
}
