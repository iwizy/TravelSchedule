//
//  CityPickerView.swift
//  TravelSchedule
//
//  Экран выбора города

import SwiftUI

struct City: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let stations: [Station]
}

struct Station: Identifiable, Hashable {
    let id = UUID()
    let name: String
}

struct CityPickerView: View {
    let field: RouteField
    @EnvironmentObject var router: MainRouter
    
    @State private var query: String = ""
    
    private let allCities: [City] = [
        City(name: "Москва", stations: [
            Station(name: "Киевский вокзал"),
            Station(name: "Курский вокзал"),
            Station(name: "Ярославский вокзал"),
            Station(name: "Белорусский вокзал"),
            Station(name: "Савёловский вокзал"),
            Station(name: "Ленинградский вокзал")
        ]),
        City(name: "Санкт Петербург", stations: [
            Station(name: "Балтийский вокзал"),
            Station(name: "Ладожский вокзал"),
            Station(name: "Московский вокзал"),
        ]),
        City(name: "Сочи", stations: [Station(name: "Сочи")]),
        City(name: "Горный воздух", stations: [Station(name: "Главный вокзал")]),
        City(name: "Краснодар", stations: [Station(name: "Краснодар-1")]),
        City(name: "Казань", stations: [Station(name: "Казань-1")]),
        City(name: "Омск", stations: [Station(name: "Омск-Пасс.")])
    ]
    
    private var filteredCities: [City] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return allCities }
        return allCities.filter { $0.name.lowercased().contains(q) }
    }
    
    var body: some View {
        List {
            Section {
                SearchBar(text: $query, placeholder: "Введите запрос")
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            if filteredCities.isEmpty && !query.isEmpty {
                VStack(spacing: 12) {
                    Spacer(minLength: 60)
                    Text("Город не найден")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.primary)
                    Spacer(minLength: 20)
                }
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            
            ForEach(filteredCities) { city in
                Button {
                    router.path.append(.station(city, field))
                } label: {
                    HStack {
                        Text(city.name)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Выбор города")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("CityPickerView — from") {
    NavigationStack {
        CityPickerView(field: .from)
            .environmentObject(MainRouter())
    }
}

#Preview("CityPickerView — to") {
    NavigationStack {
        CityPickerView(field: .to)
            .environmentObject(MainRouter())
    }
}
