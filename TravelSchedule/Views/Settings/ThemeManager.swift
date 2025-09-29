//
//  ThemeManager.swift
//  TravelSchedule
//
//  Менеджер темы

import SwiftUI

enum ThemeOverride: String { case light, dark }

final class ThemeManager: ObservableObject {
    @AppStorage("app.themeOverride") private var storedOverride: String?
    @Published private(set) var override: ThemeOverride?
    @Published private(set) var effectiveScheme: ColorScheme?

    init() {
        override = storedOverride.flatMap(ThemeOverride.init(rawValue:))
        recomputeEffective()
    }

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

    private func recomputeEffective() {
        if let o = override { effectiveScheme = (o == .dark ? .dark : .light) }
        else { effectiveScheme = nil }
    }
}
