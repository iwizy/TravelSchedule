//
//  StoriesFullScreenView.swift
//  TravelSchedule
//
// Экран просмотра историй

import SwiftUI

public protocol StoryDisplayable {
    var id: UUID { get }
    var imageName: String { get }
    var title: String? { get }
    var subtitle: String? { get }
}

struct StoriesFullScreenView<Item: StoryDisplayable>: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewedStore: StoriesViewedStore
    
    let items: [Item]
    @State private var index: Int
    let autoAdvance: Bool
    let duration: TimeInterval
    
    @State private var progress: CGFloat = 0
    @State private var timer: Timer?
    @State private var isPaused = false
    
    private var longPress: some Gesture {
        LongPressGesture(minimumDuration: 0.15)
            .onChanged { _ in pause() }
            .onEnded { _ in resume() }
    }
    
    init(items: [Item], startIndex: Int, autoAdvance: Bool = true, duration: TimeInterval = 6) {
        self.items = items
        self.autoAdvance = autoAdvance
        self.duration = duration
        _index = State(initialValue: startIndex)
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $index) {
                ForEach(items.indices, id: \.self) { i in
                    ZStack {
                        Image(items[i].imageName)
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                        
                            .ignoresSafeArea()
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Spacer()
                            if let t = items[i].title, !t.isEmpty {
                                Text(t)
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundStyle(.ypWhiteUniversal)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .accessibilityAddTraits(.isHeader)
                            }
                            if let s = items[i].subtitle, !s.isEmpty {
                                Text(s)
                                    .font(.system(size: 20, weight: .regular))
                                    .foregroundStyle(.ypWhiteUniversal)
                                    .lineLimit(3)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading) 
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                    }
                    .tag(i)
                    .contentShape(Rectangle())
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .gesture(longPress)
            
            VStack {
                HStack(spacing: 6) {
                    ForEach(items.indices, id: \.self) { i in
                        StorySegmentBar(
                            state: segmentState(for: i),
                            progress: progress
                        )
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 28)
                Spacer()
            }
            
            HStack(spacing: 0) {
                Color.clear.contentShape(Rectangle()).onTapGesture { previous() }
                Color.clear.contentShape(Rectangle()).onTapGesture { next() }
            }
            .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.ypWhiteUniversal)
                            .padding(10)
                            .background(
                                Circle().fill(Color.ypBlackUniversal)
                            )
                    }
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 12)
                }
                .padding(.top, 50)
                Spacer()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
        .padding(.top, 0)
        .ignoresSafeArea(edges: [.horizontal])
        
        .onAppear {
            viewedStore.markViewed(media: items[index].id)
            startTimerIfNeeded()
        }
        .onChange(of: index) {
            for id in items.prefix(index + 1).map(\.id) {
                viewedStore.markViewed(media: id)
            }
            resetTimer()
        }
        .onDisappear { timer?.invalidate() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in pause() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in resume() }
    }
    
    private func segmentState(for i: Int) -> StorySegmentBar.State {
        if i < index { return .past }
        if i == index { return .current }
        return .future
    }
    
    private func next() { index < items.count - 1 ? (index += 1) : dismiss() }
    private func previous() { if index > 0 { index -= 1 } }
    
    private func startTimerIfNeeded() {
        guard autoAdvance else { return }
        progress = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { t in
            guard !isPaused else { return }
            progress += 0.02 / duration
            if progress >= 1 {
                t.invalidate()
                next()
            }
        }
    }
    
    private func resetTimer() { timer?.invalidate(); startTimerIfNeeded() }
    private func pause() { isPaused = true }
    private func resume() { isPaused = false }
}

#Preview("Stories Fullscreen") {
    struct StoryPreviewItem: StoryDisplayable {
        let id: UUID
        let imageName: String
        let title: String?
        let subtitle: String?
        init(_ imageName: String, _ title: String?, _ subtitle: String? = nil) {
            self.id = UUID()
            self.imageName = imageName
            self.title = title
            self.subtitle = subtitle
        }
    }
    
    let previewItems: [StoryPreviewItem] = [
        .init("item1", "Text Text Text Text Text Text Text Text Text Text Text", "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text"),
        .init("item2", "Text Text Text Text Text Text Text Text Text Text Text", "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text"),
        .init("item3", "Text Text Text Text Text Text Text Text Text Text Text", "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text"),
    ]
    
    let viewed = StoriesViewedStore()
    return StoriesFullScreenView(items: previewItems, startIndex: 0, autoAdvance: true, duration: 5)
        .environmentObject(viewed)
        .background(Color.black)
}
