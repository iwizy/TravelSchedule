//
//  StoriesMocks.swift
//  TravelSchedule
//
//  Mocks for stories

import Foundation

enum StoriesMocks {
    static let groups: [StoryGroup] = {
        func medias(_ names: [String], title: String, prefix: String? = nil) -> [StoryMedia] {
            names.enumerated().map { idx, name in
                let xOfYKey = "stories.slide_x_of_y"
                let xOfYTemplate = Bundle.main.localizedString(forKey: xOfYKey,
                                                               value: "%1$d из %2$d",
                                                               table: nil)
                let localizedXofY = String(format: xOfYTemplate, idx + 1, names.count)
                let localizedPrefix = prefix.map {
                    Bundle.main.localizedString(forKey: $0, value: $0, table: nil)
                }
                
                let subtitle = localizedPrefix.map { "\($0) \(localizedXofY)" }

                return StoryMedia(
                    imageName: name,
                    title: title,
                    subtitle: subtitle,
                    duration: 6
                )
            }
        }

        return [
            StoryGroup(
                title: "stories.first",
                avatar: "item1",
                items: medias(["item1", "item2", "item3"], title: "stories.first", prefix: "stories.slide_prefix")
            ),
            StoryGroup(
                title: "stories.second",
                avatar: "item2",
                items: medias(["item2", "item3", "item4"], title: "stories.second", prefix: "stories.slide_prefix")
            ),
            StoryGroup(
                title: "stories.third",
                avatar: "item3",
                items: medias(["item3", "item4", "item5"], title: "stories.third", prefix: "stories.slide_prefix")
            ),
            StoryGroup(
                title: "stories.fourth",
                avatar: "item4",
                items: medias(["item4", "item5", "item1"], title: "stories.fourth", prefix: "stories.slide_prefix")
            ),
            StoryGroup(
                title: "stories.fifth",
                avatar: "item5",
                items: medias(["item5", "item1", "item2"], title: "stories.fifth", prefix: "stories.slide_prefix")
            )
        ]
    }()
}
