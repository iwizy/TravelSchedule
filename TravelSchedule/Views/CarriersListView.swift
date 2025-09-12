//
//  CarriersListView.swift
//  TravelSchedule
//
//  Экран списка перевозчиков

import SwiftUI

struct CarrierOption: Identifiable, Hashable {
    let id = UUID()
    let carrierName: String
    let logoName: String
    let dateText: String
    let depart: String
    let arrive: String
    let durationText: String
    let transferNote: String?
}

final class CarriersListViewModel: ObservableObject {
    @Published var options: [CarrierOption] = [
        CarrierOption(
            carrierName: "РЖД", logoName: "rzd_logo",
            dateText: "14 января", depart: "22:30", arrive: "08:15",
            durationText: "20 часов",
            transferNote: "С пересадкой в Костроме"
        ),
        CarrierOption(
            carrierName: "ФГК", logoName: "fgk_logo",
            dateText: "15 января", depart: "01:15", arrive: "09:00",
            durationText: "9 часов",
            transferNote: nil
        ),
        CarrierOption(
            carrierName: "Урал логистика", logoName: "ural_logo",
            dateText: "16 января", depart: "12:30", arrive: "21:00",
            durationText: "9 часов",
            transferNote: nil
        ),
        CarrierOption(
            carrierName: "РЖД", logoName: "rzd_logo",
            dateText: "17 января", depart: "22:30", arrive: "08:15",
            durationText: "20 часов",
            transferNote: "С пересадкой в Костроме"
        ),
        CarrierOption(
            carrierName: "РЖД", logoName: "rzd_logo",
            dateText: "17 января", depart: "22:30", arrive: "08:15",
            durationText: "20 часов",
            transferNote: "С пересадкой в Костроме"
        ),
        CarrierOption(
            carrierName: "РЖД", logoName: "rzd_logo",
            dateText: "17 января", depart: "22:30", arrive: "08:15",
            durationText: "20 часов",
            transferNote: "С пересадкой в Костроме"
        )
    ]
}

struct CarriersListView: View {
    let summary: RouteSummary
    let onOpenFilters: () -> Void

    @StateObject private var vm = CarriersListViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(summary.title)
                            .font(.title.bold())
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                    }
                    .listRowSeparator(.hidden)
                }

                ForEach(vm.options) { item in
                    CarrierRow(option: item)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
                }
            }
            .listStyle(.plain)

            Button(action: onOpenFilters) {
                Text("Уточнить время")
                    .font(.system(size: 17, weight: .bold))
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.ypBlueUniversal)
                    )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}

private struct CarrierRow: View {
    let option: CarrierOption

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemGray5))
                Text("Лого")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(option.carrierName)
                        .font(.headline)
                    Spacer()
                    Text(option.dateText)
                        .foregroundStyle(.secondary)
                }

                if let note = option.transferNote {
                    Text(note)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }

                HStack {
                    Text(option.depart)
                        .font(.title3).bold()
                    DividerLine()
                    Text(option.durationText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    DividerLine()
                    Text(option.arrive)
                        .font(.title3).bold()
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.systemGray6))
        )
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .padding(.horizontal, 4)
    }
}

private struct DividerLine: View {
    var body: some View {
        Rectangle()
            .fill(Color(.systemGray3))
            .frame(height: 1)
            .padding(.horizontal, 6)
    }
}

#Preview("CarriersListView") {
    NavigationStack {
        CarriersListView(
            summary: RouteSummary(
                fromCity: "Москва", fromStation: "Курский вокзал",
                toCity: "Санкт Петербург", toStation: "Балтийский вокзал"
            ),
            onOpenFilters: { print("Open filters") }
        )
    }
}
