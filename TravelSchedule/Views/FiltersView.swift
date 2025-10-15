//
//  FiltersView.swift
//  TravelSchedule
//

import SwiftUI

// MARK: - FiltersView
struct FiltersView: View {
    @EnvironmentObject var filters: CarriersFilterModel
    @Environment(\.dismiss) private var dismiss
    @State private var selection = FiltersSelection()
    let onApply: (FiltersSelection) -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                departureSection
                transfersSection
            }
            .listStyle(.plain)
            .listRowSpacing(0)
            .listSectionSpacing(.custom(0))
            .scrollContentBackground(.hidden)
            .listRowBackground(Color.clear)
            .background(Color(.ypWhite))
            
            if selection.canApply {
                Button {
                    onApply(selection)
                } label: {
                    Text(LocalizedStringKey("filters.transfer.apply"))
                        .font(.system(size: 17, weight: .bold))
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
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.snappy, value: selection.canApply)
            }
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
        .onAppear {
            selection = filters.appliedFilters ?? FiltersSelection()
        }
    }
    
    // MARK: - Sections
    private var departureSection: some View {
        Section {
            timeRow(.morning)
                .frame(height: 60)
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowBackground(Color(.ypWhite))
            
            timeRow(.day)
                .frame(height: 60)
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowBackground(Color(.ypWhite))
            
            timeRow(.evening)
                .frame(height: 60)
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowBackground(Color(.ypWhite))
            
            timeRow(.night)
                .frame(height: 60)
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: 16, bottom: 16, trailing: 16))
                .listRowBackground(Color(.ypWhite))
        } header: {
            Text(LocalizedStringKey("filters.depart"))
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 0)
                .textCase(nil)
                .foregroundStyle(Color.ypBlack)
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
    }
    
    private var transfersSection: some View {
        Section {
            radioRow(
                title: String(localized: "filters.transfer.yes"),
                isSelected: selection.transfers == true
            ) { selection.transfers = true }
                .listRowSeparator(.hidden)
                .frame(height: 60)
                .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowBackground(Color(.ypWhite))
            
            radioRow(
                title: String(localized: "filters.transfer.no"),
                isSelected: selection.transfers == false
            ) { selection.transfers = false }
                .listRowSeparator(.hidden)
                .frame(height: 60)
                .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowBackground(Color(.ypWhite))
            
        } header: {
            Text(LocalizedStringKey("filters.transfer.title"))
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 0)
                .textCase(nil)
                .foregroundStyle(Color.ypBlack)
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
    }
    
    // MARK: - Rows
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

// MARK: - Components
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
                .stroke(isOn ? Color.ypBlack : Color(.ypBlack).opacity(0.6), lineWidth: 2)
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
