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

    /// 기록한 날과 저장한 날이 다르면 "나중에 기록"이다. 따로 저장하는 값은 없고 두 날짜를 비교해서 계산한다. (ADD-13)
    var isRecordedLater: Bool { DayKey(createdAt) != day }
}
