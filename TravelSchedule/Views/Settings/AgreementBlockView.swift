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

    public var body: some View {
        switch block {
        case .h1(let text):
            Text(text)
                .font(.title.bold())
                .multilineTextAlignment(.leading)

        case .h2(let text):
            Text(text)
                .font(.title3.bold())
                .multilineTextAlignment(.leading)

        case .paragraph(let text):
            Text(text)
                .font(.body)
                .lineSpacing(2)

        case .list(let items):
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items.indices, id: \.self) { i in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("•").font(.body)
                        Text(items[i]).font(.body)
                    }
                }
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        AgreementBlockView(block: .h1("ДОГОВОР-ОФЕРТА"))
        AgreementBlockView(block: .paragraph("на оказание образовательных услуг"))
        AgreementBlockView(block: .h2("1. Общие положения"))
        AgreementBlockView(block: .paragraph("Настоящий документ является официальным предложением..."))
        AgreementBlockView(block: .h2("2. Права и обязанности сторон"))
        AgreementBlockView(block: .list(["Исполнитель обязуется ...", "Заказчик обязуется ..."]))
    }
    .padding(24)
}
