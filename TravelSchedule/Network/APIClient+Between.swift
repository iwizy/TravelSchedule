//
//  APIClient+Between.swift
//  TravelSchedule
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

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
    
    func getSegmentsBetween(
        from: String,
        to: String,
        date: Date,
        transport: String?
    ) async throws -> [BetweenSegment] {
        
        try await logRequest("between (search)", params: [
            "from": from,
            "to": to,
            "date": DateFormatterManager.dateYMD.string(from: date),
            "transport": transport ?? "any"
        ]) {
            
#if DEBUG
            if let debugURL = Self.makeDebugSearchURL(
                baseURLString: Constants.apiURL,
                apikey: apikey,
                from: from,
                to: to,
                date: DateFormatterManager.dateYMD.string(from: date),
                transportTypes: transport,
                transfers: true
            ) {
                print("🔎 [HTTP] search → \(debugURL)")
            }
#endif
            
            let output = try await client.getScheduleBetweenStations(
                query: .init(
                    from: from,
                    to: to,
                    date: DateFormatterManager.dateYMD.string(from: date),
                    transport_types: transport,
                    transfers: true,
                    lang: "ru_RU",
                    format: "json"
                )
            )
            
            switch output {
            case .ok(let ok):
                switch ok.body {
                case .json(let model):
                    let segments = Self.mapSegmentsResponse(model)
#if DEBUG
                    print("📦 [SEARCH] decoded segments=\(segments.count)")
#endif
                    return segments
                }
            default:
                throw URLError(.badServerResponse)
            }
        }
    }
    
    private static func mapSegmentsResponse(
        _ resp: Components.Schemas.SegmentsResponse
    ) -> [BetweenSegment] {
        let items = resp.segments ?? []
        return items.compactMap { seg -> BetweenSegment? in
            guard
                let dep = seg.departure,
                let arr = seg.arrival
            else {
                return nil
            }
            
            var carrier = seg.thread?.carrier
            if carrier == nil, let details = seg.details {
                carrier = details.first(where: { $0.thread?.carrier != nil })?.thread?.carrier
            }
            
            let hasTransfer: Bool = {
                if let v = seg.has_transfers { return v }
                if let tr = seg.transfers, !tr.isEmpty { return true }
                if let dets = seg.details, dets.count > 1 { return true }
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
                hasTransfer: hasTransfer,
                carrierEmail: carrier?.email,
                carrierPhone: carrier?.phone,
                carrierPhoneE164: nil
            )
        }
    }
    
    private static func makeDebugSearchURL(
        baseURLString: String,
        apikey: String,
        from: String,
        to: String,
        date: String,
        transportTypes: String?,
        transfers: Bool
    ) -> String? {
        guard var comps = URLComponents(string: baseURLString) else { return nil }
        var path = comps.path
        if !path.hasSuffix("/") { path.append("/") }
        path.append("search/")
        comps.path = path
        
        var items: [URLQueryItem] = [
            .init(name: "apikey", value: apikey),
            .init(name: "from", value: from),
            .init(name: "to", value: to),
            .init(name: "date", value: date),
            .init(name: "format", value: "json"),
            .init(name: "lang", value: "ru_RU"),
            .init(name: "transfers", value: transfers ? "true" : "false")
        ]
        if let t = transportTypes, !t.isEmpty {
            items.append(.init(name: "transport_types", value: t))
        }
        comps.queryItems = items
        return comps.url?.absoluteString
    }
}
