//
//  CalendarMonth.swift
//  DailyMoodProject
//

import Foundation

extension DayKey {
    /// 이 날이 속한 달의 1일.
    var firstOfMonth: DayKey {
        DayKey(rawValue: year * 10_000 + month * 100 + 1)
    }

    /// `months`개월 뒤(음수면 앞)의 달의 1일.
    func firstOfMonth(adding months: Int, calendar: Calendar = .app) -> DayKey {
        let base = firstOfMonth.date(calendar: calendar)
        let moved = calendar.date(byAdding: .month, value: months, to: base) ?? base
        return DayKey(moved, calendar: calendar).firstOfMonth
    }
}

/// 달력 격자 계산. 화면과 분리해 두어 SwiftData 없이 확인할 수 있다.
enum CalendarGrid {
    /// 한 달을 일요일부터 시작하는 주 단위로 나눈다. 1일 앞과 말일 뒤의 빈 칸은 `nil`이다. (R-13)
    static func weeks(of month: DayKey, calendar: Calendar = .app) -> [[DayKey?]] {
        let first = month.firstOfMonth
        let dayCount = calendar.range(of: .day, in: .month, for: first.date(calendar: calendar))?.count ?? 30
        let weekday = calendar.component(.weekday, from: first.date(calendar: calendar))
        let leadingBlanks = (weekday - calendar.firstWeekday + 7) % 7

        var cells: [DayKey?] = Array(repeating: nil, count: leadingBlanks)
        cells += (0..<dayCount).map { DayKey(rawValue: first.rawValue + $0) }
        while !cells.count.isMultiple(of: 7) { cells.append(nil) }

        return stride(from: 0, to: cells.count, by: 7).map { Array(cells[$0..<$0 + 7]) }
    }
}
