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

    @State private var mainPath = NavigationPath()
    @State private var settingsPath = NavigationPath()

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $mainPath) {
                MainView()
                   .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Image("TabIconMain")
            }
            .tag(AppTab.main)

            NavigationStack(path: $settingsPath) {
                SettingsView()
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Image("TabIconSettings")
            }
            .tag(AppTab.settings)
        }
        .tint(.ypBlack)
    }
}

#Preview {
    RootTabsView()
}
