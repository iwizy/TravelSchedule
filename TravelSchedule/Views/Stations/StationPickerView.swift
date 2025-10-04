//
//  StationPickerView.swift
//  TravelSchedule
//
//  Экран выбора станции

import SwiftUI

struct StationPickerView: View {
    let city: City
    let onPick: (_ station: Station) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: MainRouter
    @Environment(\.apiClient) private var apiClient
    @StateObject private var viewModel = StationPickerViewModel()
    @State private var query: String = ""
    
    init(city: City, initialQuery: String? = nil, onPick: @escaping (_ station: Station) -> Void) {
        self.city = city
        self.onPick = onPick
        if let q = initialQuery {
            _query = State(initialValue: q)
        }
    }
    
    private var filteredStations: [Station] { viewModel.filtered }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                SearchBar(text: $query, placeholder: "Введите запрос")
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                    .background(Color(.systemBackground))
                
                ZStack {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(filteredStations.enumerated()), id: \.element.id) { _, station in
                                Button {
                                    print("🧭 [StationPicker] select station=\(station.title) (\(station.id)) in \(city.title)")
                                    onPick(station)
                                } label: {
                                    HStack {
                                        Text(station.title)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.ypBlack)
                                    }
                                    .frame(height: 60)
                                    .padding(.horizontal, 16)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 16)
                    }
                    
                    if filteredStations.isEmpty && !query.isEmpty && !viewModel.isLoading {
                        Text("Станции не найдены")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.ypBlack)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .allowsHitTesting(false)
                    }
                }
            }
            .navigationTitle("Выбор станции")
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
            .toolbar(.hidden, for: .tabBar)
            .background(Color(.systemBackground))
            .disabled(viewModel.isLoading)
            
            if viewModel.isLoading {
                LoaderView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .background(Color.black.opacity(0.001))
                    .transition(.opacity)
            }
        }
        .task {
            print("➡️ [StationPicker] task load start city=\(city.title) (\(city.id))")
            await viewModel.load(apiClient: apiClient, city: city)
            if !query.isEmpty {
                viewModel.setInitialQuery(query)
            } else {
                viewModel.applySearch()
            }
            print("✅ [StationPicker] task load done")
        }
        .task(id: query) {
            viewModel.searchText = query
            viewModel.applySearch()
        }
    }
}
