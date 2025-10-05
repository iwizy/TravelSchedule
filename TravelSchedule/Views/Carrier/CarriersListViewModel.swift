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
    @Published var hasAvailability: Bool? = nil
    
    private var cityToStationsCache: [String: [Station]] = [:]
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
                let sample = demoOptions.first ?? CarrierOption(
                    carrierName: "—", logoName: "rzd_logo",
                    dateText: "—", depart: "—", arrive: "—",
                    durationText: "—", transferNote: nil,
                    email: "", phoneE164: "", phoneDisplay: ""
                )
                self.options = segs.map { seg in
                    let dep = Self.formatTime(seg.departureISO)
                    let arr = Self.formatTime(seg.arrivalISO)
                    let dur = Self.durationText(depISO: seg.departureISO, arrISO: seg.arrivalISO)
                    let dt  = Self.formatDateDM(seg.departureISO)
                    let note = Self.transferNote(from: seg)

                    return CarrierOption(
                        carrierName: seg.carrierName,
                        logoName: sample.logoName,
                        dateText: dt,
                        depart: dep,
                        arrive: arr,
                        durationText: dur,
                        transferNote: note,
                        email: sample.email,
                        phoneE164: sample.phoneE164,
                        phoneDisplay: sample.phoneDisplay,
                        logoURL: seg.carrierLogoURL
                    )
                }
                self.hasAvailability = true
                print("✅ [CarriersVM] real check result: FOUND (\(segs.count)) → carrier names mapped")
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
        
        let stations = try await apiClient.getStationsOfCity(cityId: "", cityTitle: cityTitle)
        cityToStationsCache[key] = stations
        
        let code = pickStationCode(in: stations, stationTitle: stationTitle)
        print("ℹ️ [CarriersVM] code resolved via API for city=\(cityTitle) station=\(stationTitle) → \(String(describing: code))")
        return code
    }
    
    private func pickStationCode(in stations: [Station], stationTitle: String) -> String? {
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
