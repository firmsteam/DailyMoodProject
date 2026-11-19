//
//  EntryValidator.swift
//  DailyMoodProject
//

import Foundation

/// 저장 조건. (R-03, R-06, R-05)
enum EntryValidator {
    static let maxLength = 40

    /// 작은 달력이 거슬러 올라갈 수 있는 가장 이른 날. 기록 가능 기간을 사실상 제한하지 않되, 달력이 끝없이 이어지지 않게 하는 하한이다.
    static let earliestDay = DayKey(rawValue: 2000_01_01)

    /// 기록할 수 있는 날의 범위. 지난 모든 날과 오늘이고, 미래 날짜는 없다. (R-05, R-14, ADD-09)
    static func recordableRange(today: DayKey) -> ClosedRange<DayKey> {
        earliestDay...today
    }

    /// 새 기록을 남길 수 있는 날인지. 이미 기록이 있는 날인지는 `EntryStore`가 따로 확인한다.
    static func isRecordable(_ day: DayKey, today: DayKey) -> Bool {
        recordableRange(today: today).contains(day)
    }

    /// 이미 있는 기록을 수정할 수 있는 날인지. 오늘 기록만 수정할 수 있고, 지난 날 기록은 수정할 수 없다.
    static func isEditable(_ day: DayKey, today: DayKey) -> Bool {
        day == today
    }

    /// 앞뒤 공백을 지우고 최대 글자 수까지만 남긴다.
    static func normalized(_ text: String) -> String {
        String(text.trimmingCharacters(in: .whitespacesAndNewlines).prefix(maxLength))
    }

    /// 감정을 골랐고 한 줄이 비어 있지 않아야 저장할 수 있다. 공백만 입력하면 빈 것으로 본다.
    static func canSave(emotion: Emotion?, text: String) -> Bool {
        emotion != nil && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
