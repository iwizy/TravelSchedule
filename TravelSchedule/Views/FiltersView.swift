//
//  FiltersView.swift
//  TravelSchedule
//
//  Экран фильтров

import SwiftUI

struct FiltersSelection: Hashable {
    enum TimeBand: CaseIterable, Hashable {
        case morning, day, evening, night
        var title: String {
            switch self {
            case .morning: return "Утро 06:00 – 12:00"
            case .day:     return "День 12:00 – 18:00"
            case .evening: return "Вечер 18:00 – 00:00"
            case .night:   return "Ночь 00:00 – 06:00"
            }
        }
    }
    var timeBands: Set<TimeBand> = []
    var transfers: Bool? = nil

    var canApply: Bool { !timeBands.isEmpty && transfers != nil }
}


struct FiltersView: View {
    @State private var selection = FiltersSelection()
    let onApply: (FiltersSelection) -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                Section {
                    bigSectionTitle("Время отправления")

                    timeRow(.morning)
                    timeRow(.day)
                    timeRow(.evening)
                    timeRow(.night)
                }

                Section {
                    bigSectionTitle("Показывать варианты с пересадками")

                    radioRow(title: "Да",   isSelected: selection.transfers == true)  { selection.transfers = true  }
                    radioRow(title: "Нет",  isSelected: selection.transfers == false) { selection.transfers = false }
                }
            }
            .listStyle(.plain)

            if selection.canApply {
                Button {
                    onApply(selection)
                } label: {
                    Text("Применить")
                        .font(.system(size: 17, weight: .bold))
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .foregroundStyle(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.ypBlueUniversal)
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.snappy, value: selection.canApply)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }

    private func timeRow(_ band: FiltersSelection.TimeBand) -> some View {
        let isOn = selection.timeBands.contains(band)
        return HStack {
            Text(band.title)
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(.primary)
            Spacer(minLength: 12)
            CheckBox(isOn: isOn)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if isOn { selection.timeBands.remove(band) }
            else    { selection.timeBands.insert(band) }
        }
        .padding(.vertical, 12)
    }

    private func radioRow(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(.primary)
            Spacer(minLength: 12)
            Radio(isOn: isSelected)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
        .padding(.vertical, 12)
    }

    private func bigSectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .listRowSeparator(.hidden)
    }
}

private struct CheckBox: View {
    let isOn: Bool
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(isOn ? Color.ypBlueUniversal : Color.primary.opacity(0.6), lineWidth: 2)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(isOn ? Color.ypBlueUniversal : Color.clear)
                )
            if isOn {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 26, height: 26)
        .animation(.snappy, value: isOn)
    }
}

private struct Radio: View {
    let isOn: Bool
    var body: some View {
        ZStack {
            Circle()
                .stroke(isOn ? Color.ypBlueUniversal : Color.primary.opacity(0.6), lineWidth: 2)
                .frame(width: 26, height: 26)
            if isOn {
                Circle()
                    .fill(Color.ypBlueUniversal)
                    .frame(width: 12, height: 12)
            }
        }
        .animation(.snappy, value: isOn)
    }
}

#Preview("Фильтры — пусто") {
    NavigationStack {
        FiltersView(onApply: { value in
            print("APPLY:", value)
        })
    }
}
