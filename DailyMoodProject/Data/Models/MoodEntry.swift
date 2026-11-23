//
//  MoodEntry.swift
//  DailyMoodProject
//

import Foundation
import SwiftData

/// 하루 한 건의 감정 기록. 앱에서 유일한 저장 모델이다.
/// 이후 iCloud 동기화를 붙일 때 구조를 바꾸지 않도록 모든 속성에 기본값을 두고,
/// 수정 시각은 옵셔널로 둔다. "하루 한 건"은 `EntryStore`가 지킨다.
@Model
final class MoodEntry {
    var id: UUID = UUID()
    /// 기록한 날(`20250514`).
    var dayKey: Int = 0
    /// `Emotion.rawValue`.
    var emotionRaw: String = Emotion.joy.rawValue
    /// 한 줄(최대 40자).
    var text: String = ""
    /// 처음 저장한 시각. 수정해도 바뀌지 않는다. (R-04)
    var createdAt: Date = Date.now
    /// 수정한 시각. 수정한 적이 없으면 `nil`. (R-04)
    var modifiedAt: Date?

    init(day: DayKey, emotion: Emotion, text: String, createdAt: Date = .now) {
        self.dayKey = day.rawValue
        self.emotionRaw = emotion.rawValue
        self.text = text
        self.createdAt = createdAt
    }

    var day: DayKey { DayKey(rawValue: dayKey) }
    var emotion: Emotion { Emotion(rawValue: emotionRaw) ?? .joy }

    var snapshot: EntrySnapshot {
        EntrySnapshot(day: day, emotion: emotion, text: text, createdAt: createdAt, modifiedAt: modifiedAt)
    }
}
