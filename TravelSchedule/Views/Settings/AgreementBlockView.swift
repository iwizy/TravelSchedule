//
//  AgreementBlockView.swift
//  TravelSchedule
//
//  Created by Alexander Agafonov on 26.09.2025.
//

import SwiftUI

public struct AgreementBlockView: View {
    public let block: MDBlock

    public init(block: MDBlock) { self.block = block }

    private func inlineText(_ inlines: [MDInline]) -> Text {
        inlines.reduce(Text("")) { acc, inline in
            switch inline {
            case .text(let s):
                return acc + Text(s)
            case .bold(let s):
                return acc + Text(s).bold()
            case .italic(let s):
                return acc + Text(s).italic()
            case .link(let text, _):
                return acc + Text(text).foregroundStyle(.blue).underline()
            }
        }
    }

    public var body: some View {
        switch block {
        case .h1(let inlines):
            inlineText(inlines)
                .font(.title.bold())
                .multilineTextAlignment(.leading)

        case .h2(let inlines):
            inlineText(inlines)
                .font(.title3.bold())
                .multilineTextAlignment(.leading)

        case .h3(let inlines):
            inlineText(inlines)
                .font(.headline.bold())
                .multilineTextAlignment(.leading)

        case .paragraph(let inlines):
            inlineText(inlines)
                .font(.body)
                .lineSpacing(2)

        case .list(let items):
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items.indices, id: \.self) { i in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("•").font(.body)
                        inlineText(items[i]).font(.body)
                    }
                }
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        AgreementBlockView(block: .h1([.text("ДОГОВОР-ОФЕРТА")]))
        AgreementBlockView(block: .paragraph([.text("на оказание образовательных услуг")]))
        AgreementBlockView(block: .h2([.text("1. Общие положения")]))
        AgreementBlockView(block: .paragraph([.text("Настоящий документ является официальным предложением...")]))
        AgreementBlockView(block: .h2([.text("2. Права и обязанности сторон")]))
        AgreementBlockView(block: .list([
            [.text("Исполнитель обязуется ...")],
            [.text("Заказчик обязуется ...")]
        ]))
    }
    .padding(24)
}
