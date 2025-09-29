//
//  MarkdownMini.swift
//  TravelSchedule
//
//  Парсер markdown


import Foundation

public enum MDInline: Equatable {
    case text(String)
    case bold(String)
    case italic(String)
    case link(text: String, url: String)
}

public enum MDBlock: Equatable {
    case h1([MDInline])
    case h2([MDInline])
    case h3([MDInline])
    case paragraph([MDInline])
    case list([[MDInline]])
}

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
            case .text(let s):
                var segment = AttributedString(s)
                if let rx = emailRegex {
                    let matches = rx.matches(in: s, options: [], range: NSRange(location: 0, length: (s as NSString).length))
                    for m in matches {
                        if let rStr = Range(m.range, in: s), let rAttr = Range(rStr, in: segment) {
                            let email = String(s[rStr])
                            segment[rAttr].link = URL(string: "mailto:\(email)")
                        }
                    }
                }
                result.append(segment)
                
            case .bold(let s):
                var segment = AttributedString(s)
                segment.inlinePresentationIntent = .stronglyEmphasized
                result.append(segment)
                
            case .italic(let s):
                var segment = AttributedString(s)
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
    
    public static func normalize(_ s: String) -> String {
        var t = s.replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .replacingOccurrences(of: "\t", with: "    ")
        t = t.replacingOccurrences(of: "\u{00A0}", with: " ")
        t = t.split(separator: "\n", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .joined(separator: "\n")
        return t
    }
    
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
    
    private static func parseInlines(_ s: String) -> [MDInline] {
        if s.isEmpty { return [] }
        
        let patterns: [(type: InlineType, regex: NSRegularExpression)] = [
            (.link,   try! NSRegularExpression(pattern: #"\[([^\]]+)\]\(([^)]+)\)"#, options: [])),
            (.bold,   try! NSRegularExpression(pattern: #"\*\*([^*]+)\*\*"#, options: [])),
            (.italic, try! NSRegularExpression(pattern: #"(?<!\*)\*([^*]+)\*(?!\*)"#, options: []))
        ]
        
        var result: [MDInline] = []
        var index = s.startIndex
        
        func appendTextIfNeeded(upTo nextIdx: String.Index) {
            if index < nextIdx {
                let chunk = String(s[index..<nextIdx])
                if !chunk.isEmpty { result.append(.text(chunk)) }
            }
        }
        
        while index < s.endIndex {
            var nearest: (type: InlineType, match: NSTextCheckingResult, range: Range<String.Index>)?
            
            for (type, rx) in patterns {
                if let m = rx.firstMatch(in: s, options: [], range: NSRange(index..<s.endIndex, in: s)),
                   let r = Range(m.range, in: s) {
                    if let current = nearest {
                        if r.lowerBound < current.range.lowerBound {
                            nearest = (type, m, r)
                        }
                    } else {
                        nearest = (type, m, r)
                    }
                }
            }
            
            guard let found = nearest else {
                appendTextIfNeeded(upTo: s.endIndex)
                break
            }
            
            appendTextIfNeeded(upTo: found.range.lowerBound)
            
            switch found.type {
            case .link:
                let textRange = Range(found.match.range(at: 1), in: s)!
                let urlRange  = Range(found.match.range(at: 2), in: s)!
                let text = String(s[textRange])
                let url  = String(s[urlRange])
                result.append(.link(text: text, url: url))
                
            case .bold:
                let inner = Range(found.match.range(at: 1), in: s)!
                result.append(.bold(String(s[inner])))
                
            case .italic:
                let inner = Range(found.match.range(at: 1), in: s)!
                result.append(.italic(String(s[inner])))
            }
            
            index = found.range.upperBound
        }
        
        return mergeAdjacentTexts(result)
    }
    
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
    
    private enum InlineType { case link, bold, italic }
}

