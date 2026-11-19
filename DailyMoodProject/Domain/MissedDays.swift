//
//  MissedDays.swift
//  DailyMoodProject
//

import Foundation

/// "빠뜨린 날" 계산. 화면과 분리해 SwiftData 없이 확인할 수 있다. (ADD-02, ADD-07)
/// 빠뜨린 날은 첫 기록을 남긴 날 이후이고, 기록이 없는 지난 날이다.
enum MissedDays {
    /// 최근 순으로 정렬한 빠뜨린 날. 오늘은 넣지 않는다.
    /// 기록이 하나도 없으면 첫 기록이 없으므로 빈 배열이다.
    /// `limit`개를 채우면 거기서 멈춘다. 첫 기록이 오래전이어도 필요한 만큼만 계산한다.
    static func list(recorded: Set<DayKey>, today: DayKey, limit: Int? = nil) -> [DayKey] {
        guard let first = recorded.min() else { return [] }
        let range = EntryValidator.recordableRange(today: today)

        var result: [DayKey] = []
        var day = today.adding(days: -1)
        while day >= range.lowerBound, day > first {
            if !recorded.contains(day) {
                result.append(day)
                if let limit, result.count >= limit { break }
            }
            day = day.adding(days: -1)
        }
        return result
    }

    /// 달력 ＋를 눌렀을 때 시트가 처음 보여 줄 날. `nil`이면 오늘 기록을 수정 모드로 연다. (E-1~E-3)
    static func initialDay(recorded: Set<DayKey>, today: DayKey) -> DayKey? {
        if !recorded.contains(today) { return today }
        return list(recorded: recorded, today: today, limit: 1).first
    }

    /// 시트의 칩에 보여 줄 날. 오늘 기록 전이면 "오늘"이 맨 앞이고, 빠뜨린 날은 최대 `limit`개다. (ADD-07)
    static func chips(recorded: Set<DayKey>, today: DayKey, limit: Int = 5) -> [DayKey] {
        let missed = list(recorded: recorded, today: today, limit: limit)
        return recorded.contains(today) ? missed : [today] + missed
    }
}
