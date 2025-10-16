//
//  SettingsViewModel.swift
//  TravelSchedule
//

import SwiftUI
import Combine

// MARK: - ThemeControlling
protocol ThemeControlling {
    var override: ThemeOverride? { get }
    var effectiveScheme: ColorScheme? { get }
    func setOverride(_ new: ThemeOverride)
    func clearOverride()
    func bindToSystem(_ system: ColorScheme)
}

// MARK: - SettingsViewModel
@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: State
    @Published var isDark: Bool = false
    @Published var showAgreement: Bool = false
    
    // MARK: Dependencies
    private let theme: ThemeControlling
    private var bag = Set<AnyCancellable>()
    private let systemScheme: () -> ColorScheme
    
    // MARK: Init
    init(theme: ThemeControlling, systemScheme: @escaping () -> ColorScheme) {
        self.theme = theme
        self.systemScheme = systemScheme
        
        isDark = (theme.effectiveScheme ?? systemScheme()) == .dark
        
        // MARK: Bindings
        $isDark
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] new in
                self?.theme.setOverride(new ? .dark : .light)
            }
            .store(in: &bag)
    }
    
    // MARK: Public API
    func onAppear() {
        if theme.effectiveScheme == nil {
            theme.bindToSystem(systemScheme())
            isDark = (theme.effectiveScheme ?? systemScheme()) == .dark
        }
    }
    
    func openAgreement() { showAgreement = true }
}
