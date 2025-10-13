//
//  ErrorOverlayHost.swift
//  TravelSchedule
//

import SwiftUI

struct ErrorOverlayHost<Content: View>: View {
    @EnvironmentObject private var network: NetworkMonitor
    private let content: Content

    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        ZStack {
            content

            if !network.isOnline {
                ErrorPlaceholderView(type: .noInternet)
                    .ignoresSafeArea(.container, edges: [.top, .leading, .trailing])
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
    }
}
