//
//  UserAgreementView.swift
//  TravelSchedule
//
//  Created by Alexander Agafonov on 24.09.2025.
//

import SwiftUI

struct UserAgreementView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var blocks: [MDBlock] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(blocks.indices, id: \.self) { i in
                        AgreementBlockView(block: blocks[i])
                    }
                }
                .padding(24)
            }
            .navigationTitle("Пользовательское соглашение")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: { Image(systemName: "chevron.left") }
                }
            }
        }
        .task { loadMarkdown() }
        .ignoresSafeArea(edges: .bottom)
    }

    private func loadMarkdown() {
        guard let url = Bundle.main.url(forResource: "UserAgreement", withExtension: "md"),
              let md = try? String(contentsOf: url, encoding: .utf8)
        else {
            blocks = [.paragraph("Не удалось загрузить документ.")]
            return
        }
        blocks = MarkdownMini.parse(md)
    }
}

#Preview {
    let md = """
    # ДОГОВОР-ОФЕРТА

    на оказание образовательных услуг

    ## 1. Общие положения

    Настоящий документ является официальным предложением...

    ## 2. Права и обязанности сторон

    - Исполнитель обязуется ...
    - Заказчик обязуется ...
    """
    let blocks = MarkdownMini.parse(md)

    return NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(blocks.indices, id: \.self) { i in
                    AgreementBlockView(block: blocks[i])
                }
            }
            .padding(24)
        }
        .navigationTitle("Пользовательское соглашение")
        .navigationBarTitleDisplayMode(.inline)
    }
}
