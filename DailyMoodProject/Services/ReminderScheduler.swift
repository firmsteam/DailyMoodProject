//
//  ReminderScheduler.swift
//  DailyMoodProject
//

import SwiftUI
import UserNotifications

/// 매일 기록 알림 예약. 알림은 실기기와 시스템 권한에 기대므로
/// 프로토콜로 두고 환경(Environment)으로 주입해 테스트와 미리보기에서 바꿔 끼울 수 있게 한다.
protocol ReminderScheduling: Sendable {
    /// 알림을 보낼 권한이 있는지.
    func isAuthorized() async -> Bool

    /// 권한을 요청한다. 처음 한 번만 시스템 권한 창이 뜨고, 이미 정해졌다면 창 없이 현재 결과를 돌려준다.
    func requestAuthorization() async -> Bool

    /// 이 앱의 기존 알림 예약을 모두 지우고, `enabled`가 켜져 있으면 규칙(`ReminderPlan`)대로 다시 예약한다.
    func reschedule(enabled: Bool, minutesFromMidnight: Int, recordedToday: Bool, now: Date) async
}

struct SystemReminderScheduler: ReminderScheduling {
    private var center: UNUserNotificationCenter { .current() }

    func isAuthorized() async -> Bool {
        switch await center.notificationSettings().authorizationStatus {
        case .authorized, .provisional, .ephemeral: true
        case .notDetermined, .denied: false
        @unknown default: false
        }
    }

    func requestAuthorization() async -> Bool {
        let granted = try? await center.requestAuthorization(options: [.alert, .sound])
        return granted ?? false
    }

    func reschedule(enabled: Bool, minutesFromMidnight: Int, recordedToday: Bool, now: Date) async {
        let pending = await center.pendingNotificationRequests()
        let staleIDs = pending.map(\.identifier).filter { $0.hasPrefix(ReminderPlan.identifierPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: staleIDs)

        guard enabled else { return }

        let content = UNMutableNotificationContent()
        content.body = "오늘의 감정을 기록하세요"
        content.sound = .default

        let slots = ReminderPlan.slots(
            minutesFromMidnight: minutesFromMidnight, recordedToday: recordedToday, now: now
        )
        for slot in slots {
            let components = Calendar.app.dateComponents(
                [.year, .month, .day, .hour, .minute], from: slot.fireDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: slot.identifier, content: content, trigger: trigger)
            try? await center.add(request)
        }
    }
}

extension EnvironmentValues {
    @Entry var reminderScheduler: any ReminderScheduling = SystemReminderScheduler()
}
