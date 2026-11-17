//
//  DayKey.swift
//  DailyMoodProject
//

import Foundation

/// 달력상의 하루를 `20250514` 같은 정수로 나타낸다.
/// 시간대가 바뀌어도 "5월 14일 기록"이 5월 14일로 남도록 `Date` 대신 쓴다.
struct DayKey: Hashable, Comparable, Codable, Sendable {
    let rawValue: Int

    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    init(_ date: Date, calendar: Calendar = .app) {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        rawValue = (c.year ?? 0) * 10_000 + (c.month ?? 0) * 100 + (c.day ?? 0)
    }

    static func today(calendar: Calendar = .app) -> DayKey {
        DayKey(.now, calendar: calendar)
    }

    var year: Int { rawValue / 10_000 }
    var month: Int { rawValue / 100 % 100 }
    var day: Int { rawValue % 100 }

    func date(calendar: Calendar = .app) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? .distantPast
    }

    func adding(days: Int, calendar: Calendar = .app) -> DayKey {
        let base = date(calendar: calendar)
        let moved = calendar.date(byAdding: .day, value: days, to: base) ?? base
        return DayKey(moved, calendar: calendar)
    }

    static func < (lhs: DayKey, rhs: DayKey) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
