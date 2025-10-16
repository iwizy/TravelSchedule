//
//  ErrorCenter.swift
//  TravelSchedule
//

import SwiftUI

// MARK: - ErrorCenter
@MainActor
final class ErrorCenter: ObservableObject {
    static let shared = ErrorCenter()
    @Published var serverError: Bool = false
}
