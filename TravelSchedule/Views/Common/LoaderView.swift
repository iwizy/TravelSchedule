//
//  LoaderView.swift
//  TravelSchedule
//
//  Лоудер

import SwiftUI

struct LoaderView: View {
    @State private var spinning = false

    var body: some View {
        Image("loader")
            .resizable()
            .frame(width: 48, height: 48)
            .rotationEffect(.degrees(spinning ? 360 : 0))
            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: spinning)
            .onAppear { spinning = true }
            .onDisappear { spinning = false }
            .accessibilityLabel("Загрузка")
    }
}
