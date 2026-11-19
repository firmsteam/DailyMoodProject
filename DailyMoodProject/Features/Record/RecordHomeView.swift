//
//  RecordHomeView.swift
//  DailyMoodProject
//

import SwiftUI
import SwiftData

/// 기록 탭(①②). 오늘 기록이 없으면 ②를 보여 준다. (COM-01)
/// 오늘 기록이 있을 때(①)는 구현 전이라 시트와 push 연결만 확인할 수 있게 버튼을 둔다.
struct RecordHomeView: View {
    @Environment(AppRouter.self) private var router
    @Query(sort: \MoodEntry.dayKey, order: .reverse) private var entries: [MoodEntry]

    var body: some View {
        let today = DayKey.today()

        Group {
            if entries.contains(where: { $0.dayKey == today.rawValue }) {
                List {
                    Button("오늘의 감정 기록하기") {
                        router.sheet = .editor(.new(prompt: nil))
                    }
                    NavigationLink("오늘 기록 보기", value: DayKey.today())
                }
            } else {
                RecordBeforeView(today: today, entries: entries.map(\.snapshot))
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
