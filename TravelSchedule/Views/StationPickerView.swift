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

    init(city: City, initialQuery: String? = nil, onPick: @escaping (_ station: Station) -> Void) {
        self.city = city
        self.onPick = onPick
        if let q = initialQuery {
            _stationQuery = State(initialValue: q)
        }
    }

    private var filteredStations: [Station] {
        let q = stationQuery.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return city.stations }
        return city.stations.filter { $0.name.lowercased().contains(q) }
    }

    var body: some View {
        ZStack {
            List {
                Section {
                    SearchBar(text: $stationQuery, placeholder: "Введите запрос")
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))

                ForEach(Array(filteredStations.enumerated()), id: \.element.id) { idx, station in
                    Button {
                        onPick(station)
                    } label: {
                        HStack {
                            Text(station.name)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.ypBlack)
                        }
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                    .frame(height: 60)
                    .listRowInsets(.init(top: idx == 0 ? 16 : 0, leading: 16, bottom: 0, trailing: 16))
                }
            }
            .listStyle(.plain)
            .listSectionSpacing(.custom(0))

            if filteredStations.isEmpty && !stationQuery.isEmpty {
                Text("Станция не найдена")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.ypBlack)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .allowsHitTesting(false)
            }
        }
        .navigationTitle("Выбор станции")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview("StationPickerView — список") {
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

#Preview("StationPickerView — не найдено") {
    let demoCity = City(
        name: "Москва",
        stations: [
            Station(name: "Киевский вокзал"),
            Station(name: "Курский вокзал"),
            Station(name: "Ярославский вокзал")
        ]
    )

    return NavigationStack {
        StationPickerView(city: demoCity, initialQuery: "zzz") { _ in }
    }
}

#Preview("StationPickerView — найдено (поиск)") {
    let demoCity = City(
        name: "Москва",
        stations: [
            Station(name: "Киевский вокзал"),
            Station(name: "Курский вокзал"),
            Station(name: "Ярославский вокзал")
        ]
    )

    return NavigationStack {
        StationPickerView(city: demoCity, initialQuery: "Курск") { _ in }
    }
}
