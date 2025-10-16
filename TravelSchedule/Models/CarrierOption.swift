//
//  CarrierOption.swift
//  TravelSchedule
//

import Foundation

// MARK: - CarrierOption
struct CarrierOption: Identifiable, Hashable, Sendable {
    let id = UUID()
    let carrierName: String
    let logoName: String
    let dateText: String
    let depart: String
    let arrive: String
    let durationText: String
    let transferNote: String?
    var email: String?
    var phoneE164: String?
    var phoneDisplay: String?
    var logoURL: URL?
    
    var hasTransfer: Bool { transferNote != nil }
}
