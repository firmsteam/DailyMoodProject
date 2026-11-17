//
//  CalendarView.swift
//  DailyMoodProject
//

import SwiftUI

/// 달력 탭(④). 화면 구현 전까지 쓰는 자리표시 뷰.
struct CalendarView: View {
    var body: some View {
        ContentUnavailableView("달력", systemImage: "calendar", description: Text("준비 중이에요"))
            .navigationTitle("달력")
    }
}

#Preview {
    NavigationStack {
        CalendarView()
    }
}
