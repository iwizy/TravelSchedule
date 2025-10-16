//
//  CityPickerView.swift
//  TravelSchedule
//

import SwiftUI

struct CityPickerView: View {
    // MARK: CityPickerView.Input
    let field: RouteField
    
    // MARK: CityPickerView.Environment
    @EnvironmentObject var router: MainRouter
    @Environment(\.dismiss) private var dismiss
    @Environment(\.apiClient) private var apiClient
    @EnvironmentObject private var errors: ErrorCenter
    
    // MARK: CityPickerView.State
    @StateObject private var viewModel = CityPickerViewModel()
    @State private var query: String = ""
    
    // MARK: CityPickerView.Init
    init(field: RouteField, initialQuery: String? = nil) {
        self.field = field
        if let q = initialQuery {
            _query = State(initialValue: q)
        }
    }
    
    // MARK: CityPickerView.Derived
    private var filteredCities: [City] { viewModel.filtered }
    
    // MARK: CityPickerView.Body
    var body: some View {
        ZStack {
            VStack(spacing: .zero) {
                SearchBar(text: $query, placeholder: String(localized: "city.search.placeholder"))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                    .background(Color(.ypWhite))
                
                ZStack {
                    switch viewModel.state {
                    case .idle, .loading:
                        Color.clear
                            .overlay {
                                LoaderView()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.black.opacity(0.001))
                                    .transition(.opacity)
                            }
                    case .loaded:
                        ScrollView {
                            LazyVStack(spacing: .zero) {
                                ForEach(Array(filteredCities.enumerated()), id: \.element.id) { _, city in
                                    Button {
                                        print("🧭 [CityPicker] select city=\(city.title) (\(city.id))")
                                        router.path.append(.station(city, field))
                                    } label: {
                                        HStack {
                                            Text(city.title)
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
                        .overlay {
                            if filteredCities.isEmpty && !query.isEmpty {
                                Text(LocalizedStringKey("city.picker.not.found"))
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(.ypBlack)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .allowsHitTesting(false)
                                    .transition(.opacity)
                            }
                        }
                    case .error(let message):
                        VStack(spacing: 12) {
                            Text(LocalizedStringKey("city.picker.title"))
                                .font(.headline)
                            Text(message)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Button(String(localized: "common.retry")) {
                                Task { await viewModel.load(apiClient: apiClient, force: true) }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("city.picker.title"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(Color(.ypWhite), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
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
            .background(Color(.ypWhite))
            .disabled(viewModel.state == .loading)
        }
        // MARK: CityPickerView.Tasks
        .task {
            let force = errors.serverError
            print("➡️ [CityPicker] task load start (force=\(force))")
            await viewModel.load(apiClient: apiClient, force: force)
            if !query.isEmpty { viewModel.setInitialQuery(query) }
            else { viewModel.applySearch() }
            print("✅ [CityPicker] task load done")
        }
        .task(id: query) {
            viewModel.searchText = query
            viewModel.applySearch()
        }
    }
}
