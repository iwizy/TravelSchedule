//
//  ErrorPlaceholderView.swift
//  TravelSchedule
//
//  Экран ошибок

import SwiftUI

enum AppErrorType {
    case server
    case noInternet
    
    var title: String {
        switch self {
        case .server:
            "Ошибка сервера"
        case .noInternet:
            "Нет интернета"
        }
    }
    var imageName: String {
        switch self {
        case .server:
            "error_server"
        case .noInternet:
            "error_offline"
        }
    }
}

struct ErrorPlaceholderView: View {
    let type: AppErrorType
    
    var body: some View {
        VStack(spacing: 16) {
            Image(type.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 223)
            Text(type.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.ypBlack)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.ypWhite))
    }
}

#Preview {
    ErrorPlaceholderView(type: .server)
}
