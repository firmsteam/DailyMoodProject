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

    /// 테스트용 한 달치(30건). `today` 기준으로 2025년 4월 15일부터 5월 14일까지 매일 한 건씩 있다.
    private static let monthRows: [(day: Int, emotion: Emotion, text: String)] = [
        (20250415, .calm, "봄바람이 좋아서 점심 산책을 했다"),
        (20250416, .tired, "야근 때문에 몸이 무겁다"),
        (20250417, .anxious, "내일 면담이 신경 쓰인다"),
        (20250418, .joy, "면담이 잘 끝나서 마음이 가볍다"),
        (20250419, .love, "친구들과 오랜만에 브런치"),
        (20250420, .calm, "일요일, 집에서 푹 쉬었다"),
        (20250421, .angry, "약속이 갑자기 취소돼서 화가 났다"),
        (20250422, .sad, "비가 와서 괜히 가라앉는 하루"),
        (20250423, .calm, "따뜻한 차를 마시며 책을 읽었다"),
        (20250424, .excited, "여행 계획을 세우는 중이라 설렌다"),
        (20250425, .joy, "금요일! 퇴근하고 맛집에 갔다"),
        (20250426, .love, "가족과 함께 꽃구경을 다녀왔다"),
        (20250427, .tired, "주말 내내 돌아다녀서 피곤하다"),
        (20250428, .anxious, "한 주의 일정이 빽빽해서 걱정된다"),
        (20250429, .calm, "점심시간에 잠깐 햇볕을 쬈다"),
        (20250430, .joy, "월말 정리를 끝내서 후련했다"),
        (20250501, .joy, "연휴 첫날, 늦잠 자고 커피 한 잔"),
        (20250502, .calm, "산책하다 만난 노을이 예뻤다"),
        (20250503, .love, "가족이랑 먹은 저녁이 따뜻했다"),
        (20250504, .sad, "친한 친구가 이사를 간다고 했다"),
        (20250505, .excited, "어린이날 놀이공원 다녀옴!"),
        (20250506, .tired, "연휴 끝, 몸이 무겁다"),
        (20250507, .anxious, "발표 준비가 아직 막막하다"),
        (20250508, .joy, "발표 생각보다 잘 끝났다"),
        (20250509, .calm, "퇴근길 플레이리스트가 완벽했다"),
        (20250510, .excited, "새로 산 운동화를 신고 달렸다"),
        (20250511, .calm, "일요일 오후, 책 읽으며 쉬었다"),
        (20250512, .angry, "회의가 세 번이나 길어졌다"),
        (20250513, .calm, "비 오는 날, 따뜻한 차 한 잔"),
        (20250514, .joy, "오랜만에 운동하고 개운해졌다"),
    ]

    /// 한 달치 테스트 기록. 날짜 오름차순, 기록 시각은 그날 밤 9시.
    static let monthEntries: [EntrySnapshot] = monthRows.map { row in
        let day = DayKey(rawValue: row.day)
        let createdAt = Calendar.app.date(bySettingHour: 21, minute: 0, second: 0, of: day.date()) ?? day.date()
        return EntrySnapshot(day: day, emotion: row.emotion, text: row.text, createdAt: createdAt, modifiedAt: nil)
    }

    /// 샘플을 저장소에 넣는다. 같은 날 기록이 이미 있으면 건너뛰어 "하루 한 건"을 지킨다.
    /// 기본값은 시안과 같은 12건이고, `monthEntries`를 넘기면 한 달치가 들어간다.
    @MainActor
    static func insert(into context: ModelContext, entries: [EntrySnapshot] = SampleData.entries) throws {
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
