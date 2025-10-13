//
//  ErrorCenter.swift
//  TravelSchedule
//

import Foundation

final class ErrorCenter: ObservableObject {
    static let shared = ErrorCenter()
    @Published var serverError: Bool = false
}
