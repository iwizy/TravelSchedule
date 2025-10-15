//
//  ThemeManager.swift
//  TravelSchedule
//

import SwiftUI

// MARK: - ThemeOverride
enum ThemeOverride: String { case light, dark }

// MARK: - ThemeManager
@MainActor
final class ThemeManager: ObservableObject {
    @AppStorage("app.themeOverride") private var storedOverride: String?
    @Published private(set) var override: ThemeOverride?
    @Published private(set) var effectiveScheme: ColorScheme?
    
    // MARK: Init
    init() {
        override = storedOverride.flatMap(ThemeOverride.init(rawValue:))
        recomputeEffective()
    }
    
    // MARK: Public API
    func setOverride(_ new: ThemeOverride) {
        override = new
        storedOverride = new.rawValue
        recomputeEffective()
    }
    
    func clearOverride() {
        override = nil
        storedOverride = nil
        recomputeEffective()
    }
    
    func bindToSystem(_ system: ColorScheme) {
        if override == nil { effectiveScheme = system }
    }
    
    // MARK: Private
    private func recomputeEffective() {
        if let o = override { effectiveScheme = (o == .dark ? .dark : .light) }
        else { effectiveScheme = nil }
    }
}
