//
//  MainRoute.swift
//  TravelSchedule
//

import Foundation

enum RouteField: Hashable {
    case from
    case to
}

struct RouteSummary: Hashable {
    let fromCity: String
    let fromStation: String
    let toCity: String
    let toStation: String
    
    var title: String {
        "\(fromCity) (\(fromStation)) → \(toCity) (\(toStation))"
    }
}

enum MainRoute: Hashable {
    case city(RouteField)
    case station(City, RouteField)
    case carriers(RouteSummary)
    case carrierInfo(Carrier)
    case filters
}
