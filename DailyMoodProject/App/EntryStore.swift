//
//  EntryStore.swift
//  DailyMoodProject
//

import Foundation
import SwiftData

/// 지난 날 기록을 추가할 수 없는 이유.
enum EntryStoreError: Error {
    /// 그 날에 이미 기록이 있다. 다른 경로(동기화 등)로 먼저 기록된 경우도 여기에 해당한다.
    case alreadyRecorded
    /// 미래 날짜이거나 기록할 수 있는 가장 이른 날(`EntryValidator.earliestDay`)보다 앞이다.
    case outOfRange
}

/// 기록의 저장·수정·삭제를 맡는다. "하루 한 건"(R-02)은 여기서 지킨다.
@MainActor
struct EntryStore {
    let context: ModelContext

    func entry(on day: DayKey) throws -> MoodEntry? {
        let key = day.rawValue
        var descriptor = FetchDescriptor<MoodEntry>(predicate: #Predicate { $0.dayKey == key })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    /// 새 기록을 만들거나, 같은 날 기록이 있으면 그 기록을 수정한다.
    /// 입력 조건(`EntryValidator.canSave`)은 호출하는 쪽에서 먼저 확인한다.
    @discardableResult
    func save(day: DayKey, emotion: Emotion, text: String, now: Date = .now) throws -> MoodEntry {
        let normalized = EntryValidator.normalized(text)

        if let existing = try entry(on: day) {
            // 바뀐 것이 있을 때만 수정 시각을 갱신한다. 기록 시각(createdAt)은 그대로 둔다. (R-04, D-06)
            if existing.emotion != emotion || existing.text != normalized {
                existing.emotionRaw = emotion.rawValue
                existing.text = normalized
                existing.modifiedAt = now
                try context.save()
            }
            return existing
        }

        let entry = MoodEntry(day: day, emotion: emotion, text: normalized, createdAt: now)
        context.insert(entry)
        try context.save()
        return entry
    }

    /// 기록이 없는 날에만 새 기록을 더한다. `save`와 달리 같은 날 기록이 있으면 덮어쓰지 않고 실패한다.
    /// 기록 가능 기간은 저장하는 순간의 `today`로 다시 확인한다. (R-05, ADD-09)
    @discardableResult
    func add(day: DayKey, emotion: Emotion, text: String, today: DayKey? = nil, now: Date = .now) throws -> MoodEntry {
        guard EntryValidator.isRecordable(day, today: today ?? .today()) else { throw EntryStoreError.outOfRange }
        guard try entry(on: day) == nil else { throw EntryStoreError.alreadyRecorded }
        return try save(day: day, emotion: emotion, text: text, now: now)
    }

    func delete(day: DayKey) throws {
        guard let entry = try entry(on: day) else { return }
        context.delete(entry)
        try context.save()
    }

    func deleteAll() throws {
        try context.delete(model: MoodEntry.self)
        try context.save()
    }
}
