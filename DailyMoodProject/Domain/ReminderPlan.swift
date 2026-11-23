//
//  ReminderPlan.swift
//  DailyMoodProject
//

import Foundation

/// 매일 기록 알림을 언제 울릴지 정하는 규칙. (SET-03, SET-04)
///
/// 반복 알림은 "오늘 이미 기록했으면 보내지 않기" 같은 조건을 걸 수 없다.
/// 그래서 앞으로 며칠 치를 날짜별 알림으로 하나씩 예약하고, 상황이 바뀔 때마다 다시 예약한다.
enum ReminderPlan {
    /// 한 번에 예약하는 일수. 시스템의 대기 알림 한도(64건)보다 충분히 작다.
    static let horizonDays = 14

    /// 알림 식별자의 앞부분. 이 접두어가 붙은 알림만 이 앱이 관리한다.
    static let identifierPrefix = "daily-reminder-"

    struct Slot: Equatable {
        /// `daily-reminder-20250514` 형태.
        let identifier: String
        let fireDate: Date
    }

    /// 예약할 알림 목록.
    /// - 오늘 알림 시간이 이미 지났거나 오늘 기록이 있으면 오늘 치는 뺀다.
    /// - 내일부터는 기록 여부를 미리 알 수 없으므로 항상 넣는다.
    static func slots(
        minutesFromMidnight: Int,
        recordedToday: Bool,
        now: Date,
        calendar: Calendar = .app
    ) -> [Slot] {
        let minutes = min(max(minutesFromMidnight, 0), 24 * 60 - 1)
        let startOfToday = calendar.startOfDay(for: now)

        return (0..<horizonDays).compactMap { offset in
            guard
                let dayStart = calendar.date(byAdding: .day, value: offset, to: startOfToday),
                let fireDate = calendar.date(
                    bySettingHour: minutes / 60, minute: minutes % 60, second: 0, of: dayStart
                )
            else { return nil }

            if offset == 0, recordedToday || fireDate <= now { return nil }

            let key = DayKey(dayStart, calendar: calendar)
            return Slot(identifier: "\(identifierPrefix)\(key.rawValue)", fireDate: fireDate)
        }
    }
}
