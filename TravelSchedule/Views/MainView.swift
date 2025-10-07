//
//  MainView.swift
//  TravelSchedule
//
//  Главный экран

import SwiftUI

struct MainView: View {
    @EnvironmentObject var router: MainRouter
    @State private var activeStoryID: UUID?
    
    @State private var fromCity: String?
    @State private var fromStation: String?
    @State private var toCity: String?
    @State private var toStation: String?
    
    @StateObject private var carriersFilter = CarriersFilterModel()
    @StateObject private var viewedStore = StoriesViewedStore()
    
    private struct StoriesOpenContext: Identifiable {
        let id = UUID()
        let groupIndex: Int
        let mediaIndex: Int
    }
    @State private var storiesOpen: StoriesOpenContext?
    
    private let storyGroups: [StoryGroup] = StoriesMocks.groups
    
    var body: some View {
        VStack(spacing: 0) {
            
            storiesCarousel
                .padding(.top, 16)
            
            routeCard
                .padding(.top, 44)
            
            if isRouteComplete {
                findButton
                    .padding(.top, 16)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .principal) { EmptyView() } }
        .background(.ypWhite)
        
        .fullScreenCover(item: $storiesOpen) { ctx in
            StoriesPlayerView(
                groups: storyGroups,
                startGroupIndex: ctx.groupIndex,
                startMediaIndex: ctx.mediaIndex
            )
            .environmentObject(viewedStore)
        }
        
        .navigationDestination(for: MainRoute.self) { route in
            switch route {
            case .city(let field):
                CityPickerView(field: field)
                
            case .station(let city, let field):
                StationPickerView(city: city) { station in
                    switch field {
                    case .from:
                        fromCity = city.title
                        fromStation = station.title
                    case .to:
                        toCity = city.title
                        toStation = station.title
                    }
                    router.path = []
                }
                
            case .carriers(let summary):
                CarriersListView(summary: summary)
                    .environmentObject(carriersFilter)
                
            case .carrierInfo(let carrier):
                CarrierInfoView(carrier: carrier)
                
            case .filters:
                FiltersView { newFilters in
                    carriersFilter.appliedFilters = newFilters
                    router.path.removeLast()
                }
                .environmentObject(carriersFilter)
            }
        }
    }
    
    private var storiesCarousel: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 12) {
                ForEach(Array(storyGroups.enumerated()), id: \.1.id) { (gi, group) in
                    StoryCardView(
                        title: group.title,
                        imageName: group.avatar,
                        isViewed: !viewedStore.hasUnviewed(in: group)
                    )
                    .id(group.id)
                    .onTapGesture {
                        let mi = viewedStore.firstUnviewedIndex(in: group) ?? 0
                        storiesOpen = StoriesOpenContext(groupIndex: gi, mediaIndex: mi)
                    }
                }
            }
            .padding(.horizontal, 2)
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $activeStoryID)
        .frame(height: 140 + 8)
        .onAppear {
            if activeStoryID == nil { activeStoryID = storyGroups.first?.id }
        }
    }
    
    private var routeCard: some View {
        ZStack(alignment: .trailing) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ypBlueUniversal)
                .frame(maxWidth: .infinity)
                .frame(height: 128)
            
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.ypWhiteUniversal))
                .frame(maxWidth: .infinity, maxHeight: 96)
                .padding(.leading, 16)
                .padding(.vertical, 16)
                .padding(.trailing, 68)
                .overlay(
                    VStack(alignment: .leading, spacing: 24) {
                        Button {
                            router.path.append(.city(.from))
                        } label: {
                            RouteTextRow(
                                placeholder: "main.from",
                                valueText: fromTitle
                            )
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            router.path.append(.city(.to))
                        } label: {
                            RouteTextRow(
                                placeholder: "main.to",
                                valueText: toTitle
                            )
                        }
                        .buttonStyle(.plain)
                        
                    }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                )
            
            Button {
                swapRoute()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(.ypWhiteUniversal))
                        .frame(width: 36, height: 36)
                    
                    Image("SwapIcon")
                        .foregroundStyle(.ypBlueUniversal)
                }
            }
            .buttonStyle(.plain)
            .padding(.trailing, 16)
            .sensoryFeedback(.impact, trigger: fromCity ?? "" + (toCity ?? ""))
        }
    }
    
    private var findButton: some View {
        Button {
            guard
                let fC = fromCity, let fS = fromStation,
                let tC = toCity, let tS = toStation
            else { return }
            
            let summary = RouteSummary(fromCity: fC, fromStation: fS, toCity: tC, toStation: tS)
            router.path.append(.carriers(summary))
        } label: {
            Text(LocalizedStringKey("main.search"))
                .font(.system(size: 17, weight: .bold))
                .frame(width: 150, height: 60)
                .foregroundStyle(.ypWhiteUniversal)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.ypBlueUniversal)
                )
        }
        .buttonStyle(.plain)
        .padding(.top, 0)
    }
    
    private var isRouteComplete: Bool {
        fromCity != nil && fromStation != nil && toCity != nil && toStation != nil
    }
    
    private var fromTitle: String {
        if let c = fromCity, let s = fromStation { return "\(c) (\(s))" }
        return ""
    }
    
    private var toTitle: String {
        if let c = toCity, let s = toStation { return "\(c) (\(s))" }
        return ""
    }
    
    private func swapRoute() {
        withAnimation(.easeInOut) {
            swap(&fromCity, &toCity)
            swap(&fromStation, &toStation)
        }
    }
}

struct StoryCardView: View {
    let title: String
    let imageName: String
    let isViewed: Bool
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 92, height: 140)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .opacity(isViewed ? 0.5 : 1.0)
            
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isViewed ? Color.clear : Color.ypBlueUniversal, lineWidth: 4)
                .frame(width: 92, height: 140)
            

            Text(LocalizedStringKey(title))
                .font(.footnote.weight(.regular))
                .foregroundStyle(.ypWhiteUniversal)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
        }
        .frame(width: 92, height: 140)
    }
}

private struct RouteTextRow: View {
    let placeholder: String
    let valueText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if valueText.isEmpty {
                Text(LocalizedStringKey(placeholder))
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.ypGrayUniversal)
                    .tint(.ypGrayUniversal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)
            } else {
                Text(valueText)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.ypBlackUniversal)
                    .tint(.ypGrayUniversal)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)
                    .padding(.trailing, 56)
            }
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack { MainView() }
}
