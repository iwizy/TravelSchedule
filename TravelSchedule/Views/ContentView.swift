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
            testFetchCarrier()
            testFetchNearestStations()
            testFetchNearestSettlement()
            testFetchSearch()
            testFetchStationSchedule()
            testFetchThread(uid: "018J_5_2")
            testFetchStationsList()
            testFetchCopyright()
        }
    }

    // Carrier
    func testFetchCarrier() {
        Task {
            do {
                let client = Client(
                    serverURL: URL(string: "https://api.rasp.yandex.net/v3.0")!,
                    transport: URLSessionTransport()
                )
                let service = CarrierService(client: client, apikey: Constants.apiKey)
                let resp = try await service.getCarrier(code: "TK", system: "iata")

                if let first = resp.carriers?.first {
                    let title = first.title ?? "-"
                    let code = first.code.map(String.init) ?? "-"
                    print("✅ CarrierService Success — first: title=\(title), code=\(code)")
                } else {
                    let data = try JSONEncoder().encode(resp)
                    let json = String(data: data, encoding: .utf8) ?? "<invalid utf8>"
                    print("✅ CarrierService Success — carriers empty. Raw JSON: \(json)")
                }
            } catch {
                print("❌ CarrierService Error: \(error)")
            }
        }
    }

    // Nearest Stations
    func testFetchNearestStations() {
        Task {
            do {
                let client = Client(
                    serverURL: URL(string: "https://api.rasp.yandex.net/v3.0")!,
                    transport: URLSessionTransport()
                )
                let service = NearestStationsService(client: client, apikey: Constants.apiKey)

                let resp = try await service.getNearestStations(lat: 55.75222, lng: 37.61556, distance: 10)
                if let first = resp.stations?.first {
                    let title = first.title ?? "-"
                    let code = first.code ?? "-"
                    let ttype = first.transport_type ?? "-"
                    print("✅ NearestStations Success — first: title=\(title), code=\(code), transport_type=\(ttype)")
                } else {
                    print("✅ NearestStations Success — stations empty")
                }
            } catch {
                print("❌ NearestStations Error: \(error)")
            }
        }
    }

    // Nearest Settlement
    func testFetchNearestSettlement() {
        Task {
            do {
                let client = Client(
                    serverURL: URL(string: "https://api.rasp.yandex.net/v3.0")!,
                    transport: URLSessionTransport()
                )
                let service = NearestSettlementService(client: client, apikey: Constants.apiKey)

                let resp = try await service.getNearestSettlement(lat: 55.75222, lng: 37.61556, distance: 10)

                let data = try JSONEncoder().encode(resp)
                let json = String(data: data, encoding: .utf8) ?? "<invalid utf8>"
                print("✅ NearestSettlement Success — \(json)")
            } catch {
                print("❌ NearestSettlement Error: \(error)")
            }
        }
    }

    // Search
    func testFetchSearch() {
        Task {
            do {
                let client = Client(
                    serverURL: URL(string: "https://api.rasp.yandex.net/v3.0")!,
                    transport: URLSessionTransport()
                )
                let service = SearchService(client: client, apikey: Constants.apiKey)

                let resp = try await service.getScheduleBetweenStations(
                    from: "c213", to: "c2",
                    date: nil, transportTypes: nil, offset: nil, limit: 5,
                    resultTimezone: nil, transfers: nil
                )

                if let first = resp.segments?.first {
                    let dep = first.departure ?? "-"
                    let arr = first.arrival ?? "-"
                    let fromTitle = first.from?.title ?? "-"
                    let toTitle = first.to?.title ?? "-"
                    let num = first.thread?.number ?? "-"
                    let ttype = first.thread?.transport_type ?? "-"
                    let uid = first.thread?.uid ?? "-"
                    print("✅ Search Success — first segment: \(fromTitle) ⟶ \(toTitle), dep=\(dep), arr=\(arr), number=\(num), type=\(ttype), uid=\(uid)")
                } else {
                    print("✅ Search Success — segments empty")
                }
            } catch {
                print("❌ Search Error: \(error)")
            }
        }
    }

    // Station Schedule
    func testFetchStationSchedule() {
        Task {
            do {
                let client = Client(
                    serverURL: URL(string: "https://api.rasp.yandex.net/v3.0")!,
                    transport: URLSessionTransport()
                )
                let service = StationScheduleService(client: client, apikey: Constants.apiKey)

                let resp = try await service.getScheduleOnStation(
                    station: "s9600774",
                    date: nil, transportTypes: nil, event: nil, direction: nil, system: nil, resultTimezone: nil
                )

                if let first = resp.schedule?.first {
                    let dep = first.departure ?? "-"
                    let arr = first.arrival ?? "-"
                    let num = first.thread?.number ?? "-"
                    let title = first.thread?.title ?? "-"
                    print("✅ StationSchedule Success — first schedule: \(title) #\(num), dep=\(dep), arr=\(arr)")
                } else if let intFirst = resp.interval_schedule?.first {
                    let dens = intFirst.interval?.density ?? "-"
                    let b = intFirst.interval?.begin_time ?? "-"
                    let e = intFirst.interval?.end_time ?? "-"
                    let title = intFirst.thread?.title ?? "-"
                    print("✅ StationSchedule Success — first interval: \(title), density=\(dens), \(b)–\(e)")
                } else {
                    print("✅ StationSchedule Success — schedule empty")
                }
            } catch {
                print("❌ StationSchedule Error: \(error)")
            }
        }
    }

    // Thread
    func testFetchThread(uid: String, date: String? = nil) {
        Task {
            do {
                let client = Client(
                    serverURL: URL(string: "https://api.rasp.yandex.net/v3.0")!,
                    transport: URLSessionTransport()
                )
                let service = ThreadService(client: client, apikey: Constants.apiKey)

                let resp = try await service.getThread(uid: uid, from: nil, to: nil, date: date, showSystems: nil)

                if let first = resp.stops?.first {
                    let stTitle = first.station?.title ?? "-"
                    let dep = first.departure ?? "-"
                    let arr = first.arrival ?? "-"
                    print("✅ Thread Success — first stop: \(stTitle), dep=\(dep), arr=\(arr)")
                } else {
                    print("✅ Thread Success — stops empty")
                }
            } catch {
                print("❌ Thread Error: \(error)")
            }
        }
    }

    // Stations List
    func testFetchStationsList() {
        Task {
            do {
                let client = Client(
                    serverURL: URL(string: "https://api.rasp.yandex.net/v3.0")!,
                    transport: URLSessionTransport()
                )
                let service = StationsListService(client: client, apikey: Constants.apiKey)

                let resp = try await service.getStationsList()
                if let country = resp.countries?.first {
                    let title = country.title ?? "-"
                    let regionsCount = country.regions?.count ?? 0
                    print("✅ StationsList Success — first country: \(title), regions=\(regionsCount)")
                } else {
                    print("✅ StationsList Success — countries empty")
                }
            } catch {
                print("❌ StationsList Error: \(error)")
            }
        }
    }

    // Copyright
    func testFetchCopyright() {
        Task {
            do {
                let client = Client(
                    serverURL: URL(string: "https://api.rasp.yandex.net/v3.0")!,
                    transport: URLSessionTransport()
                )
                let service = CopyrightService(client: client, apikey: Constants.apiKey)

                _ = try await service.getCopyrights()
                print("✅ Copyright Success")
            } catch {
                print("❌ Copyright Error: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
