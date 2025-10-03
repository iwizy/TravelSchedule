//
//  DebugViewTool.swift
//  TravelSchedule
//
//  Created by Alexander Agafonov on 14.09.2025.
//
//  - debugBorder(...)   — рамка для наглядности
//  - debugBackground(...) — полупрозрачный фон
//  - debugSize(label:)  — печать размера/координат в консоль
//  - debugOverlay(label:) — выводит размер поверх вью (лейблом)


import SwiftUI

#if DEBUG

public extension View {
    func debugBorder(_ color: Color = .red, width: CGFloat = 1) -> some View {
        overlay(Rectangle().stroke(color, lineWidth: width))
    }
    
    func debugBackground(_ color: Color = .yellow.opacity(0.2)) -> some View {
        background(color)
    }
}


private struct DebugSizeModifier: ViewModifier {
    let label: String
    
    func body(content: Content) -> some View {
        content.background(
            GeometryReader { proxy in
                if #available(iOS 17.0, *) {
                    Color.clear
                        .onAppear {
                            log(proxy: proxy, reason: "appear")
                        }
                        .onChange(of: proxy.size) {
                            log(proxy: proxy, reason: "size change")
                        }
                } else {
                    Color.clear
                        .onAppear {
                            log(proxy: proxy, reason: "appear")
                        }
                        .onChange(of: proxy.size) { _ in
                            log(proxy: proxy, reason: "size change")
                        }
                }
            }
        )
    }
    
    private func log(proxy: GeometryProxy, reason: String) {
        let size = proxy.size
        let global = proxy.frame(in: .global)
        let local  = proxy.frame(in: .local)
        print("[DEBUG][\(label)] \(reason) — size: \(Int(size.width))×\(Int(size.height)); " +
              "global: x:\(Int(global.minX)) y:\(Int(global.minY)); " +
              "local: x:\(Int(local.minX)) y:\(Int(local.minY))")
    }
}

public extension View {
    func debugSize(_ label: String = "") -> some View {
        modifier(DebugSizeModifier(label: label))
    }
}

// MARK: - Текстовый оверлей с размерами поверх вью

private struct DebugOverlayModifier: ViewModifier {
    let label: String
    
    func body(content: Content) -> some View {
        content.overlay(
            GeometryReader { proxy in
                let size = proxy.size
                ZStack {
                    Text(overlayText(size: size))
                        .font(.caption2.monospaced())
                        .padding(4)
                        .background(.black.opacity(0.6))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .padding(4)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            }
        )
    }
    
    private func overlayText(size: CGSize) -> String {
        var parts: [String] = []
        if !label.isEmpty { parts.append(label) }
        parts.append("\(Int(size.width))×\(Int(size.height))")
        return parts.joined(separator: " • ")
    }
}

public extension View {
    func debugOverlay(_ label: String = "") -> some View {
        modifier(DebugOverlayModifier(label: label))
    }
}

#endif

