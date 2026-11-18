//
//  ReminderSync.swift
//  DailyMoodProject
//

import SwiftUI
import SwiftData

/// 알림 예약을 현재 상태와 맞춰 둔다. (SET-03, SET-04, COM-07)
/// 아래 값이 바뀌거나 앱이 `active`가 될 때마다 예약을 다시 한다.
/// - 알림 켬/끔, 알림 시간
/// - 가장 최근 기록의 날짜. 오늘 기록의 저장, 삭제, 전체 삭제가 여기에 드러난다.
struct ReminderSync: ViewModifier {
    @Environment(\.reminderScheduler) private var scheduler
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage(SettingsKey.reminderEnabled) private var enabled = false
    @AppStorage(SettingsKey.reminderMinutes) private var minutes = SettingsDefault.reminderMinutes

    @Query(ReminderSync.latestEntry) private var latest: [MoodEntry]

    private static var latestEntry: FetchDescriptor<MoodEntry> {
        var descriptor = FetchDescriptor<MoodEntry>(sortBy: [SortDescriptor(\.dayKey, order: .reverse)])
        descriptor.fetchLimit = 1
        return descriptor
    }

    private struct Trigger: Equatable {
        let enabled: Bool
        let minutes: Int
        let latestDay: Int?
        let isActive: Bool
    }

    func body(content: Content) -> some View {
        content.task(id: Trigger(
            enabled: enabled,
            minutes: minutes,
            latestDay: latest.first?.dayKey,
            isActive: scenePhase == .active
        )) {
            guard scenePhase == .active else { return }
            await refresh()
        }
    }

    private func refresh() async {
        // 설정 앱에서 알림 권한을 끈 경우: 켜져 있는 것처럼 보이지 않게 토글을 끈다.
        // 값이 바뀌면 이 작업이 다시 돌면서 남은 예약도 지운다.
        if enabled, await !scheduler.isAuthorized() {
            enabled = false
            return
        }

        let recordedToday = latest.first?.dayKey == DayKey.today().rawValue
        await scheduler.reschedule(
            enabled: enabled,
            minutesFromMidnight: minutes,
            recordedToday: recordedToday,
            now: .now
        )
    }
}

extension View {
    /// 앱 최상위 뷰에 한 번만 붙인다. `modelContainer`보다 안쪽에서 써야 기록을 읽을 수 있다.
    func syncReminders() -> some View {
        modifier(ReminderSync())
    }
}
