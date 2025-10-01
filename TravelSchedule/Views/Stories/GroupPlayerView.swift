//
//  GroupPlayerView.swift
//  TravelSchedule
//
//  Плеер группы сториз

import SwiftUI

struct GroupPlayerView: View {
    let group: StoryGroup
    let startIndex: Int
    let onClose: () -> Void
    let onFinishGroup: () -> Void
    let onUpdateIndex: (Int) -> Void
    let onViewed: (UUID) -> Void
    let onRequestPrevGroup: () -> Void
    
    @State private var index: Int
    @State private var progress: CGFloat = 0
    @State private var timer: Timer?
    @State private var isPaused = false
    
    init(group: StoryGroup,
         startIndex: Int,
         onClose: @escaping () -> Void,
         onFinishGroup: @escaping () -> Void,
         onUpdateIndex: @escaping (Int) -> Void,
         onViewed: @escaping (UUID) -> Void,
         onRequestPrevGroup: @escaping () -> Void) {
        self.group = group
        self.startIndex = startIndex
        self.onClose = onClose
        self.onFinishGroup = onFinishGroup
        self.onUpdateIndex = onUpdateIndex
        self.onViewed = onViewed
        self.onRequestPrevGroup = onRequestPrevGroup
        _index = State(initialValue: startIndex)
    }
    
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
                        onRequestPrevGroup()
                    }
                }
            }
    }
    
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
                    Text(t)
                        .font(.system(size: 34, weight: .heavy))
                        .foregroundStyle(.white)
                        .shadow(radius: 2)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if let s = medias[index].subtitle, !s.isEmpty {
                    Text(s)
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
                Color.clear.contentShape(Rectangle()).onTapGesture { previous() }
                Color.clear.contentShape(Rectangle()).onTapGesture { next() }
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
            startTimer()
        }
        .onChange(of: index) { _, newValue in
            onViewed(medias[newValue].id)
            onUpdateIndex(newValue)
            resetTimer()
        }
        .onDisappear { timer?.invalidate() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in pause() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in resume() }
    }
    
    // MARK: - Навигация и прогресс
    
    private func segmentState(for i: Int) -> StorySegmentBar.State {
        if i < index { return .past }
        if i == index { return .current }
        return .future
    }
    
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
        }
    }
    
    private func startTimer() {
        progress = 0
        isPaused = false
        timer?.invalidate()
        let dur = max(0.2, medias[index].duration)
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { t in
            guard !isPaused else { return }
            progress += 0.02 / dur
            if progress >= 1 {
                t.invalidate()
                next()
            }
        }
    }
    
    private func resetTimer() { startTimer() }
    private func pause() { isPaused = true }
    private func resume() { isPaused = false }
}
