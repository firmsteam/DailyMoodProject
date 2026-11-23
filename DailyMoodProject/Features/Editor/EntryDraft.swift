//
//  EntryDraft.swift
//  DailyMoodProject
//

import Foundation

/// 감정 기록 시트에서 입력 중인 값. 저장하기 전까지는 이 값만 바뀌고 저장소는 건드리지 않는다.
struct EntryDraft: Equatable {
    /// 기록할 날. 새 기록은 시트를 연 시점의 오늘로 고정하고, 수정은 그 기록의 날짜다. (R-05)
    let day: DayKey
    var emotion: Emotion?
    var text: String

    private let isNew: Bool
    private let initialEmotion: Emotion?
    private let initialText: String

    /// 새 기록. 감정과 한 줄이 모두 비어 있다.
    init(newOn day: DayKey) {
        self.day = day
        self.emotion = nil
        self.text = ""
        self.isNew = true
        self.initialEmotion = nil
        self.initialText = ""
    }

    /// 기존 기록 수정. 처음 값을 기억해 두었다가 바뀌었는지 비교한다.
    init(editing entry: EntrySnapshot) {
        self.day = entry.day
        self.emotion = entry.emotion
        self.text = entry.text
        self.isNew = false
        self.initialEmotion = entry.emotion
        self.initialText = entry.text
    }

    /// 닫을 때 버릴지 물어야 하는지. (SHT-02)
    /// 새 기록은 한 줄에 입력한 내용이 있을 때만 묻는다. 감정만 골랐다면 묻지 않는다.
    /// 수정은 감정이나 한 줄을 처음 값에서 바꿨을 때만 묻는다.
    var hasUnsavedChanges: Bool {
        if isNew {
            return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return emotion != initialEmotion || text != initialText
    }

    /// 저장할 수 있는지. (SHT-03, R-06)
    var canSave: Bool {
        EntryValidator.canSave(emotion: emotion, text: text)
    }
}
