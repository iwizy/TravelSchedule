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
    @Environment(\.dismiss) private var dismiss
    @State private var selection = FiltersSelection()
    let onApply: (FiltersSelection) -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                Section {
                    timeRow(.morning)
                        .frame(height: 60)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))

                    timeRow(.day)
                        .frame(height: 60)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))

                    timeRow(.evening)
                        .frame(height: 60)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))

                    timeRow(.night)
                        .frame(height: 60)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 0, leading: 16, bottom: 16, trailing: 16))
                } header: {
                    Text("Время отправления")
                        .font(.system(size: 24, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical,0)
                        .textCase(nil)
                        .foregroundStyle(Color.ypBlack)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))

                Section {
                    radioRow(title: "Да",   isSelected: selection.transfers == true)  { selection.transfers = true  }
                        .listRowSeparator(.hidden)
                        .frame(height: 60)

                    radioRow(title: "Нет",  isSelected: selection.transfers == false) { selection.transfers = false }
                        .listRowSeparator(.hidden)
                        .frame(height: 60)

                } header: {
                    Text("Показывать варианты с пересадками")
                        .font(.system(size: 24, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical,0)
                        .textCase(nil)
                        .foregroundStyle(Color.ypBlack)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
                
            }
            .listStyle(.plain)
            .listRowSpacing(0)
            .listSectionSpacing(.custom(0))
            
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.ypBlack)
                }
            }
        }
        .tint(.ypBlack)
        .toolbar(.hidden, for: .tabBar)
    }

    private func timeRow(_ band: FiltersSelection.TimeBand) -> some View {
        let isOn = selection.timeBands.contains(band)
        return HStack {
            Text(band.title)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(.ypBlack)
            Spacer(minLength: 12)
            CheckBox(isOn: isOn)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if isOn { selection.timeBands.remove(band) }
            else    { selection.timeBands.insert(band) }
        }
    }

    private func radioRow(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(.ypBlack)
            Spacer(minLength: 12)
            Radio(isOn: isSelected)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}

private struct CheckBox: View {
    let isOn: Bool
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(isOn ? Color.ypBlack : Color.primary.opacity(0.6), lineWidth: 2)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(isOn ? Color.ypBlack : Color.clear)
                )
            if isOn {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.ypWhite)
            }
        }
        .frame(width: 24, height: 24)
        .animation(.snappy, value: isOn)
    }
}

private struct Radio: View {
    let isOn: Bool
    var body: some View {
        ZStack {
            Circle()
                .stroke(isOn ? Color.ypBlack : Color.primary.opacity(0.6), lineWidth: 2)
                .frame(width: 24, height: 24)
            if isOn {
                Circle()
                    .fill(Color.ypBlack)
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
