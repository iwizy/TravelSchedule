//
//  CarriersListViewModel.swift
//  TravelSchedule
//

import Foundation

@MainActor
final class CarriersListViewModel: ObservableObject {
    @Published var options: [CarrierOption] = []
    @Published var isChecking: Bool = false
    @Published var hasAvailability: Bool? = nil
    
    private var cityToStationsCache: [String: [APIClient.StationLite]] = [:]
    private var segments: [APIClient.BetweenSegment] = []
    
    init() {
        self.options = []
    }
    
    func checkAvailabilityReal(apiClient: APIClient, summary: RouteSummary) async {
        print("➡️ [CarriersVM] real check start summary=\(summary)")
        isChecking = true
        hasAvailability = nil
        defer { isChecking = false }
        
        let fromCity = summary.fromCity.trimmingCharacters(in: .whitespacesAndNewlines)
        let toCity   = summary.toCity.trimmingCharacters(in: .whitespacesAndNewlines)
        let fromSt   = summary.fromStation.trimmingCharacters(in: .whitespacesAndNewlines)
        let toSt     = summary.toStation.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if fromCity.caseInsensitiveCompare(toCity) == .orderedSame ||
            fromSt.caseInsensitiveCompare(toSt) == .orderedSame {
            self.segments = []
            self.options = []
            self.hasAvailability = false
            print("✅ [CarriersVM] real check: NOT FOUND (same city/station)")
            return
        }
        
        do {
            async let fromCode = resolveStationCode(apiClient: apiClient, cityTitle: fromCity, stationTitle: fromSt)
            async let toCode   = resolveStationCode(apiClient: apiClient, cityTitle: toCity,   stationTitle: toSt)
            let (fCode, tCode) = try await (fromCode, toCode)
            
            guard let fromCode = fCode, let toCode = tCode else {
                self.segments = []
                self.options = []
                self.hasAvailability = false
                print("⚠️ [CarriersVM] codes not resolved: from=\(String(describing: fCode)) to=\(String(describing: tCode))")
                return
            }
            let today = Date()
            let segs = try await apiClient.getSegmentsBetween(
                from: fromCode,
                to: toCode,
                date: today,
                transport: nil
            )
            self.segments = segs
            
            if segs.isEmpty {
                self.options = []
                self.hasAvailability = false
                print("✅ [CarriersVM] real check result: NOT FOUND")
            } else {
                let fallbackLogoAsset = "rzd_logo"
                let mapped: [CarrierOption] = segs.map { seg in
                    let dep = Self.formatTime(seg.departureISO)
                    let arr = Self.formatTime(seg.arrivalISO)
                    let dur = Self.durationText(depISO: seg.departureISO, arrISO: seg.arrivalISO)
                    let dt  = Self.formatDateDM(seg.departureISO)
                    let note = Self.transferNote(from: seg)
                    
                    return CarrierOption(
                        carrierName: seg.carrierName,
                        logoName: fallbackLogoAsset,
                        dateText: dt,
                        depart: dep,
                        arrive: arr,
                        durationText: dur,
                        transferNote: note,
                        email: seg.carrierEmail,
                        phoneE164: seg.carrierPhoneE164,
                        phoneDisplay: seg.carrierPhone,
                        logoURL: seg.carrierLogoURL
                    )
                }
                self.options = mapped
                self.hasAvailability = true
                print("✅ [CarriersVM] base mapping done (\(segs.count)) → names/dates/times/duration/transfer/logoURL")
                
                for (idx, seg) in segs.enumerated() {
                    if let url = seg.carrierLogoURL {
                        options[idx].logoURL = url
                    }
                    options[idx].phoneE164 = seg.carrierPhoneE164 ?? seg.carrierPhone
                    options[idx].phoneDisplay = seg.carrierPhone
                    options[idx].email = seg.carrierEmail
                }
                
                print("✅ [CarriersVM] carrier contacts merged directly from segments → options updated")
            }
            
        } catch {
            self.segments = []
            self.options = []
            self.hasAvailability = false
            print("❌ [CarriersVM] real check error: \(error)")
        }
    }
    
    
    private func resolveStationCode(apiClient: APIClient, cityTitle: String, stationTitle: String) async throws -> String? {
        let key = cityTitle.lowercased()
        
        if let cached = cityToStationsCache[key],
           let code = pickStationCode(in: cached, stationTitle: stationTitle) {
            print("ℹ️ [CarriersVM] code from cache for city=\(cityTitle)")
            return code
        }
        
        let stations = try await apiClient.getStationsOfCity(cityTitle: cityTitle, cityId: "")
        cityToStationsCache[key] = stations
        
        let code = pickStationCode(in: stations, stationTitle: stationTitle)
        print("ℹ️ [CarriersVM] code resolved via API for city=\(cityTitle) station=\(stationTitle) → \(String(describing: code))")
        return code
    }
    
    private func pickStationCode(in stations: [APIClient.StationLite], stationTitle: String) -> String? {
        if let exact = stations.first(where: {
            $0.title.compare(stationTitle, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }) { return exact.id }
        
        let target = stationTitle.lowercased()
        return stations.first(where: { $0.title.lowercased().contains(target) })?.id
    }
    
    private static let isoParser: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()
    
    private static let hhmm: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "ru_RU")
        f.timeZone = .current
        f.dateFormat = "HH:mm"
        return f
    }()
    
    private static func formatTime(_ iso: String) -> String {
        if let d = isoParser.date(from: iso) {
            return hhmm.string(from: d)
        }
        let fallback = ISO8601DateFormatter()
        fallback.formatOptions = [.withInternetDateTime]
        fallback.timeZone = TimeZone(secondsFromGMT: 0)
        if let d = fallback.date(from: iso) {
            return hhmm.string(from: d)
        }
        return "—"
    }
    
    private static func durationText(depISO: String, arrISO: String) -> String {
        func parse(_ iso: String) -> Date? {
            if let d = isoParser.date(from: iso) { return d }
            let fallback = ISO8601DateFormatter()
            fallback.formatOptions = [.withInternetDateTime]
            fallback.timeZone = TimeZone(secondsFromGMT: 0)
            return fallback.date(from: iso)
        }
        
        guard let dep = parse(depISO), let arr = parse(arrISO) else { return "—" }
        let seconds = max(0, Int(arr.timeIntervalSince(dep)))
        let minutes = seconds / 60
        let h = minutes / 60
        let m = minutes % 60
        
        switch (h, m) {
        case (0, let m): return "\(m) м"
        case (let h, 0): return "\(h) ч"
        default:         return "\(h) ч \(m) м"
        }
    }
    
    private static let dayMonth: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "ru_RU")
        f.timeZone = .current
        f.setLocalizedDateFormatFromTemplate("d MMMM")
        return f
    }()
    
    private static func parseISO(_ iso: String) -> Date? {
        if let d = isoParser.date(from: iso) { return d }
        let fallback = ISO8601DateFormatter()
        fallback.formatOptions = [.withInternetDateTime]
        fallback.timeZone = TimeZone(secondsFromGMT: 0)
        return fallback.date(from: iso)
    }
    
    private static func formatDateDM(_ iso: String) -> String {
        guard let d = parseISO(iso) else { return "—" }
        return dayMonth.string(from: d)
    }
    
    private static func transferNote(from seg: APIClient.BetweenSegment) -> String? {
        seg.hasTransfer ? "С пересадкой" : nil
    }
    
}

private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return self.filter { set.insert($0).inserted }
    }
}
