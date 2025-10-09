//
//  CarrierInfoViewModel.swift
//  TravelSchedule
//

import SwiftUI
import Combine

@MainActor
final class CarrierInfoViewModel: ObservableObject {
    @Published private(set) var carrier: Carrier
    @Published var title: String = "Информация о перевозчике"
    
    var emailValue: String { carrier.email?.trimmedNonEmpty ?? "—" }
    var emailURL: URL? {
        guard let e = carrier.email?.trimmedNonEmpty else { return nil }
        return URL(string: "mailto:\(e)")
    }
    
    var phoneDisplayValue: String { carrier.phoneDisplay?.trimmedNonEmpty ?? "—" }
    var phoneURL: URL? {
        guard let raw = carrier.phoneE164?.trimmedNonEmpty else { return nil }
        let digits = raw.filter { "+0123456789".contains($0) }
        guard !digits.isEmpty else { return nil }
        return URL(string: "tel://\(digits)")
    }
    
    init(carrier: Carrier) {
        self.carrier = carrier
        if !carrier.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.title = carrier.name
        }
    }
}

private extension String {
    var trimmedNonEmpty: String? {
        let s = trimmingCharacters(in: .whitespacesAndNewlines)
        return s.isEmpty ? nil : s
    }
}
