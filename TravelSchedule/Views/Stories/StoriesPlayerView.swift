//
//  StoriesPlayerView.swift
//  TravelSchedule
//
//  Плеер сториз

import SwiftUI

struct StoriesPlayerView: View {
    let groups: [StoryGroup]
    @State private var groupIndex: Int
    @State private var mediaIndex: Int
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: StoriesViewedStore
    
    init(groups: [StoryGroup], startGroupIndex: Int, startMediaIndex: Int) {
        self.groups = groups
        _groupIndex = State(initialValue: startGroupIndex)
        _mediaIndex = State(initialValue: startMediaIndex)
    }
    
    var body: some View {
        ZStack {
            Color.ypBlackUniversal.ignoresSafeArea()
            
            TabView(selection: $groupIndex) {
                ForEach(groups.indices, id: \.self) { gi in
                    let group = groups[gi]
                    GroupPlayerView(
                        group: group,
                        startIndex: gi == groupIndex ? mediaIndex : (store.lastIndexByGroup[group.id] ?? 0),
                        onClose: { dismiss() },
                        onFinishGroup: {
                            if gi < groups.count - 1 { groupIndex = gi + 1 } else { dismiss() }
                        },
                        onUpdateIndex: { idx in
                            store.setLastIndex(groupID: group.id, index: idx)
                            if gi == groupIndex { mediaIndex = idx }
                        },
                        onViewed: { mid in
                            store.markViewed(media: mid)
                        },
                        onRequestPrevGroup: {
                            if gi > 0 {
                                groupIndex = gi - 1
                                mediaIndex = max(0, groups[gi - 1].items.count - 1)
                            } else {
                                dismiss()
                            }
                        }
                    )
                    .tag(gi)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .onChange(of: groupIndex) { _, newGi in
            let g = groups[newGi]
            mediaIndex = store.firstUnviewedIndex(in: g) ?? 0
        }
    }
}
