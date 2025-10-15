//
//  GroupPlayerView.swift
//  TravelSchedule
//

import SwiftUI

struct GroupPlayerView: View {
    let group: StoryGroup
    let startIndex: Int
    let onClose: () -> Void
    let onFinishGroup: () -> Void
    let onUpdateIndex: (Int) -> Void
    let onViewed: (UUID) -> Void
    
    let onPrevGroup: () -> Void
    
    @State private var index: Int
    @State private var progress: CGFloat = 0
    @State private var isPaused = false
    
    // MARK: - Ticker
    @State private var ticker: Task<Void, Never>?
    
    // MARK: - Init
    init(
        group: StoryGroup,
        startIndex: Int,
        onClose: @escaping () -> Void,
        onFinishGroup: @escaping () -> Void,
        onPrevGroup: @escaping () -> Void,
        onUpdateIndex: @escaping (Int) -> Void,
        onViewed: @escaping (UUID) -> Void
    ) {
        self.group = group
        self.startIndex = startIndex
        self.onClose = onClose
        self.onFinishGroup = onFinishGroup
        self.onPrevGroup = onPrevGroup
        self.onUpdateIndex = onUpdateIndex
        self.onViewed = onViewed
        _index = State(initialValue: startIndex)
    }
    
    // MARK: - Derived
    private var medias: [StoryMedia] { group.items }
    
    private var horizontalSwipe: some Gesture {
        DragGesture(minimumDistance: 24, coordinateSpace: .local)
            .onEnded { value in
                let dx = value.translation.width
                if dx < -24 {
                    next()
                } else if dx > 24 {
                    if index > 0 {
                        previous()
                    } else {
                        onPrevGroup()
                    }
                }
            }
    }
    
    // MARK: - View
    var body: some View {
        ZStack {
            Image(medias[index].imageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            LinearGradient(colors: [.clear, .black.opacity(0.65)],
                           startPoint: .center, endPoint: .bottom)
            .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 8) {
                Spacer(minLength: 0)
                
                if let t = medias[index].title, !t.isEmpty {
                    Text(LocalizedStringKey(t))
                        .font(.system(size: 34, weight: .heavy))
                        .foregroundStyle(.white)
                        .shadow(radius: 2)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if let s = medias[index].subtitle, !s.isEmpty {
                    Text(LocalizedStringKey(s))
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.95))
                        .shadow(radius: 1)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            
            VStack {
                HStack(spacing: 6) {
                    ForEach(medias.indices, id: \.self) { i in
                        StorySegmentBar(state: segmentState(for: i), progress: progress)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 28)
                Spacer()
            }
            
            HStack(spacing: 0) {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { previous() }
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { next() }
            }
            .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button { onClose() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(Circle().fill(Color.black.opacity(0.8)))
                    }
                    .padding(.trailing, 12)
                }
                .padding(.top, 50)
                Spacer()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
        .padding(.top, 8)
        .ignoresSafeArea(edges: [.horizontal, .bottom])
        .highPriorityGesture(horizontalSwipe)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.15)
                .onChanged { _ in pause() }
                .onEnded { _ in resume() }
        )
        .onAppear {
            onViewed(medias[index].id)
            startTicker()
        }
        .onChange(of: index) { _, newValue in
            onViewed(medias[newValue].id)
            onUpdateIndex(newValue)
            resetTicker()
        }
        .onDisappear { cancelTicker() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in pause() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in resume() }
    }
    
    // MARK: - Segment State
    private func segmentState(for i: Int) -> StorySegmentBar.State {
        if i < index { return .past }
        if i == index { return .current }
        return .future
    }
    
    // MARK: - Navigation
    private func next() {
        if index < medias.count - 1 {
            index += 1
        } else {
            onFinishGroup()
        }
    }
    
    private func previous() {
        if index > 0 {
            index -= 1
        } else {
            onPrevGroup()
        }
    }
    
    // MARK: - Ticker control (Structured Concurrency)
    private func startTicker() {
        cancelTicker()
        progress = 0
        isPaused = false
        
        let duration = max(0.2, medias[index].duration)
        let step: Double = 0.02
        
        ticker = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 20_000_000)
                await MainActor.run {
                    guard !isPaused else { return }
                    progress += step / duration
                    if progress >= 1 {
                        progress = 1
                        next()
                    }
                }
            }
        }
    }
    
    private func resetTicker() {
        cancelTicker()
        startTicker()
    }
    
    private func cancelTicker() {
        ticker?.cancel()
        ticker = nil
    }
    
    // MARK: - Pause/Resume
    private func pause() { isPaused = true }
    private func resume() { isPaused = false }
}
