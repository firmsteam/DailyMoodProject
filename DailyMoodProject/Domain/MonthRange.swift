//
//  MonthRange.swift
//  DailyMoodProject
//

import Foundation

/// 1일부터 말일까지 한 달. 월간 화면(⑥)이 보여 주는 달을 나타낸다.
struct MonthRange: Hashable, Sendable {
    /// 그 달 1일.
    let start: DayKey

    /// `day`가 속한 달.
    init(containing day: DayKey) {
        start = DayKey(rawValue: day.year * 10_000 + day.month * 100 + 1)
    }

    static func current(calendar: Calendar = .app) -> MonthRange {
        MonthRange(containing: .today(calendar: calendar))
    }

    var year: Int { start.year }
    var month: Int { start.month }

    /// 그 달의 날 수(28~31).
    func dayCount(calendar: Calendar = .app) -> Int {
        calendar.range(of: .day, in: .month, for: start.date(calendar: calendar))?.count ?? 30
    }

    var end: DayKey { DayKey(rawValue: start.rawValue + dayCount() - 1) }

    func contains(_ day: DayKey) -> Bool {
        day.year == year && day.month == month
    }

    // MARK: - 기록률의 분모

    /// 기록률(R-08)의 분모. 이번 달은 오늘까지 지난 날, 지난 달은 그 달의 전체 일수(D-05)다.
    func elapsedDays(today: DayKey = .today()) -> Int {
        if contains(today) { return today.day }
        return start > today ? 0 : dayCount()
    }

    // MARK: - 이동

    var previous: MonthRange { MonthRange(containing: start.adding(days: -1)) }
    var next: MonthRange { MonthRange(containing: end.adding(days: 1)) }

    /// 아직 오지 않은 달로는 갈 수 없다. 이번 달에서는 다음 달로 못 간다.
    func canGoNext(today: DayKey = .today()) -> Bool {
        next.start <= today
    }

    // MARK: - 표기

    /// "2025년"
    var yearText: String { "\(year)년" }

    /// "5월 요약"
    var summaryTitle: String { "\(month)월 요약" }
}
