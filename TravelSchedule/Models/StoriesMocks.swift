//
//  StoriesMocks.swift
//  TravelSchedule
//
//  Моки для сториз

import Foundation

enum StoriesMocks {
    static let groups: [StoryGroup] = {
        func medias(_ names: [String], title: String, prefix: String? = nil) -> [StoryMedia] {
            names.enumerated().map { idx, name in
                StoryMedia(
                    imageName: name,
                    title: title,
                    subtitle: prefix != nil ? "\(prefix!) \(idx + 1) из \(names.count)" : nil,
                    duration: 6
                )
            }
        }
        
        return [
            StoryGroup(
                title: "Осенние маршруты",
                avatar: "item1",
                items: medias(["item1", "item2", "item3"], title: "Осенние маршруты", prefix: "Слайд")
            ),
            StoryGroup(
                title: "Где встретить рассвет",
                avatar: "item2",
                items: medias(["item2", "item3", "item4"], title: "Где встретить рассвет", prefix: "Слайд")
            ),
            StoryGroup(
                title: "Weekend-побеги",
                avatar: "item3",
                items: medias(["item3", "item4", "item5"], title: "Weekend-побеги", prefix: "Слайд")
            ),
            StoryGroup(
                title: "Новые направления",
                avatar: "item4",
                items: medias(["item4", "item5", "item1"], title: "Новые направления", prefix: "Слайд")
            ),
            StoryGroup(
                title: "Поезда мечты",
                avatar: "item5",
                items: medias(["item5", "item1", "item2"], title: "Поезда мечты", prefix: "Слайд")
            )
        ]
    }()
}
