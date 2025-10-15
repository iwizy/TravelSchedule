//
//  LoaderView.swift
//  TravelSchedule
//

import SwiftUI

// MARK: - LoaderView
struct LoaderView: View {
    // MARK: Properties
    @State private var spinning = false
    
    // MARK: Body
    var body: some View {
        Image("loader")
            .resizable()
            .frame(width: 48, height: 48)
            .rotationEffect(.degrees(spinning ? 360 : 0))
            .animation(
                .linear(duration: 1)
                .repeatForever(autoreverses: false),
                value: spinning
            )
            .onAppear { spinning = true }
            .onDisappear { spinning = false }
    }
}

// MARK: - Preview
#Preview {
    LoaderView()
        .padding()
        .background(Color(.systemGray6))
}
