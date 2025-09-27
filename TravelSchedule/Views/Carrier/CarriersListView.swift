//
//  CarriersListView.swift
//  TravelSchedule
//
//  Экран списка перевозчиков

import SwiftUI

final class CarriersListViewModel: ObservableObject {
    @Published var options: [CarrierOption] = [
        CarrierOption(
            carrierName: "РЖД", logoName: "rzd_logo",
            dateText: "14 января", depart: "06:15", arrive: "12:05",
            durationText: "5 ч 50 м",
            transferNote: nil
        ),
        CarrierOption(
            carrierName: "ФГК", logoName: "fgk_logo",
            dateText: "15 января", depart: "01:15", arrive: "09:00",
            durationText: "7 ч 45 м",
            transferNote: "С пересадкой в Твери"
        ),
        CarrierOption(
            carrierName: "Урал логистика", logoName: "ural_logo",
            dateText: "16 января", depart: "12:30", arrive: "21:00",
            durationText: "8 ч 30 м",
            transferNote: nil
        ),
        CarrierOption(
            carrierName: "РЖД", logoName: "rzd_logo",
            dateText: "17 января", depart: "22:30", arrive: "08:15",
            durationText: "9 ч 45 м",
            transferNote: "С пересадкой в Костроме"
        ),
        CarrierOption(
            carrierName: "РЖД", logoName: "rzd_logo",
            dateText: "17 января", depart: "18:05", arrive: "23:15",
            durationText: "5 ч 10 м",
            transferNote: nil
        ),
        CarrierOption(
            carrierName: "РЖД", logoName: "rzd_logo",
            dateText: "17 января", depart: "18:05", arrive: "23:15",
            durationText: "5 ч 10 м",
            transferNote: nil
        ),
        CarrierOption(
            carrierName: "Урал логистика", logoName: "ural_logo",
            dateText: "16 января", depart: "12:30", arrive: "21:00",
            durationText: "8 ч 30 м",
            transferNote: nil
        )
    ]
}

struct CarriersListView: View {
    
    let summary: RouteSummary
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: MainRouter
    @EnvironmentObject var filters: CarriersFilterModel
    @StateObject private var vm = CarriersListViewModel()
    
    private var filteredOptions: [CarrierOption] {
        guard let f = filters.appliedFilters else { return vm.options }
        return vm.options.filter { option in
            matchTransfers(option, f) && matchTimeBands(option, f)
        }
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
                
                if filteredOptions.isEmpty {
                    Spacer()
                    Text("Вариантов нет")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.ypBlack)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 24)
                    Spacer()
                    Color.clear.frame(height: 56 + 12 + 8)
                } else {
                    List {
                        ForEach(filteredOptions) { item in
                            CarrierRow(option: item)
                                .listRowSeparator(.hidden)
                                .listRowInsets(.init(top: 0, leading: 16, bottom: 8, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                    .listRowSeparator(.hidden)
                    .listRowSpacing(0)
                    .listSectionSpacing(.custom(0))
                    .padding(.top, 16)
                    .safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: 56 + 12 + 8)
                    }
                }
            }
            
            Button {
                router.path.append(.filters)
            } label: {
                HStack(spacing: 8) {
                    Text("Уточнить время")
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
            .accessibilityLabel(Text(hasActiveFilters ? "Уточнить время, фильтры применены" : "Уточнить время"))
        }
        
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.ypBlack)
                }
            }
        }
        .tint(.ypBlack)
        .toolbar(.hidden, for: .tabBar)
        .onDisappear {
            filters.appliedFilters = nil
        }
    }
    
    
    private func matchTransfers(_ option: CarrierOption, _ filters: FiltersSelection) -> Bool {
        guard let t = filters.transfers else { return true }
        let hasTransfer = (option.transferNote != nil)
        return t ? hasTransfer : !hasTransfer
    }
    
    private func matchTimeBands(_ option: CarrierOption, _ filters: FiltersSelection) -> Bool {
        guard !filters.timeBands.isEmpty else { return true }
        guard let hour = parseHour(option.depart) else { return false }
        for band in filters.timeBands {
            switch band {
            case .morning: if (6...11).contains(hour) { return true }
            case .day:     if (12...17).contains(hour) { return true }
            case .evening: if (18...23).contains(hour) { return true }
            case .night:   if (0...5).contains(hour)   { return true }
            }
        }
        return false
    }
    
    private func parseHour(_ hhmm: String) -> Int? {
        let comps = hhmm.split(separator: ":")
        guard comps.count == 2, let h = Int(comps[0]) else { return nil }
        return h
    }
}

private struct CarrierRow: View {
    let option: CarrierOption
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                
                HStack(spacing: 12) {
                    Image(option.logoName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 38, height: 38)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    
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
