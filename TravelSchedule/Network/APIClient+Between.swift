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
            let hasTransfers: Bool?
        }
    }
    
    private struct SearchSegment: Decodable {
        let departure: String?
        let arrival: String?
        let thread: ThreadInfo?
        let details: [DetailItem]?
        let hasTransfers: Bool?
    }
    
    private struct DetailItem: Decodable {
        let isTransfer: Bool?
        let thread: ThreadInfo?
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
            "date": DateFormatterManager.dateYMD.string(from: date),
            "transport": transport ?? "any"
        ]) {
            
            guard var comps = URLComponents(string: Constants.apiURL) else {
                throw URLError(.badURL)
            }
            
            var path = comps.path
            if !path.hasSuffix("/") { path.append("/") }
            path.append("search/")
            comps.path = path
            
            
            var items: [URLQueryItem] = [
                URLQueryItem(name: "apikey", value: apikey),
                URLQueryItem(name: "from", value: from),
                URLQueryItem(name: "to", value: to),
                URLQueryItem(name: "date", value: DateFormatterManager.dateYMD.string(from: date)),
                URLQueryItem(name: "format", value: "json"),
                URLQueryItem(name: "lang", value: "ru_RU"),
                URLQueryItem(name: "transfers", value: "true")
            ]
            if let t = transport, !t.isEmpty {
                items.append(URLQueryItem(name: "transport_types", value: t))
            }
            comps.queryItems = items
            
#if DEBUG
            if let fullURL = comps.url?.absoluteString {
                print("🔎 [HTTP] search → \(fullURL)")
            }
#endif
            
            guard let url = comps.url else { throw URLError(.badURL) }
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                throw URLError(.badServerResponse)
            }
            
#if DEBUG
            if let obj = try? JSONSerialization.jsonObject(with: data),
               let pretty = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted),
               let str = String(data: pretty, encoding: .utf8) {
                print("📦 [SEARCH RESPONSE JSON]:\n\(str)")
            }
#endif
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decoded = try decoder.decode(SearchResponse.self, from: data)
            
            let segments = (decoded.segments ?? []).compactMap { seg -> BetweenSegment? in
                guard let dep = seg.departure, let arr = seg.arrival else { return nil }
                
                var carrier = seg.thread?.carrier
                
                if carrier == nil, let details = seg.details {
                    carrier = details.first(where: { $0.thread?.carrier != nil })?.thread?.carrier
                }
                
                let hasTr: Bool = {
                    if let v = seg.hasTransfers { return v }
                    if let det = seg.details, det.contains(where: { $0.isTransfer == true }) { return true }
                    return false
                }()
                
                let logoURL: URL? = {
                    guard let raw = carrier?.logo, !raw.isEmpty else { return nil }
                    if raw.hasPrefix("//") { return URL(string: "https:\(raw)") }
                    return URL(string: raw)
                }()
                
                return BetweenSegment(
                    carrierName: carrier?.title ?? "—",
                    carrierLogoURL: logoURL,
                    carrierCode: carrier?.codes?.yandex,
                    departureISO: dep,
                    arrivalISO: arr,
                    hasTransfer: hasTr,
                    carrierEmail: carrier?.email,
                    carrierPhone: carrier?.phone,
                    carrierPhoneE164: nil
                )
            }
            
            return segments
        }
    }
}
