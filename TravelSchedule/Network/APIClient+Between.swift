//
//  APIClient+Between.swift
//  TravelSchedule
//
//  Поиск маршрутов между станциями

import Foundation

extension APIClient {
    private struct SearchResponse: Decodable {
        let segments: [Segment]?
    }
    
    private struct Segment: Decodable {
        let departure: String?
        let arrival: String?
        let thread: ThreadInfo?
        let transfer: Bool?
    }
    
    private struct ThreadInfo: Decodable {
        let carrier: CarrierInfo?
        let title: String?
    }
    
    private struct CarrierInfo: Decodable {
        let title: String?
    }
    
    public struct BetweenSegment: Sendable, Equatable {
        public let carrierName: String
        public let departureISO: String
        public let arrivalISO: String
        public let hasTransfer: Bool
    }
    
    public func getSegmentsBetween(
        from fromCode: String,
        to toCode: String,
        date: Date,
        transport: String? = nil
    ) async throws -> [BetweenSegment] {
        try await logRequest("between_get_segments", params: [
            "from": fromCode, "to": toCode, "date": Self.yyyyMMdd(date)
        ]) {
            guard let baseComps = URLComponents(string: Constants.apiURL) else {
                throw URLError(.badURL)
            }
            let baseURL = baseComps.url!.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            guard var comps = URLComponents(string: baseURL + "/search/") else {
                throw URLError(.badURL)
            }
            
            var query: [URLQueryItem] = [
                URLQueryItem(name: "from", value: fromCode),
                URLQueryItem(name: "to", value: toCode),
                URLQueryItem(name: "date", value: Self.yyyyMMdd(date)),
                URLQueryItem(name: "apikey", value: self.apikey)
            ]
            if let t = transport, !t.isEmpty {
                query.append(URLQueryItem(name: "transport_types", value: t))
            }
            comps.queryItems = query
            
            guard let url = comps.url else { throw URLError(.badURL) }
            
            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            req.timeoutInterval = 30
            
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                throw URLError(.badServerResponse)
            }
            
            let decoded = try JSONDecoder().decode(SearchResponse.self, from: data)
            let raw = decoded.segments ?? []
            
            let mapped: [BetweenSegment] = raw.compactMap { seg in
                guard
                    let dep = seg.departure, !dep.isEmpty,
                    let arr = seg.arrival,   !arr.isEmpty
                else { return nil }
                
                let name = seg.thread?.carrier?.title?.trimmingCharacters(in: .whitespacesAndNewlines)
                let carrier = (name?.isEmpty == false) ? name! : "—"
                let hasTransfer = seg.transfer ?? false
                
                return BetweenSegment(
                    carrierName: carrier,
                    departureISO: dep,
                    arrivalISO: arr,
                    hasTransfer: hasTransfer
                )
            }
            
            return mapped
        }
    }
    
    private static func yyyyMMdd(_ date: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}
