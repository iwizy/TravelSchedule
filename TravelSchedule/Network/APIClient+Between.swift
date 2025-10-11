//
//  APIClient+Between.swift
//  TravelSchedule
//

import Foundation

extension APIClient {
    struct BetweenSegment: Hashable, Codable {
        let carrierName: String
        let carrierLogoURL: URL?
        let carrierCode: String?
        let departureISO: String
        let arrivalISO: String
        let hasTransfer: Bool
        let carrierEmail: String?
        let carrierPhone: String?
        let carrierPhoneE164: String?
    }
    
    private struct SearchResponse: Decodable {
        let segments: [SearchSegment]?
        let search: SearchMeta?
        
        struct SearchMeta: Decodable {
            let date: String?
            let has_transfers: Bool?
        }
    }
    
    private struct SearchSegment: Decodable {
        let departure: String?
        let arrival: String?
        let thread: ThreadInfo?
        let has_transfers: Bool?
    }
    
    private struct ThreadInfo: Decodable {
        let carrier: CarrierLite?
    }
    
    private struct CarrierLite: Decodable {
        let title: String?
        let logo: String?
        let codes: CarrierCodes?
        let phone: String?
        let email: String?
    }
    
    private struct CarrierCodes: Decodable {
        let yandex: String?
    }
    
    func getSegmentsBetween(
        from: String,
        to: String,
        date: Date,
        transport: String?
    ) async throws -> [BetweenSegment] {
        
        try await logRequest("between (search)", params: [
            "from": from, "to": to,
            "date": Self.dateYMD.string(from: date),
            "transport": transport ?? "any"
        ]) {
            let fromCode = try await ensureRaspCode(from)
            let toCode   = try await ensureRaspCode(to)
            
            var comps = URLComponents(url: self.serverURL, resolvingAgainstBaseURL: false)!
            comps.path = "/v3.0/search/"
            var items: [URLQueryItem] = [
                URLQueryItem(name: "apikey", value: apikey),
                URLQueryItem(name: "from", value: fromCode),
                URLQueryItem(name: "to", value: toCode),
                URLQueryItem(name: "date", value: Self.dateYMD.string(from: date)),
                URLQueryItem(name: "format", value: "json"),
                URLQueryItem(name: "lang", value: "ru_RU"),
                URLQueryItem(name: "transfers", value: "true")
            ]
            if let t = transport, !t.isEmpty {
                items.append(URLQueryItem(name: "transport_types", value: t))
            }
            comps.queryItems = items
            
            if let urlStr = comps.url?.absoluteString {
                print("🔎 [HTTP] search → \(urlStr)")
            }
            
            guard let url = comps.url else { throw URLError(.badURL) }
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                if let http = response as? HTTPURLResponse {
                    let body = String(data: data, encoding: .utf8) ?? ""
                    print("⚠️ [API] search HTTP \(http.statusCode). Body:\n\(body)")
                }
                throw URLError(.badServerResponse)
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decoded = try decoder.decode(SearchResponse.self, from: data)
            
            let segments = (decoded.segments ?? []).compactMap { seg -> BetweenSegment? in
                guard let dep = seg.departure, let arr = seg.arrival else { return nil }
                
                let carrierTitle = seg.thread?.carrier?.title ?? "—"
                let logoStr = seg.thread?.carrier?.logo
                let logoURL = logoStr.flatMap { raw -> URL? in
                    if raw.hasPrefix("//") { return URL(string: "https:\(raw)") }
                    return URL(string: raw)
                }
                let code = seg.thread?.carrier?.codes?.yandex
                let hasTr = seg.has_transfers ?? false
                
                let email = seg.thread?.carrier?.email
                let phone = seg.thread?.carrier?.phone
                
                return BetweenSegment(
                    carrierName: carrierTitle,
                    carrierLogoURL: logoURL,
                    carrierCode: code,
                    departureISO: dep,
                    arrivalISO: arr,
                    hasTransfer: hasTr,
                    carrierEmail: email,
                    carrierPhone: phone,
                    carrierPhoneE164: nil
                )
            }
            return segments
        }
    }
    
    private func ensureRaspCode(_ raw: String) async throws -> String {
        if isRaspCode(raw) { return raw }
        
        let catalog = try await getStationsListCached()
        
        for country in (catalog.countries ?? []) {
            for region in (country.regions ?? []) {
                for settlement in (region.settlements ?? []) {
                    if let stations = settlement.stations {
                        if let match = stations.first(where: { st in
                            if let sc = st.code, sc == raw { return true }
                            if let title = st.title, title == raw { return true }
                            return false
                        }) {
                            if let sc = match.code {
                                print("ℹ️ [API] ensureRaspCode: resolved station '\(raw)' -> \(sc)")
                                return sc
                            }
                        }
                    }
                }
            }
        }
        
        for country in (catalog.countries ?? []) {
            let countryTitle = country.title ?? ""
            for region in (country.regions ?? []) {
                let regionTitle = region.title ?? ""
                for settlement in (region.settlements ?? []) {
                    let displayTitle = (settlement.title ?? settlement.stations?.first?.title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    let candidateID = makeCityID(
                        countryTitle: countryTitle,
                        regionTitle: regionTitle,
                        settlement: settlement
                    )
                    
                    if raw == candidateID || (!displayTitle.isEmpty && raw == displayTitle) {
                        if let cityCode = settlement.codes?.yandex_code {
                            print("ℹ️ [API] ensureRaspCode: resolved city '\(raw)' -> \(cityCode)")
                            return cityCode
                        }
                        if let sc = settlement.stations?.first?.code {
                            print("ℹ️ [API] ensureRaspCode: resolved city '\(raw)' via first station -> \(sc)")
                            return sc
                        }
                    }
                }
            }
        }
        
        print("⚠️ [API] ensureRaspCode: cannot resolve '\(raw)' to Rasp code (expected sNNN…/cNNN…)")
        throw URLError(.badURL)
    }
    
    private func isRaspCode(_ s: String) -> Bool {
        guard let first = s.first else { return false }
        if first == "s" || first == "c" || first == "r" {
            return s.dropFirst().allSatisfy { $0.isNumber }
        }
        return false
    }
    
    private static let dateYMD: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "ru_RU")
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
