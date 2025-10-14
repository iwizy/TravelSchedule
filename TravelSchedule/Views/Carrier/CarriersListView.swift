//
//  CarriersListView.swift
//  TravelSchedule
//

import SwiftUI

struct CarriersListView: View {
    
    let summary: RouteSummary
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: MainRouter
    @EnvironmentObject var filters: CarriersFilterModel
    @StateObject private var vm = CarriersListViewModel()
    @Environment(\.apiClient) private var apiClient
    
    @State private var didLoadOnce = false
    
    private var filteredOptions: [CarrierOption] {
        applyFilters(vm.options, filters.appliedFilters)
    }
    
    private var hasActiveFilters: Bool {
        if let f = filters.appliedFilters { return f.canApply }
        return false
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            VStack(alignment: .leading, spacing: 0) {
                Text(summary.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.ypBlack)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                
                if vm.hasAvailability == nil {
                    Spacer()
                    Color.clear.frame(height: 56 + 12 + 8)
                } else if vm.hasAvailability == false {
                    Spacer()
                    Text(LocalizedStringKey("carrier.no.options"))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.ypBlack)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 24)
                    Spacer()
                    Color.clear.frame(height: 56 + 12 + 8)
                } else {
                    if filteredOptions.isEmpty {
                        Spacer()
                        Text(LocalizedStringKey("carrier.no.options"))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.ypBlack)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 24)
                        Spacer()
                        Color.clear.frame(height: 56 + 12 + 8)
                    } else {
                        carriersList // ← вынесено отдельно, чтобы упростить type-check
                    }
                }
            }
            
            Button {
                router.path.append(.filters)
            } label: {
                HStack(spacing: 8) {
                    Text(LocalizedStringKey("carrier.list.button"))
                        .font(.system(size: 17, weight: .bold))
                    
                    if hasActiveFilters {
                        Circle()
                            .fill(Color.ypRedUniversal)
                            .frame(width: 10, height: 10)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 60)
                .foregroundStyle(.ypWhiteUniversal)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.ypBlueUniversal)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            .animation(.snappy, value: hasActiveFilters)
        }
        
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    filters.appliedFilters = nil
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.ypBlack)
                }
            }
        }
        .toolbarBackground(Color(.ypWhite), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .tint(.ypBlack)
        .toolbar(.hidden, for: .tabBar)
        .task {
            guard !didLoadOnce else { return }
            didLoadOnce = true
            await vm.checkAvailabilityReal(apiClient: apiClient, summary: summary)
        }
        .overlay {
            if vm.isChecking {
                ZStack {
                    Color.ypWhite.ignoresSafeArea()
                    LoaderView()
                }
                .transition(.opacity)
            }
        }
        .disabled(vm.isChecking)
        .background(Color(.ypWhite).ignoresSafeArea())
    }
    
    // MARK: - Extracted views (упростили type-checker)
    private var carriersList: some View {
        List {
            ForEach(filteredOptions, id: \.id) { (item: CarrierOption) in
                Button {
                    router.path.append(.carrierInfo(carrier(from: item)))
                } label: {
                    CarrierRow(option: item)
                        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
                .buttonStyle(.plain)
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .listRowSeparator(.hidden)
        .listRowSpacing(0)
        .listSectionSpacing(.custom(0))
        .scrollContentBackground(.hidden)
        .listRowBackground(Color.clear)
        .background(Color(.ypWhite))
        .padding(.top, 16)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 56 + 12 + 8)
        }
    }
    
    private func applyFilters(_ options: [CarrierOption], _ selection: FiltersSelection?) -> [CarrierOption] {
        guard let f = selection, f.canApply else { return options }
        let byTransfers: [CarrierOption] = {
            guard let t = f.transfers else { return options }
            if t == true {
                return options
            } else {
                return options.filter { !optionHasTransfer($0) }
            }
        }()
        
        if f.timeBands.isEmpty { return byTransfers }
        return byTransfers.filter { opt in
            guard let hour = parseHour(opt.depart) else { return false }
            for band in f.timeBands {
                switch band {
                case .morning: if (6...11).contains(hour) { return true }
                case .day:     if (12...17).contains(hour) { return true }
                case .evening: if (18...23).contains(hour) { return true }
                case .night:   if (0...5).contains(hour)   { return true }
                }
            }
            return false
        }
    }
    
    private func optionHasTransfer(_ option: CarrierOption) -> Bool {
        return option.transferNote != nil
    }
    
    private func parseHour(_ hhmm: String) -> Int? {
        let comps = hhmm.split(separator: ":")
        guard comps.count == 2, let h = Int(comps[0]) else { return nil }
        return h
    }
    
    private func carrier(from option: CarrierOption) -> Carrier {
        Carrier(
            id: option.logoName,
            name: option.carrierName,
            logoAsset: option.logoName,
            logoURL: option.logoURL,
            email: option.email,
            phoneE164: option.phoneE164,
            phoneDisplay: option.phoneDisplay
        )
    }
}

// MARK: - Row

private struct CarrierRow: View {
    let option: CarrierOption
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                HStack(spacing: 12) {
                    logoView
                        .frame(width: 38, height: 38)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(option.carrierName)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(.ypBlackUniversal)
                        
                        if let note = option.transferNote {
                            Text(note)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(.ypRedUniversal)
                        }
                    }
                    .frame(height: 38, alignment: .center)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 14)
                .padding(.horizontal, 14)
                
                Text(option.dateText)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.ypBlackUniversal)
                    .padding(.top, 15)
                    .padding(.trailing, 14)
            }
            
            HStack {
                Text(option.depart)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.ypBlackUniversal)
                
                DividerLine()
                
                Text(option.durationText)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.ypBlackUniversal)
                
                DividerLine()
                
                Text(option.arrive)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.ypBlackUniversal)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.ypLightGray))
        )
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
    
    @ViewBuilder
    private var logoView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.ypWhiteUniversal)
            
            if let url = option.logoURL {
                AsyncImage(url: url, transaction: .init(animation: .easeInOut)) { phase in
                    switch phase {
                    case .empty:
                        EmptyView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .padding(6)
                            .transition(.opacity.combined(with: .scale))
                    case .failure:
                        EmptyView()
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                EmptyView()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .compositingGroup()
        .drawingGroup(opaque: false)
    }
}

private struct DividerLine: View {
    var body: some View {
        Rectangle()
            .fill(Color(.ypGrayUniversal))
            .frame(height: 1)
            .padding(.horizontal, 6)
    }
}

#Preview("CarriersListView — push filters") {
    NavigationStack {
        CarriersListView(
            summary: RouteSummary(
                fromCity: "Москва", fromStation: "Курский вокзал",
                toCity: "Санкт-Петербург", toStation: "Балтийский вокзал"
            )
        )
        .environmentObject(MainRouter())
        .environmentObject(CarriersFilterModel())
    }
}
