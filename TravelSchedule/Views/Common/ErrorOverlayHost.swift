//
//  ErrorOverlayHost.swift
//  TravelSchedule
//

import SwiftUI

// MARK: - ErrorOverlayHost
struct ErrorOverlayHost<Content: View>: View {
    @EnvironmentObject private var network: NetworkMonitor
    private let content: Content
    var showServerError: Bool
    
    init(
        showServerError: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.showServerError = showServerError
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content
            
            if !network.isOnline {
                ErrorPlaceholderView(type: .noInternet)
                    .ignoresSafeArea(.container, edges: [.top, .leading, .trailing])
                    .allowsHitTesting(false)
                    .transition(.opacity)
                
            } else if showServerError {
                ErrorPlaceholderView(type: .server)
                    .ignoresSafeArea(.container, edges: [.top, .leading, .trailing])
                    .transition(.opacity)
            }
        }
    }
}
