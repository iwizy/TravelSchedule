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
        let details: [Detail]?
        let transfers: [Transfer]?
    }
    
    private struct Detail: Decodable {
        let departure: String?
        let arrival: String?
        let thread: ThreadInfo?
    }
    
    private struct Transfer: Decodable {
        let title: String?
        let short_title: String?
    }
    
    private struct ThreadInfo: Decodable {
        let carrier: CarrierLite?
        let title: String?
        let short_title: String?
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
            var comps = URLComponents(string: "https://api.rasp.yandex.net/v3.0/search/")!
            var items: [URLQueryItem] = [
                URLQueryItem(name: "apikey", value: apikey),
                URLQueryItem(name: "from", value: from),
                URLQueryItem(name: "to", value: to),
                URLQueryItem(name: "date", value: Self.dateYMD.string(from: date)),
                URLQueryItem(name: "format", value: "json"),
                URLQueryItem(name: "lang", value: "ru_RU"),
                URLQueryItem(name: "transfers", value: "true") 
            ]
            if let t = transport, !t.isEmpty {
                items.append(URLQueryItem(name: "transport_types", value: t))
            }
            comps.queryItems = items
            
            guard let url = comps.url else {
                throw URLError(.badURL)
            }
            let (data, _) = try await URLSession.shared.data(from: url)

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decoded = try decoder.decode(SearchResponse.self, from: data)
            
            let segments = (decoded.segments ?? []).compactMap { seg -> BetweenSegment? in
                guard let dep = seg.departure, let arr = seg.arrival else { return nil }
                
                let firstLegWithThread = seg.details?.first(where: { $0.thread?.carrier != nil })
                let carrier = firstLegWithThread?.thread?.carrier ?? seg.thread?.carrier
                
                let carrierTitle = carrier?.title ?? "—"
                let logoStr = carrier?.logo
                let logoURL = logoStr.flatMap { raw -> URL? in
                    if raw.hasPrefix("//") { return URL(string: "https:\(raw)") }
                    return URL(string: raw)
                }
                let code = carrier?.codes?.yandex
                let email = carrier?.email
                let phone = carrier?.phone
                
                let hasTransfersFlag = seg.has_transfers ?? false
                let hasTransfersByLists = !(seg.transfers?.isEmpty ?? true) || ((seg.details?.count ?? 1) > 1)
                let hasTr = hasTransfersFlag || hasTransfersByLists
                
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
    
    private static let dateYMD: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "ru_RU")
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
