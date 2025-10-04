//
//  CityPickerView.swift
//  TravelSchedule
//
//  Экран выбора города

import SwiftUI

struct CityPickerView: View {
    let field: RouteField
    
    @EnvironmentObject var router: MainRouter
    @Environment(\.dismiss) private var dismiss
    @Environment(\.apiClient) private var apiClient
    @StateObject private var viewModel = CityPickerViewModel()
    
    @State private var query: String = ""
    
    init(field: RouteField, initialQuery: String? = nil) {
        self.field = field
        if let q = initialQuery {
            _query = State(initialValue: q)
        }
    }
    
    private var filteredCities: [City] { viewModel.filtered }
    
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
                    
                    if filteredCities.isEmpty && !query.isEmpty && !viewModel.isLoading {
                        Text("Город не найден")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.ypBlack)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .allowsHitTesting(false)
                    }
                }
            }
            .navigationTitle("Выбор города")
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
            print("➡️ [CityPicker] task load start")
            await viewModel.load(apiClient: apiClient)
            if !query.isEmpty {
                viewModel.setInitialQuery(query)
            } else {
                viewModel.applySearch()
            }
            print("✅ [CityPicker] task load done")
        }
        .task(id: query) {
            viewModel.searchText = query
            viewModel.applySearch()
        }
    }
}
