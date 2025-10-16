//
//  RootTabsView.swift
//  TravelSchedule
//

import SwiftUI

enum AppTab: Hashable {
    case main
    case settings
}

// MARK: - RootTabsView
struct RootTabsView: View {
    @State private var selectedTab: AppTab = .main
    @StateObject private var mainRouter = MainRouter()
    @State private var settingsPath = NavigationPath()
    
    @EnvironmentObject private var errors: ErrorCenter
    @Environment(\.apiClient) private var apiClient
    
    @State private var resetMainOnNextSelect = false
    
    var body: some View {
        // MARK: - Tabs
        TabView(selection: $selectedTab) {
            NavigationStack(path: $mainRouter.path) {
                MainView()
                    .navigationBarTitleDisplayMode(.inline)
            }
            .environmentObject(mainRouter)
            .tabItem { Image("TabIconMain") }
            .tag(AppTab.main)
            .overlay(alignment: .top) {
                Color(.systemBackground)
                    .frame(height: 2)
                    .ignoresSafeArea(edges: .top)
            }
            
            ErrorOverlayHost(showServerError: errors.serverError) {
                NavigationStack(path: $settingsPath) {
                    SettingsView()
                        .navigationTitle(LocalizedStringKey("settings.title"))
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            .tabItem { Image("TabIconSettings") }
            .tag(AppTab.settings)
        }
        .tint(.ypBlack)
        // MARK: - Change Handlers
        .onChange(of: errors.serverError) { _, newValue in
            if newValue {
                selectedTab = .settings
                resetMainOnNextSelect = true
            }
        }
        .onChange(of: selectedTab) { _, newValue in
            if newValue == .main, resetMainOnNextSelect {
                mainRouter.path = []
                Task { @MainActor in
                    await apiClient.invalidateStationsListCache()
                    ErrorCenter.shared.serverError = false
                }
                resetMainOnNextSelect = false
            }
        }
    }
}

#Preview {
    RootTabsView()
        .environmentObject(ErrorCenter.shared)
        .environmentObject(NetworkMonitor.shared)
}
