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
    }
    
    private struct ThreadInfo: Decodable {
        let carrier: CarrierInfo?
        let title: String?
    }
    
    private struct CarrierInfo: Decodable {
        let title: String?
    }

    public func hasSegmentsBetween(
        from fromCode: String,
        to toCode: String,
        date: Date,
        transport: String? = nil
    ) async throws -> Bool {
        try await logRequest("between_has_segments", params: [
            "from": fromCode, "to": toCode, "date": Self.yyyyMMdd(date)
        ]) {
            guard var baseComps = URLComponents(string: Constants.apiURL) else {
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
            let count = decoded.segments?.count ?? 0
            return count > 0
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
