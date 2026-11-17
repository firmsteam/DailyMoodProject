//
//  AppCalendar.swift
//  DailyMoodProject
//

import Foundation

extension Calendar {
    /// 앱 전체에서 쓰는 달력. 한 주는 일요일부터 시작한다. (R-13)
    /// 기기의 지역 설정과 관계없이 고정한다.
    static let app: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.firstWeekday = 1
        calendar.timeZone = .autoupdatingCurrent
        return calendar
    }()
}
