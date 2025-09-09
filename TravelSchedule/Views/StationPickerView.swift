//
//  StationPickerView.swift
//  TravelSchedule
//
//  Экран выбора станции

import SwiftUI

struct StationPickerView: View {
    let city: City
    let onPick: (_ station: Station) -> Void
    
    @State private var stationQuery: String = ""
    
    private var filteredStations: [Station] {
        let q = stationQuery.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return city.stations }
        return city.stations.filter { $0.name.lowercased().contains(q) }
    }
    
    var body: some View {
        List {
            Section {
                SearchBar(text: $stationQuery, placeholder: "Введите запрос")
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            ForEach(filteredStations) { station in
                Button {
                    onPick(station)
                } label: {
                    HStack {
                        Text(station.name)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Выбор станции")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("StationPickerView") {
    let demoCity = City(
        name: "Москва",
        stations: [
            Station(name: "Киевский вокзал"),
            Station(name: "Курский вокзал"),
            Station(name: "Ярославский вокзал"),
            Station(name: "Белорусский вокзал"),
            Station(name: "Савёловский вокзал"),
            Station(name: "Ленинградский вокзал")
        ]
    )
    
    return NavigationStack {
        StationPickerView(city: demoCity) { station in
            print("Picked station: \(station.name)")
        }
    }
}
