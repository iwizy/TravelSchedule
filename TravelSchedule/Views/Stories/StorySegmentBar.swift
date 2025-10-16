//
//  StorySegmentBar.swift
//  TravelSchedule
//

import SwiftUI

// MARK: - StorySegmentBar
struct StorySegmentBar: View {
    enum State { case past, current, future }
    let state: State
    let progress: CGFloat
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.ypWhiteUniversal)
                switch state {
                case .past:
                    Capsule().fill(Color.ypBlueUniversal)
                        .frame(width: geo.size.width)
                case .current:
                    Capsule().fill(Color.ypBlueUniversal)
                        .frame(width: geo.size.width * max(0, min(1, progress)))
                case .future:
                    EmptyView()
                }
            }
        }
        .frame(height: 6)
        .accessibilityHidden(true)
    }
}
