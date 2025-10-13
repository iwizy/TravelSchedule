//
//  TravelScheduleApp.swift
//  TravelSchedule
//

import SwiftUI

@main
struct TravelScheduleApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var errorCenter  = ErrorCenter.shared
    // ✅ NEW: прокидываем монитор сети для ErrorOverlayHost
    @StateObject private var network      = NetworkMonitor.shared
    
    private let apiClient = APIClient(
        apikey: Constants.apiKey,
        serverURL: URL(string: Constants.apiURL)!
    )
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypWhite
        appearance.shadowColor = UIColor(.ypBlack)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        
        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = UIColor(.ypWhite)
        nav.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
        UINavigationBar.appearance().tintColor = UIColor(.ypBlack)
        
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
    }
    
    var body: some Scene {
        WindowGroup {
            RootTabsView()
                .environment(\.apiClient, apiClient)
                .environmentObject(themeManager)
                .environmentObject(errorCenter)
                .environmentObject(network)              // ✅ NEW: вот его и не хватало
                .onAppear {
                    let isDark = UITraitCollection.current.userInterfaceStyle == .dark
                    themeManager.bindToSystem(isDark ? .dark : .light)
                }
                .preferredColorScheme(themeManager.effectiveScheme)
        }
    }
}
