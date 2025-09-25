//
//  MarkdownMini.swift
//  TravelSchedule
//
//  Парсер markdown

import Foundation

public enum MDBlock: Equatable {
    case h1(String)
    case h2(String)
    case paragraph(String)
    case list([String])
}

public enum MarkdownMini {
    public static func parse(_ md: String) -> [MDBlock] {
        let m = normalize(md)
        return parseBlocks(m)
    }

    public static func normalize(_ s: String) -> String {
        var t = s.replacingOccurrences(of: "\r\n", with: "\n")
                 .replacingOccurrences(of: "\r", with: "\n")
                 .replacingOccurrences(of: "\t", with: "    ")
        t = t.replacingOccurrences(of: "\u{00A0}", with: " ")
        return t
    }

    public static func parseBlocks(_ md: String) -> [MDBlock] {
        let rawBlocks = md
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return rawBlocks.map { block in
            if block.hasPrefix("# ") {
                let title = block.replacingOccurrences(of: "^#\\s+", with: "", options: .regularExpression)
                return .h1(title)
            }
            if block.hasPrefix("## ") {
                let title = block.replacingOccurrences(of: "^##\\s+", with: "", options: .regularExpression)
                return .h2(title)
            }
            let lines = block.components(separatedBy: .newlines)
            if lines.allSatisfy({ $0.trimmingCharacters(in: .whitespaces).hasPrefix("- ") }) {
                let items = lines.map {
                    $0.replacingOccurrences(of: "^-\\s+", with: "", options: .regularExpression)
                }
                return .list(items)
            }
            let paragraph = lines.joined(separator: " ")
            return .paragraph(paragraph)
        }
    }
}
