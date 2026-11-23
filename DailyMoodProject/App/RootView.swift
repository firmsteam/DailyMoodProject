//
//  RootView.swift
//  DailyMoodProject
//

import SwiftUI
import SwiftData

/// 탭 4개와 앱 최상위 시트를 연결하는 루트 화면.
struct RootView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            Tab("기록", systemImage: "book.closed", value: AppTab.record) {
                tabStack { RecordHomeView() }
            }
            Tab("달력", systemImage: "calendar", value: AppTab.calendar) {
                tabStack { CalendarView() }
            }
            Tab("주간", systemImage: "list.bullet", value: AppTab.week) {
                tabStack { WeekView() }
            }
            Tab("월간", systemImage: "chart.pie", value: AppTab.month) {
                tabStack { MonthView() }
            }
        }
        .tint(.indigo)      // 앱 강조색은 디자인 시스템의 인디고
        .sheet(item: $router.sheet) { sheet in
            switch sheet {
            case .editor(let mode):
                EntryEditorSheet(mode: mode)
            case .settings:
                SettingsSheet()
            }
        }
    }

    /// 탭마다 `NavigationStack`을 따로 둔다. 탭을 옮겨도 쌓인 화면과 스크롤 위치가 유지된다. (COM-02)
    /// 모든 탭에서 `DayKey`로 기록 관리(⑦)에 push할 수 있다.
    private func tabStack<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        NavigationStack {
            content()
                .navigationDestination(for: DayKey.self) { day in
                    EntryDetailView(day: day)
                }
        }
    }
}

#Preview {
    RootView()
        .environment(AppRouter())
        .modelContainer(try! AppContainer.make(inMemory: true))
}
