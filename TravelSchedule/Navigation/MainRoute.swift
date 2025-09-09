//
//  MainRoute.swift
//  TravelSchedule
//
//  Типы навигации

import Foundation

enum RouteField: Hashable {
    case from
    case to
}

enum MainRoute: Hashable {
    case city(RouteField)
    case station(City, RouteField)
}
