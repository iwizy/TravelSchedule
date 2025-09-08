//
//  TravelScheduleApp.swift
//  TravelSchedule
//
//  Created by Alexander Agafonov on 23.08.2025.
//

import SwiftUI

@main
struct TravelScheduleApp: App {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.shadowColor = UIColor(.ypBlack)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    var body: some Scene {
        WindowGroup {
            RootTabsView()
        }
    }
}
