//
//  EntrySnapshot.swift
//  DailyMoodProject
//

import Foundation

/// `MoodEntry`의 값 타입 복사본. 통계 계산과 테스트는 SwiftData와 분리해 이 타입으로 한다.
struct EntrySnapshot: Hashable, Sendable, Identifiable {
    let day: DayKey
    let emotion: Emotion
    let text: String
    let createdAt: Date
    let modifiedAt: Date?

    var id: DayKey { day }
}
