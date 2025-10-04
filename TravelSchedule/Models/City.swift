//
//  City.swift
//  TravelSchedule
//
//  Модель города

import Foundation

struct City: Identifiable, Sendable, Hashable, Codable {
    let id: String
    let title: String
    let region: String?
    let country: String?
    let lat: Double?
    let lon: Double?
    let transportTypes: Set<String>
    
    init(
        id: String,
        title: String,
        region: String?,
        country: String?,
        lat: Double?,
        lon: Double?,
        transportTypes: Set<String> = []
    ) {
        self.id = id
        self.title = title
        self.region = region
        self.country = country
        self.lat = lat
        self.lon = lon
        self.transportTypes = transportTypes
    }
}
