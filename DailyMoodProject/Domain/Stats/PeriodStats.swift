//
//  PeriodStats.swift
//  DailyMoodProject
//

import Foundation

/// 감정 하나의 기록 일수.
struct EmotionCount: Equatable, Identifiable, Sendable {
    let emotion: Emotion
    let days: Int

    var id: Emotion { emotion }
}

/// 기간(한 달)의 통계. 모두 `[EntrySnapshot]`을 받는 순수 함수라 SwiftData 없이 테스트할 수 있다.
enum PeriodStats {
    /// 감정별 일수를 많은 순으로 정렬한다. 일수가 같으면 점수가 높은 감정이 먼저다. (R-10, R-16)
    static func distribution(_ entries: [EntrySnapshot]) -> [EmotionCount] {
        Dictionary(grouping: entries, by: \.emotion)
            .map { EmotionCount(emotion: $0.key, days: $0.value.count) }
            .sorted { ($0.days, $0.emotion.score) > ($1.days, $1.emotion.score) }
    }

    /// 기록률(R-08)을 반올림한 정수 퍼센트. 분모가 0이면 `nil`이다.
    static func recordRate(recordedDays: Int, elapsedDays: Int) -> Int? {
        guard elapsedDays > 0 else { return nil }
        return Int((Double(recordedDays) / Double(elapsedDays) * 100).rounded())
    }
}
