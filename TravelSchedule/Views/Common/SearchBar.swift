//
//  SearchBar.swift
//  TravelSchedule
//
//  Компонент поиска

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled(true)
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview("SearchBar — пустой") {
    @Previewable @State var text = ""
    return SearchBar(text: $text, placeholder: "Введите запрос")
        .padding()
}

#Preview("SearchBar — с текстом") {
    @Previewable @State var text = "Москва"
    return SearchBar(text: $text, placeholder: "Введите запрос")
        .padding()
}
