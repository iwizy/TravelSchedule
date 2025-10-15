//
//  StoriesFullScreenView.swift
//  TravelSchedule
//

import SwiftUI

public protocol StoryDisplayable {
    var id: UUID { get }
    var imageName: String { get }
    var title: String? { get }
    var subtitle: String? { get }
}

// MARK: - StoriesFullScreenView
struct StoriesFullScreenView<Item: StoryDisplayable>: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewedStore: StoriesViewedStore
    
    let items: [Item]
    @State private var index: Int
    let autoAdvance: Bool
    let duration: TimeInterval
    
    // MARK: - State
    @State private var progress: CGFloat = 0
    @State private var isPaused = false
    @State private var ticker: Task<Void, Never>?
    
    // MARK: - Gestures
    private var longPress: some Gesture {
        LongPressGesture(minimumDuration: 0.15)
            .onChanged { _ in pause() }
            .onEnded { _ in resume() }
    }
    
    // MARK: - Init
    init(items: [Item], startIndex: Int, autoAdvance: Bool = true, duration: TimeInterval = 6) {
        self.items = items
        self.autoAdvance = autoAdvance
        self.duration = duration
        _index = State(initialValue: startIndex)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            TabView(selection: $index) {
                ForEach(items.indices, id: \.self) { i in
                    ZStack {
                        Image(items[i].imageName)
                            .resizable()
                            .scaledToFill()
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
            startTickerIfNeeded()
        }
        .onChange(of: index) {
            for id in items.prefix(index + 1).map(\.id) {
                viewedStore.markViewed(media: id)
            }
            resetTicker()
        }
        .onDisappear {
            ticker?.cancel()
            ticker = nil
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in pause() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in resume() }
    }
    
    // MARK: - Progress / Segments
    private func segmentState(for i: Int) -> StorySegmentBar.State {
        if i < index { return .past }
        if i == index { return .current }
        return .future
    }
    
    // MARK: - Navigation
    @MainActor
    private func next() {
        if index < items.count - 1 {
            index += 1
        } else {
            dismiss()
        }
    }
    
    @MainActor
    private func previous() {
        if index > 0 { index -= 1 }
    }
    
    // MARK: - Auto-advance ticker (Concurrency-safe)
    private func startTickerIfNeeded() {
        guard autoAdvance else { return }
        ticker?.cancel()
        ticker = Task {
            await MainActor.run { progress = 0 }
            let step = max(0.0001, 0.02 / max(0.2, duration))
            
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 20_000_000)
                var shouldFinish = false
                
                await MainActor.run {
                    if !isPaused {
                        progress += step
                        if progress >= 1 {
                            shouldFinish = true
                        }
                    }
                }
                
                if shouldFinish {
                    await MainActor.run {
                        next()
                    }
                    break
                }
            }
        }
    }
    
    private func resetTicker() {
        ticker?.cancel()
        ticker = nil
        startTickerIfNeeded()
    }
    
    // MARK: - Pause/Resume
    private func pause() { Task { await MainActor.run { isPaused = true } } }
    private func resume() { Task { await MainActor.run { isPaused = false } } }
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
