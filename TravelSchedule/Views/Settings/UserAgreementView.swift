//
//  UserAgreementView.swift
//  TravelSchedule
//

import SwiftUI

// MARK: - UserAgreementView
struct UserAgreementView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var blocks: [MDBlock] = []
    
    // MARK: Body
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(blocks.indices, id: \.self) { i in
                        AgreementMarkdownBlockView(block: blocks[i])
                    }
                }
                .padding(24)
            }
            .scrollContentBackground(.hidden)
            .background(Color.ypWhite.ignoresSafeArea())
            .tint(.ypBlueUniversal)
            .navigationTitle(LocalizedStringKey("settings.agreement"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: { Image(systemName: "chevron.left") }
                        .foregroundStyle(.ypBlack)
                }
            }
        }
        .task { loadMarkdown() }
        .ignoresSafeArea(edges: .bottom)
    }
    
    // MARK: Data Loading
    private func loadMarkdown() {
        guard let url = Bundle.main.url(forResource: "UserAgreement", withExtension: "md"),
              let md = try? String(contentsOf: url, encoding: .utf8)
        else {
            return
        }
        blocks = MarkdownMini.parse(md)
    }
}

// MARK: - AgreementMarkdownBlockView
private struct AgreementMarkdownBlockView: View {
    let block: MDBlock
    
    // MARK: Body
    var body: some View {
        switch block {
        case .h1(let inlines):
            Text(MarkdownMini.attributed(from: inlines))
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.ypBlack)
                .padding(.bottom, 4)
            
        case .h2(let inlines):
            Text(MarkdownMini.attributed(from: inlines))
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.ypBlack)
                .padding(.bottom, 2)
            
        case .h3(let inlines):
            Text(MarkdownMini.attributed(from: inlines))
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.ypBlack)
            
        case .paragraph(let inlines):
            Text(MarkdownMini.attributed(from: inlines))
                .font(.system(size: 15))
                .foregroundStyle(.ypBlack)
                .lineSpacing(2)
            
        case .list(let items):
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items.indices, id: \.self) { i in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("•")
                            .foregroundStyle(.ypBlack)
                        Text(MarkdownMini.attributed(from: items[i]))
                            .font(.system(size: 15))
                            .foregroundStyle(.ypBlack)
                    }
                }
            }
        }
    }
}

#Preview {
    let md = """
    # ДОГОВОР-ОФЕРТА
    
    _на оказание образовательных услуг_ и **информационных** сервисов.
    
    ## 1. Общие положения
    Настоящий документ является официальным предложением. Обращения: support@example.com или [написать нам](mailto:support@example.com).
    
    ### 1.1 Термины
    - **Пользователь** — лицо, использующее приложение.
    - _Исполнитель_ — правообладатель сервиса.
    - Сайт: [travel.example](https://travel.example)
    
    ## 2. Права и обязанности
    - Исполнитель обязуется оказывать услуги.
    - Пользователь обязуется соблюдать правила.
    """
    
    let blocks = MarkdownMini.parse(md)
    
    return NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(blocks.indices, id: \.self) { i in
                    AgreementMarkdownBlockView(block: blocks[i])
                }
            }
            .padding(24)
        }
        .tint(.blue)
        .navigationTitle("Пользовательское соглашение")
        .navigationBarTitleDisplayMode(.inline)
    }
}
