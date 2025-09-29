//
//  SettingsViewModel.swift
//  TravelSchedule
//
//  Модель экрана настроек

import SwiftUI
import Combine

protocol ThemeControlling {
    var override: ThemeOverride? { get }
    var effectiveScheme: ColorScheme? { get }
    func setOverride(_ new: ThemeOverride)
    func clearOverride()
    func bindToSystem(_ system: ColorScheme)
}

final class SettingsViewModel: ObservableObject {
    @Published var isDark: Bool = false
    @Published var showAgreement: Bool = false

    private let theme: ThemeControlling
    private var bag = Set<AnyCancellable>()
    private let systemScheme: () -> ColorScheme

    init(theme: ThemeControlling, systemScheme: @escaping () -> ColorScheme) {
        self.theme = theme
        self.systemScheme = systemScheme

        isDark = (theme.effectiveScheme ?? systemScheme()) == .dark

        $isDark
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] new in
                self?.theme.setOverride(new ? .dark : .light)
            }
            .store(in: &bag)
    }

    func onAppear() {
        if theme.effectiveScheme == nil {
            theme.bindToSystem(systemScheme())
            isDark = (theme.effectiveScheme ?? systemScheme()) == .dark
        }
    }

    func openAgreement() { showAgreement = true }
}
