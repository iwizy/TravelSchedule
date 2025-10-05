//
//  CarriersListViewModel.swift
//  TravelSchedule
//
//  ВМ для экрана списка перевозчиков

import Foundation

@MainActor
final class CarriersListViewModel: ObservableObject {
    @Published var options: [CarrierOption] = []
    @Published var isChecking: Bool = false
    
    private var cityToStationsCache: [String: [Station]] = [:]
    private var cityTitleToIdCache: [String: String] = [:]
    
    init() {
        self.options = demoOptions
    }
    
    func decideAvailability(using summary: RouteSummary) async {
        print("➡️ [CarriersVM] decide start summary=\(summary)")
        isChecking = true
        defer { isChecking = false }
        
        let fromCity = summary.fromCity.trimmingCharacters(in: .whitespacesAndNewlines)
        let toCity   = summary.toCity.trimmingCharacters(in: .whitespacesAndNewlines)
        let fromSt   = summary.fromStation.trimmingCharacters(in: .whitespacesAndNewlines)
        let toSt     = summary.toStation.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if fromCity.caseInsensitiveCompare(toCity) == .orderedSame ||
            fromSt.caseInsensitiveCompare(toSt) == .orderedSame {
            self.options = []
            print("✅ [CarriersVM] decide result: NOT FOUND (same city/station)")
        } else {
            self.options = demoOptions
            print("✅ [CarriersVM] decide result: FOUND → demo shown (\(demoOptions.count))")
        }
    }
    
    func checkAvailabilityReal(apiClient: APIClient, summary: RouteSummary) async {
        print("➡️ [CarriersVM] real check start summary=\(summary)")
        isChecking = true
        defer { isChecking = false }
        
        let fromCity = summary.fromCity.trimmingCharacters(in: .whitespacesAndNewlines)
        let toCity   = summary.toCity.trimmingCharacters(in: .whitespacesAndNewlines)
        let fromSt   = summary.fromStation.trimmingCharacters(in: .whitespacesAndNewlines)
        let toSt     = summary.toStation.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if fromCity.caseInsensitiveCompare(toCity) == .orderedSame ||
            fromSt.caseInsensitiveCompare(toSt) == .orderedSame {
            self.options = []
            print("✅ [CarriersVM] real check: NOT FOUND (same city/station)")
            return
        }
        
        do {
            async let fromCode = resolveStationCode(apiClient: apiClient, cityTitle: fromCity, stationTitle: fromSt)
            async let toCode   = resolveStationCode(apiClient: apiClient, cityTitle: toCity,   stationTitle: toSt)
            let (fCode, tCode) = try await (fromCode, toCode)
            
            guard let fromCode = fCode, let toCode = tCode else {
                self.options = []
                print("⚠️ [CarriersVM] codes not resolved: from=\(String(describing: fCode)) to=\(String(describing: tCode))")
                return
            }
            
            let today = Date()
            let has = try await apiClient.hasSegmentsBetween(
                from: fromCode,
                to: toCode,
                date: today,
                transport: nil
            )
            
            if has {
                self.options = demoOptions
                print("✅ [CarriersVM] real check result: FOUND → demo shown (\(demoOptions.count))")
            } else {
                self.options = []
                print("✅ [CarriersVM] real check result: NOT FOUND")
            }
            
        } catch {
            self.options = []
            print("❌ [CarriersVM] real check error: \(error)")
        }
    }
    
    private func resolveStationCode(apiClient: APIClient, cityTitle: String, stationTitle: String) async throws -> String? {
        guard let cityId = try await resolveCityId(apiClient: apiClient, cityTitle: cityTitle) else {
            print("⚠️ [CarriersVM] cityId not found for cityTitle=\(cityTitle)")
            return nil
        }
        
        let cityKey = cityTitle.lowercased()
        if let cached = cityToStationsCache[cityKey],
           let code = pickStationCode(in: cached, stationTitle: stationTitle) {
            print("ℹ️ [CarriersVM] code from cache for cityId=\(cityId) cityTitle=\(cityTitle)")
            return code
        }
        
        let stations = try await apiClient.getStationsOfCity(cityId: cityId)
        cityToStationsCache[cityKey] = stations
        
        let code = pickStationCode(in: stations, stationTitle: stationTitle)
        print("ℹ️ [CarriersVM] code resolved via API for cityId=\(cityId) cityTitle=\(cityTitle) station=\(stationTitle) → \(String(describing: code))")
        return code
    }
    
    private func resolveCityId(apiClient: APIClient, cityTitle: String) async throws -> String? {
        let key = cityTitle.lowercased()
        if let cached = cityTitleToIdCache[key] { return cached }
        
        let cities = try await apiClient.getRussianCities()
        if let found = cities.first(where: { $0.title.compare(cityTitle, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame }) {
            cityTitleToIdCache[key] = found.id
            return found.id
        }
        
        if let contains = cities.first(where: { $0.title.lowercased().contains(key) }) {
            cityTitleToIdCache[key] = contains.id
            return contains.id
        }
        
        return nil
    }
    
    private func pickStationCode(in stations: [Station], stationTitle: String) -> String? {
        let target = stationTitle.lowercased()
        if let exact = stations.first(where: {
            $0.title.compare(stationTitle, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }) {
            return exact.id
        }
        return stations.first(where: { $0.title.lowercased().contains(target) })?.id
    }
    
    private var demoOptions: [CarrierOption] = [
        CarrierOption(
            carrierName: "РЖД", logoName: "rzd_logo",
            dateText: "14 января", depart: "06:15", arrive: "12:05",
            durationText: "5 ч 50 м",
            transferNote: nil,
            email: "info@rzd.ru",
            phoneE164: "+78007750000",
            phoneDisplay: "8 800 775-00-00"
        ),
        CarrierOption(
            carrierName: "ФГК", logoName: "fgk_logo",
            dateText: "15 января", depart: "01:15", arrive: "09:00",
            durationText: "7 ч 45 м",
            transferNote: "С пересадкой в Твери",
            email: "info@railfgk.ru",
            phoneE164: "+78002504777",
            phoneDisplay: "8-800-250-4777"
        ),
        CarrierOption(
            carrierName: "Урал логистика", logoName: "ural_logo",
            dateText: "16 января", depart: "12:30", arrive: "21:00",
            durationText: "8 ч 30 м",
            transferNote: nil,
            email: "general@ulgroup.ru",
            phoneE164: "+74957838383",
            phoneDisplay: "+7 (495) 783-83-83"
        )
    ]
}
