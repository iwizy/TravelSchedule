//
//  Station.swift
//  TravelSchedule
//
//  Модель станции

import Foundation

struct Station: Identifiable, Sendable, Hashable, Codable {
    let id: String
    let title: String
    let transportType: String?
    let stationType: String?
    let lat: Double?
    let lon: Double?
    let cityId: String
    
    init(
        id: String,
        title: String,
        transportType: String?,
        stationType: String?,
        lat: Double?,
        lon: Double?,
        cityId: String
    ) {
        self.id = id
        self.title = title
        self.transportType = transportType
        self.stationType = stationType
        self.lat = lat
        self.lon = lon
        self.cityId = cityId
    }
}
