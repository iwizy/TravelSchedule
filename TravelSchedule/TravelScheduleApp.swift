//
//  TravelScheduleApp.swift
//  TravelSchedule
//
//  Created by Alexander Agafonov on 23.08.2025.
//

import SwiftUI

@main
struct TravelScheduleApp: App {
    @StateObject private var themeManager = ThemeManager()
    
    private let apiClient = APIClient(
        serverURL: URL(string: Constants.apiURL)!,
        apikey: Constants.apiKey
    )
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypWhite
        appearance.shadowColor = UIColor(.ypBlack)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    var body: some Scene {
        WindowGroup {
            RootTabsView()
                .environment(\.apiClient, apiClient)
                .environmentObject(themeManager)
                .onAppear {
                    let isDark = UITraitCollection.current.userInterfaceStyle == .dark
                    themeManager.bindToSystem(isDark ? .dark : .light)
                }
                .preferredColorScheme(themeManager.effectiveScheme)
        }
    }
}
