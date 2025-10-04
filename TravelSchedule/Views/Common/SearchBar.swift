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
                .foregroundStyle(.ypGrayUniversal)
            
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled(true)
                .foregroundStyle(.ypBlack)
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.ypGrayUniversal)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 36, maxHeight: 36)
        .padding(.horizontal, 8)
        .background(Color(.ypSearch))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
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
