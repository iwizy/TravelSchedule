//
//  MainRoute.swift
//  TravelSchedule
//

import Foundation

enum RouteField: Hashable, Sendable {
    case from
    case to
}

struct RouteSummary: Hashable, Sendable {
    let fromCity: String
    let fromStation: String
    let toCity: String
    let toStation: String
    
    var title: String {
        "\(fromCity) (\(fromStation)) → \(toCity) (\(toStation))"
    }
}

enum MainRoute: Hashable, Sendable {
    case city(RouteField)
    case station(City, RouteField)
    case carriers(RouteSummary)
    case carrierInfo(Carrier)
    case filters
}
