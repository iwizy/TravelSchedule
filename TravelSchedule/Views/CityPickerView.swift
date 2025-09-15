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

    init(field: RouteField, initialQuery: String? = nil) {
        self.field = field
        if let q = initialQuery {
            _query = State(initialValue: q)
        }
    }

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
        ZStack {
            List {
                Section {
                    SearchBar(text: $query, placeholder: "Введите запрос")
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))

                ForEach(Array(filteredCities.enumerated()), id: \.element.id) { idx, city in
                    Button {
                        router.path.append(.station(city, field))
                    } label: {
                        HStack {
                            Text(city.name)
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

            if filteredCities.isEmpty && !query.isEmpty {
                Text("Город не найден")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.ypBlack)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .allowsHitTesting(false)
            }
        }
        .navigationTitle("Выбор города")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview("Список городов") {
    NavigationStack {
        CityPickerView(field: .from)
            .environmentObject(MainRouter())
    }
}

#Preview("Город не найден") {
    NavigationStack {
        CityPickerView(field: .from, initialQuery: "wrgwerg")
            .environmentObject(MainRouter())
    }
}

#Preview("Город найден") {
    NavigationStack {
        CityPickerView(field: .from, initialQuery: "Москва")
            .environmentObject(MainRouter())
    }
}
