//
//  SettingsView.swift
//  TravelSchedule
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) private var systemScheme
    @State private var showAgreement = false
    
    private var isDarkBinding: Binding<Bool> {
        Binding(
            get: { (themeManager.effectiveScheme ?? systemScheme) == .dark },
            set: { themeManager.setOverride($0 ? .dark : .light) }
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        Text(LocalizedStringKey("settings.dark"))
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(.ypBlack)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Toggle("", isOn: isDarkBinding)
                            .labelsHidden()
                            .tint(.ypBlueUniversal)
                    }
                    .frame(height: 60)
                    .padding(.horizontal, 16)
                    
                    Button {
                        showAgreement = true
                    } label: {
                        HStack(spacing: 12) {
                            Text(LocalizedStringKey("settings.agreement"))
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(.ypBlack)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.ypBlack)
                        }
                        .frame(height: 60)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                }
                .padding(.top, 24)
                
                Spacer(minLength: 0)
                
                VStack(spacing: 8) {
                    Text(LocalizedStringKey("settings.api.title"))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.ypBlack)
                        .multilineTextAlignment(.center)
                    
                    Text(LocalizedStringKey("settings.version"))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.ypBlack)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            }
            .background(Color.ypWhite)
            .navigationBarTitleDisplayMode(.inline)
        }
        .fullScreenCover(isPresented: $showAgreement) {
            UserAgreementView()
        }
    }
}

#Preview {
    let tm = ThemeManager()
    SettingsView()
        .environmentObject(tm)
}
