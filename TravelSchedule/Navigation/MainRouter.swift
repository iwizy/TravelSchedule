//
//  MainRouter.swift
//  TravelSchedule
//

import SwiftUI

@MainActor
final class MainRouter: ObservableObject {
    @Published var path: [MainRoute] = []
}
