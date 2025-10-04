//
//  RootTabsView.swift
//  TravelSchedule
//
//  Вью ТабБара

import SwiftUI

enum AppTab: Hashable {
    case main
    case settings
}

struct RootTabsView: View {
    @State private var selectedTab: AppTab = .main
    @StateObject private var mainRouter = MainRouter()
    @State private var settingsPath = NavigationPath()
    
    var body: some View {
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
            
            NavigationStack(path: $settingsPath) {
                SettingsView()
                    .navigationTitle("Настройки")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem { Image("TabIconSettings") }
            .tag(AppTab.settings)
        }
        .tint(.ypBlack)
    }
}

#Preview {
    RootTabsView()
}
