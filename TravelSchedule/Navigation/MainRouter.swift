//
//  MainRouter.swift
//  TravelSchedule
//

import SwiftUI

// MARK: - MainRouter (navigation state)
@MainActor
final class MainRouter: ObservableObject {
    @Published var path: [MainRoute] = []
}
