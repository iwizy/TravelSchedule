//
//  MainRoute.swift
//  TravelSchedule
//

import Foundation

// MARK: - RouteField enum
enum RouteField: Hashable, Sendable {
    case from
    case to
}

// MARK: - RouteSummary model
struct RouteSummary: Hashable, Sendable {
    let fromCity: String
    let fromStation: String
    let toCity: String
    let toStation: String
    
    var title: String {
        "\(fromCity) (\(fromStation)) → \(toCity) (\(toStation))"
    }
}

// MARK: - MainRoute enum (navigation destinations)
enum MainRoute: Hashable, Sendable {
    case city(RouteField)
    case station(City, RouteField)
    case carriers(RouteSummary)
    case carrierInfo(Carrier)
    case filters
}
