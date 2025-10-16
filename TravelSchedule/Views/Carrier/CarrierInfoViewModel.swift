//
//  CarrierInfoViewModel.swift
//  TravelSchedule
//

import SwiftUI
import Combine

// MARK: - CarrierInfoViewModel
@MainActor
final class CarrierInfoViewModel: ObservableObject {
    // MARK: - Published state
    @Published private(set) var carrier: Carrier
    
    // MARK: UI
    let title = String(localized: "carrier.info.title", defaultValue: "Информация о перевозчике")
    
    // MARK: - Computed email
    var emailValue: String { carrier.email?.trimmedNonEmpty ?? "—" }
    var emailURL: URL? {
        guard let e = carrier.email?.trimmedNonEmpty else { return nil }
        return URL(string: "mailto:\(e)")
    }
    
    // MARK: - Computed phone
    var phoneDisplayValue: String { carrier.phoneDisplay?.trimmedNonEmpty ?? "—" }
    var phoneURL: URL? {
        guard let raw = carrier.phoneE164?.trimmedNonEmpty else { return nil }
        let digits = raw.filter { "+0123456789".contains($0) }
        guard !digits.isEmpty else { return nil }
        return URL(string: "tel://\(digits)")
    }
    
    // MARK: - Init
    init(carrier: Carrier) {
        self.carrier = carrier
    }
}
