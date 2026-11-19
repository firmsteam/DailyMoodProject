//
//  RecordHomeView.swift
//  DailyMoodProject
//

import SwiftUI
import SwiftData

/// 기록 탭(①②). 오늘 기록이 있으면 ①(RecordAfterView), 없으면 ②(RecordBeforeView)를 보여 준다. (COM-01)
struct RecordHomeView: View {
    @Environment(AppRouter.self) private var router
    @Query(sort: \MoodEntry.dayKey, order: .reverse) private var entries: [MoodEntry]

    var body: some View {
        let today = DayKey.today()
        let snapshots = entries.map(\.snapshot)

        Group {
            if let todayEntry = snapshots.first(where: { $0.day == today }) {
                RecordAfterView(today: today, todayEntry: todayEntry, entries: snapshots)
            } else {
                RecordBeforeView(today: today, entries: snapshots)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // 설정 버튼은 기록 탭에만 있다. (REC-18)
            ToolbarItem(placement: .primaryAction) {
                Button("설정", systemImage: "gearshape") {
                    router.sheet = .settings
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        RecordHomeView()
    }
    .environment(AppRouter())
    .modelContainer(.preview)
}
#endif
