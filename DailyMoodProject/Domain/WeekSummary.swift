//
//  WeekSummary.swift
//  DailyMoodProject
//

import Foundation

/// 한 주의 대표 감정. 가장 많았던 감정과 그 일수, 기록한 전체 일수를 담는다.
struct WeekSummary: Hashable, Sendable {
    let emotion: Emotion
    /// 대표 감정으로 기록한 날 수.
    let count: Int
    /// 그 주에 기록한 날 수. "4일 중 2일"의 앞의 수.
    let recordedDays: Int

    /// 기록이 없으면 `nil`. 일수가 같으면 `Emotion.score`가 높은 감정을 고른다. (R-16)
    init?(entries: [EntrySnapshot]) {
        guard !entries.isEmpty else { return nil }
        let counts = Dictionary(grouping: entries, by: \.emotion).mapValues(\.count)
        guard let top = counts.max(by: { lhs, rhs in
            lhs.value != rhs.value ? lhs.value < rhs.value : lhs.key.score < rhs.key.score
        }) else { return nil }
        emotion = top.key
        count = top.value
        recordedDays = entries.count
    }
}
