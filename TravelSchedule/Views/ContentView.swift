//
//  ContentView.swift
//  TravelSchedule
//
//  Created by Alexander Agafonov on 23.08.2025.
//

import SwiftUI
import OpenAPIRuntime
import OpenAPIURLSession

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            // testFetchCarrier()
            // testFetchNearestStations()
            // testFetchNearestSettlement()
            // testFetchSearch()
            // - ошибка testFetchStationSchedule()
            // - ошибка testFetchThread()
            // - ошибка testFetchStationsList()
            // testFetchCopyright()
        }
    }
    
    // Тестовый вызов CarrierService
    func testFetchCarrier() {
        Task {
            do {
                let client = Client(
                    serverURL: try Servers.Server1.url(),
                    transport: URLSessionTransport()
                )
                let service = CarrierService(
                    client: client,
                    apikey: Constants.apiKey
                )
                _ = try await service.getCarrier(code: "TK", system: "iata")

                print("✅ CarrierService success")
            } catch {
                print("❌ CarrierService error: \(error)")
            }
        }
    }
    
    // Тестовый вызов NearestStationsService
    func testFetchNearestStations() {
        Task {
            do {
                let client = Client(
                    serverURL: try Servers.Server1.url(),
                    transport: URLSessionTransport()
                )
                let service = NearestStationsService(
                    client: client,
                    apikey: Constants.apiKey
                )
                _ = try await service.getNearestStations(
                    lat: 55.75222, // Москва
                    lng: 37.61556,
                    distance: 10
                )
                print("✅ NearestStationsService success")
            } catch {
                print("❌ NearestStationsService error: \(error)")
            }
        }
    }
    
    // Тестовый вызов NearestSettlementService
    func testFetchNearestSettlement() {
        Task {
            do {
                let client = Client(
                    serverURL: try Servers.Server1.url(),
                    transport: URLSessionTransport()
                )
                let service = NearestSettlementService(
                    client: client,
                    apikey: Constants.apiKey
                )
                _ = try await service.getNearestSettlement(
                    lat: 55.75222,
                    lng: 37.61556,
                    distance: 10
                )
                print("✅ NearestSettlementService success")
            } catch {
                print("❌ NearestSettlementService error: \(error)")
            }
        }
    }
    
    // Тестовый вызов SearchService (между станциями)
    func testFetchSearch() {
        Task {
            do {
                let client = Client(
                    serverURL: try Servers.Server1.url(),
                    transport: URLSessionTransport()
                )
                let service = SearchService(
                    client: client,
                    apikey: Constants.apiKey
                )
                _ = try await service.getScheduleBetweenStations(
                    from: "c213", // Москва
                    to: "c2",    // Санкт-Петербург
                    date: nil,
                    transportTypes: nil,
                    offset: nil,
                    limit: nil,
                    resultTimezone: nil,
                    transfers: nil
                )
                print("✅ SearchService success")
            } catch {
                print("❌ SearchService error: \(error)")
            }
        }
    }
    
    // Тестовый вызов StationScheduleService (расписание по станции)
    func testFetchStationSchedule() {
        Task {
            do {
                let client = Client(
                    serverURL: try Servers.Server1.url(),
                    transport: URLSessionTransport()
                )
                let service = StationScheduleService(
                    client: client,
                    apikey: Constants.apiKey
                )
                _ = try await service.getScheduleOnStation(
                    station: "s9600774", // Москва Ленинградский вокзал
                    date: nil,
                    transportTypes: nil,
                    event: nil,
                    direction: nil,
                    system: nil,
                    resultTimezone: nil
                )
                print("✅ StationScheduleService success")
            } catch {
                print("❌ StationScheduleService error: \(error)")
            }
        }
    }
    
    // Тестовый вызов ThreadService (по UID нитки)
    func testFetchThread() {
        Task {
            do {
                let client = Client(
                    serverURL: try Servers.Server1.url(),
                    transport: URLSessionTransport()
                )
                let service = ThreadService(
                    client: client,
                    apikey: Constants.apiKey
                )
                // ⚠️ Нужно подставить реальный uid нитки
                _ = try await service.getThread(
                    uid: "REAL_THREAD_UID",
                    from: nil,
                    to: nil,
                    date: nil,
                    showSystems: nil
                )
                print("✅ ThreadService success")
            } catch {
                print("❌ ThreadService error: \(error)")
            }
        }
    }
    
    // Тестовый вызов StationsListService
    func testFetchStationsList() {
        Task {
            do {
                let client = Client(
                    serverURL: try Servers.Server1.url(),
                    transport: URLSessionTransport()
                )
                let service = StationsListService(
                    client: client,
                    apikey: Constants.apiKey
                )
                _ = try await service.getStationsList()
                print("✅ StationsListService success")
            } catch {
                print("❌ StationsListService error: \(error)")
            }
        }
    }
    
    // Тестовый вызов CopyrightService
    func testFetchCopyright() {
        Task {
            do {
                let client = Client(
                    serverURL: try Servers.Server1.url(),
                    transport: URLSessionTransport()
                )
                let service = CopyrightService(
                    client: client,
                    apikey: Constants.apiKey
                )
                _ = try await service.getCopyrights()
                print("✅ CopyrightService success")
            } catch {
                print("❌ CopyrightService error: \(error)")
            }
        }
    }
    
}

#Preview {
    ContentView()
}
