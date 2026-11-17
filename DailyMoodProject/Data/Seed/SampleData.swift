//
//  SampleData.swift
//  DailyMoodProject
//

#if DEBUG
import Foundation
import SwiftData

/// DEBUG 전용 샘플. 시안(`shared/data.js`)의 2025년 5월 12건과 같은 내용이다.
/// 미리보기와 단위 테스트가 같은 데이터를 쓰도록 이 파일을 원본으로 둔다.
enum SampleData {
    /// 시안에서 "오늘"로 쓰는 날.
    static let today = DayKey(rawValue: 20250514)

    private static let rows: [(day: Int, emotion: Emotion, text: String)] = [
        (1, .joy, "연휴 첫날, 늦잠 자고 커피 한 잔"),
        (2, .calm, "산책하다 만난 노을이 예뻤다"),
        (3, .love, "가족이랑 먹은 저녁이 따뜻했다"),
        (5, .excited, "어린이날 놀이공원 다녀옴!"),
        (6, .tired, "연휴 끝, 몸이 무겁다"),
        (7, .anxious, "발표 준비가 아직 막막하다"),
        (8, .joy, "발표 생각보다 잘 끝났다"),
        (9, .calm, "퇴근길 플레이리스트가 완벽했다"),
        (11, .calm, "일요일 오후, 책 읽으며 쉬었다"),
        (12, .angry, "회의가 세 번이나 길어졌다"),
        (13, .calm, "비 오는 날, 따뜻한 차 한 잔"),
        (14, .joy, "오랜만에 운동하고 개운해졌다"),
    ]

    /// 날짜 오름차순 12건. 기록 시각은 그날 밤 9시, 수정한 기록은 없다.
    static let entries: [EntrySnapshot] = rows.map { row in
        let day = DayKey(rawValue: 20250500 + row.day)
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
