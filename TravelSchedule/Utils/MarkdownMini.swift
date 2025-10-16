//
//  MarkdownMini.swift
//  TravelSchedule
//

import Foundation

// MARK: - Inline & Block Models

public enum MDInline: Equatable, Sendable {
    case text(String)
    case bold(String)
    case italic(String)
    case link(text: String, url: String)
}

public enum MDBlock: Equatable, Sendable {
    case h1([MDInline])
    case h2([MDInline])
    case h3([MDInline])
    case paragraph([MDInline])
    case list([[MDInline]])
}

// MARK: - Public API

public enum MarkdownMini {
    public static func parse(_ md: String) -> [MDBlock] {
        let m = normalize(md)
        return parseBlocks(m)
    }
    
    public static func attributed(from inlines: [MDInline]) -> AttributedString {
        var result = AttributedString()
        
        let emailRegex = try? NSRegularExpression(
            pattern: #"[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}"#,
            options: [.caseInsensitive]
        )
        
        for inline in inlines {
            switch inline {
            case .text(let string):
                var segment = AttributedString(string)
                if let rx = emailRegex {
                    let matches = rx.matches(in: string, options: [], range: NSRange(location: 0, length: (string as NSString).length))
                    for m in matches {
                        if let rStr = Range(m.range, in: string), let rAttr = Range(rStr, in: segment) {
                            let email = String(string[rStr])
                            segment[rAttr].link = URL(string: "mailto:\(email)")
                        }
                    }
                }
                result.append(segment)
                
            case .bold(let string):
                var segment = AttributedString(string)
                segment.inlinePresentationIntent = .stronglyEmphasized
                result.append(segment)
                
            case .italic(let string):
                var segment = AttributedString(string)
                segment.inlinePresentationIntent = .emphasized
                result.append(segment)
                
            case .link(text: let text, url: let urlString):
                var segment = AttributedString(text)
                if let url = URL(string: urlString) {
                    segment.link = url
                }
                result.append(segment)
            }
        }
        
        return result
    }
    
    // MARK: - Normalization
    
    public static func normalize(_ string: String) -> String {
        var t = string.replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .replacingOccurrences(of: "\t", with: "    ")
        t = t.replacingOccurrences(of: "\u{00A0}", with: " ")
        t = t.split(separator: "\n", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .joined(separator: "\n")
        return t
    }
    
    // MARK: - Block Parsing
    
    public static func parseBlocks(_ md: String) -> [MDBlock] {
        let rawBlocks = md
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        return rawBlocks.map { block in
            if block.hasPrefix("# ") {
                let str = block.replacingOccurrences(of: "^#\\s+", with: "", options: .regularExpression)
                return .h1(parseInlines(str))
            }
            if block.hasPrefix("## ") {
                let str = block.replacingOccurrences(of: "^##\\s+", with: "", options: .regularExpression)
                return .h2(parseInlines(str))
            }
            if block.hasPrefix("### ") {
                let str = block.replacingOccurrences(of: "^###\\s+", with: "", options: .regularExpression)
                return .h3(parseInlines(str))
            }
            
            let lines = block.components(separatedBy: .newlines)
            if lines.allSatisfy({ $0.trimmingCharacters(in: .whitespaces).hasPrefix("- ") }) {
                let items: [[MDInline]] = lines.map {
                    let text = $0.replacingOccurrences(of: "^-\\s+", with: "", options: .regularExpression)
                    return parseInlines(text)
                }
                return .list(items)
            }
            let paragraph = lines.joined(separator: " ")
            return .paragraph(parseInlines(paragraph))
        }
    }
    
    // MARK: - Inline Parsing
    
    private static func parseInlines(_ string: String) -> [MDInline] {
        if string.isEmpty { return [] }
        
        let patterns: [(type: InlineType, regex: NSRegularExpression)] = [
            (.link,   try! NSRegularExpression(pattern: #"\[([^\]]+)\]\(([^)]+)\)"#, options: [])),
            (.bold,   try! NSRegularExpression(pattern: #"\*\*([^*]+)\*\*"#, options: [])),
            (.italic, try! NSRegularExpression(pattern: #"(?<!\*)\*([^*]+)\*(?!\*)"#, options: []))
        ]
        
        var result: [MDInline] = []
        var index = string.startIndex
        
        func appendTextIfNeeded(upTo nextIdx: String.Index) {
            if index < nextIdx {
                let chunk = String(string[index..<nextIdx])
                if !chunk.isEmpty { result.append(.text(chunk)) }
            }
        }
        
        while index < string.endIndex {
            var nearest: (type: InlineType, match: NSTextCheckingResult, range: Range<String.Index>)?
            
            for (type, rx) in patterns {
                if let match = rx.firstMatch(in: string, options: [], range: NSRange(index..<string.endIndex, in: string)),
                   let range = Range(match.range, in: string) {
                    if let current = nearest {
                        if range.lowerBound < current.range.lowerBound {
                            nearest = (type, match, range)
                        }
                    } else {
                        nearest = (type, match, range)
                    }
                }
            }
            
            guard let found = nearest else {
                appendTextIfNeeded(upTo: string.endIndex)
                break
            }
            
            appendTextIfNeeded(upTo: found.range.lowerBound)
            
            switch found.type {
            case .link:
                let textRange = Range(found.match.range(at: 1), in: string)!
                let urlRange  = Range(found.match.range(at: 2), in: string)!
                let text = String(string[textRange])
                let url  = String(string[urlRange])
                result.append(.link(text: text, url: url))
                
            case .bold:
                let inner = Range(found.match.range(at: 1), in: string)!
                result.append(.bold(String(string[inner])))
                
            case .italic:
                let inner = Range(found.match.range(at: 1), in: string)!
                result.append(.italic(String(string[inner])))
            }
            
            index = found.range.upperBound
        }
        
        return mergeAdjacentTexts(result)
    }
    
    // MARK: - Utilities
    
    private static func mergeAdjacentTexts(_ inlines: [MDInline]) -> [MDInline] {
        var out: [MDInline] = []
        for item in inlines {
            if case .text(let t1) = item, case .text(let t0)? = out.last {
                out.removeLast()
                out.append(.text(t0 + t1))
            } else {
                out.append(item)
            }
        }
        return out
    }
    
    // MARK: - Types
    
    private enum InlineType { case link, bold, italic }
}
