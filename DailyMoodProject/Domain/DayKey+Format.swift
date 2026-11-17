//
//  DayKey+Format.swift
//  DailyMoodProject
//

import Foundation

/// 날짜 표기. 문자열을 직접 이어 붙이지 않고 서식(FormatStyle)을 써서
/// 한국어 어순을 시스템이 맞추게 한다.
extension DayKey {
    private static let locale = Locale(identifier: "ko_KR")

    /// 5월 14일 수요일
    var formattedFull: String {
        date().formatted(.dateTime.month().day().weekday(.wide).locale(Self.locale))
    }

    /// 5월 14일
    var formattedMonthDay: String {
        date().formatted(.dateTime.month().day().locale(Self.locale))
    }

    /// 2025년 5월
    var formattedYearMonth: String {
        date().formatted(.dateTime.year().month().locale(Self.locale))
    }
}
