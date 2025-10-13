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
            do {
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
                        let segs = model.segments ?? []
                        let intervals = model.interval_segments ?? []
                        if segs.isEmpty && intervals.isEmpty {
                            return []
                        }
                        return Self.mapSegmentsResponse(model)
                    default:
                        throw ServerHTTPError(statusCode: 200)
                    }
                    
                default:
                    throw ServerHTTPError(statusCode: 0)
                }
                
            } catch {
                let fallbackSegments = try await Self.fetchBetweenFallback(
                    session: self.session,
                    apikey: self.apikey,
                    baseURLString: Constants.apiURL,
                    from: from,
                    to: to,
                    date: DateFormatterManager.dateYMD.string(from: date),
                    transportTypes: transport
                )
                return fallbackSegments
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
            else { return nil }
            
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
    
    private static func fetchBetweenFallback(
        session: URLSession,
        apikey: String,
        baseURLString: String,
        from: String,
        to: String,
        date: String,
        transportTypes: String?
    ) async throws -> [BetweenSegment] {
        guard var comps = URLComponents(string: baseURLString) else {
            throw URLError(.badURL)
        }
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
            .init(name: "transfers", value: "true")
        ]
        if let t = transportTypes, !t.isEmpty {
            items.append(.init(name: "transport_types", value: t))
        }
        comps.queryItems = items
        
        guard let url = comps.url else { throw URLError(.badURL) }
        
        let (data, response) = try await session.data(from: url)
        try await Task { @MainActor in
            try await APIClient(apikey: apikey, serverURL: URL(string: baseURLString)!).ensureHTTP200(response)
        }.value
        
        let decoder = JSONDecoder()
        let model = try decoder.decode(Components.Schemas.SegmentsResponse.self, from: data)
        
        let segs = model.segments ?? []
        let intervals = model.interval_segments ?? []
        if segs.isEmpty && intervals.isEmpty {
            return []
        }
        
        return mapSegmentsResponse(model)
    }
}
