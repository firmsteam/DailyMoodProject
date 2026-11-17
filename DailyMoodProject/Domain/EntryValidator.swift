//
//  EntryValidator.swift
//  DailyMoodProject
//

import Foundation

/// 저장 조건. (R-03, R-06)
enum EntryValidator {
    static let maxLength = 40

    /// 앞뒤 공백을 지우고 최대 글자 수까지만 남긴다.
    static func normalized(_ text: String) -> String {
        String(text.trimmingCharacters(in: .whitespacesAndNewlines).prefix(maxLength))
    }

    /// 감정을 골랐고 한 줄이 비어 있지 않아야 저장할 수 있다. 공백만 입력하면 빈 것으로 본다.
    static func canSave(emotion: Emotion?, text: String) -> Bool {
        emotion != nil && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
