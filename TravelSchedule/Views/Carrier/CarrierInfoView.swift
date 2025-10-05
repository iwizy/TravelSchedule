//
//  CarrierInfoView.swift
//  TravelSchedule
//
//  Экран информации о перевозчике

import SwiftUI

struct CarrierInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: CarrierInfoViewModel
    
    init(carrier: Carrier) {
        _viewModel = StateObject(wrappedValue: CarrierInfoViewModel(carrier: carrier))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            logoContainer
            
            Text(viewModel.carrier.name)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.ypBlack)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            
            contactRow(
                title: "E-mail",
                value: viewModel.emailValue,
                url: viewModel.emailURL
            )
            contactRow(
                title: "Телефон",
                value: viewModel.phoneDisplayValue,
                url: viewModel.phoneURL
            )
            
            Spacer(minLength: 0)
        }
        .padding(.top, 16)
        .background(Color.ypWhite)
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden(true)
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.ypBlack)
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }
    
    private var logoContainer: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.ypWhiteUniversal)
            
            if let url = viewModel.carrier.logoURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img
                            .resizable()
                            .scaledToFit()
                            .frame(height: 104)
                            .padding(.horizontal, 16)
                    case .empty, .failure(_):
                        EmptyView()
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                EmptyView()
            }
        }
        .frame(height: 104)
        .padding(.horizontal, 16)
    }
    
    private func contactRow(title: String, value: String, url: URL?) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(.ypBlack)
            
            if let url = url {
                Link(value, destination: url)
                    .font(.system(size: 12))
                    .foregroundStyle(.ypBlueUniversal)
            } else {
                Text(value)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 60, alignment: .center)
        .padding(.horizontal, 16)
    }
}
