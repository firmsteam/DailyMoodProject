//
//  WeekRange.swift
//  DailyMoodProject
//

import Foundation

/// 일요일부터 토요일까지 7일. 주간 화면(⑤)이 보여 주는 한 주를 나타낸다.
struct WeekRange: Hashable, Sendable {
    /// 그 주의 일요일.
    let start: DayKey

    /// `day`가 속한 주.
    init(containing day: DayKey, calendar: Calendar = .app) {
        let weekday = calendar.component(.weekday, from: day.date(calendar: calendar))
        let offset = (weekday - calendar.firstWeekday + 7) % 7
        start = day.adding(days: -offset, calendar: calendar)
    }

    static func current(calendar: Calendar = .app) -> WeekRange {
        WeekRange(containing: .today(calendar: calendar), calendar: calendar)
    }

    private init(start: DayKey) {
        self.start = start
    }

    /// 일요일부터 토요일까지.
    var days: [DayKey] {
        (0..<7).map { start.adding(days: $0) }
    }

    var end: DayKey { start.adding(days: 6) }

    var previous: WeekRange { WeekRange(start: start.adding(days: -7)) }
    var next: WeekRange { WeekRange(start: start.adding(days: 7)) }

    func contains(_ day: DayKey) -> Bool {
        day >= start && day <= end
    }

    // MARK: - 몇째 주

    /// 두 달에 걸친 주는 목요일이 속한 달의 주로 센다.
    /// 7일 중 4일 이상이 들어 있는 달이 그 주의 달이 되고, 모든 주가 정확히 한 달에만 속한다.
    private var anchor: DayKey { start.adding(days: 4) }

    /// 이 주가 속한 달(1~12).
    var month: Int { anchor.month }

    /// 속한 달 안에서 몇째 주인지(1~5). 그 달의 첫 목요일이 든 주가 1째 주다.
    var weekOfMonth: Int { (anchor.day - 1) / 7 + 1 }

    // MARK: - 표기

    /// 이번 주, 저번 주, 그보다 이전은 "5월 1째 주".
    func title(today: DayKey = .today()) -> String {
        let current = WeekRange(containing: today)
        if self == current { return "이번 주" }
        if self == current.previous { return "저번 주" }
        return "\(month)월 \(weekOfMonth)째 주"
    }

    /// "5월 11일 – 17일". 달이 바뀌는 주는 "4월 27일 – 5월 3일".
    var rangeText: String {
        let last = end.month == start.month ? "\(end.day)일" : "\(end.month)월 \(end.day)일"
        return "\(start.month)월 \(start.day)일 – \(last)"
    }

    // MARK: - 이동

    /// 아직 오지 않은 주로는 갈 수 없다. 이번 주에서는 다음 주로 못 간다.
    func canGoNext(today: DayKey = .today()) -> Bool {
        next.start <= today
    }
}
