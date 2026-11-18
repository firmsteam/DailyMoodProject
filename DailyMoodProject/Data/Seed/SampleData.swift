//
//  SampleData.swift
//  DailyMoodProject
//

#if DEBUG
import Foundation
import SwiftData

enum SampleData {
    /// 샘플의 기준일(시안의 "오늘", 14일). 실제 어제 날짜다.
    static let today = DayKey.today().adding(days: -1)

    /// `offset`은 기준일로부터의 날수다. 0이 기준일(어제), -13이 13일 전이다.
    private static let rows: [(offset: Int, emotion: Emotion, text: String)] = [
        (-13, .joy, "연휴 첫날, 늦잠 자고 커피 한 잔"),
        (-12, .calm, "산책하다 만난 노을이 예뻤다"),
        (-11, .love, "가족이랑 먹은 저녁이 따뜻했다"),
        (-9, .excited, "어린이날 놀이공원 다녀옴!"),
        (-8, .tired, "연휴 끝, 몸이 무겁다"),
        (-7, .anxious, "발표 준비가 아직 막막하다"),
        (-6, .joy, "발표 생각보다 잘 끝났다"),
        (-5, .calm, "퇴근길 플레이리스트가 완벽했다"),
        (-3, .calm, "일요일 오후, 책 읽으며 쉬었다"),
        (-2, .angry, "회의가 세 번이나 길어졌다"),
        (-1, .calm, "비 오는 날, 따뜻한 차 한 잔"),
        (0, .joy, "오랜만에 운동하고 개운해졌다"),
    ]

    /// 날짜 오름차순 12건. 기록 시각은 그날 밤 9시, 수정한 기록은 없다.
    static let entries: [EntrySnapshot] = rows.map { row in
        let day = today.adding(days: row.offset)
        let createdAt = Calendar.app.date(bySettingHour: 21, minute: 0, second: 0, of: day.date()) ?? day.date()
        return EntrySnapshot(day: day, emotion: row.emotion, text: row.text, createdAt: createdAt, modifiedAt: nil)
    }

    /// 샘플을 저장소에 넣는다. 같은 날 기록이 이미 있으면 건너뛰어 "하루 한 건"을 지킨다.
    @MainActor
    static func insert(into context: ModelContext) throws {
        let store = EntryStore(context: context)
        for entry in entries where try store.entry(on: entry.day) == nil {
            context.insert(
                MoodEntry(day: entry.day, emotion: entry.emotion, text: entry.text, createdAt: entry.createdAt)
            )
        }
        try context.save()
    }
}
#endif
