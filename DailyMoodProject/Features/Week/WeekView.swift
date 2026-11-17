//
//  WeekView.swift
//  DailyMoodProject
//

import SwiftUI

/// 주간 탭(⑤). 화면 구현 전까지 쓰는 자리표시 뷰.
struct WeekView: View {
    var body: some View {
        ContentUnavailableView("주간", systemImage: "list.bullet", description: Text("준비 중이에요"))
            .navigationTitle("주간")
    }
}

#Preview {
    NavigationStack {
        WeekView()
    }
}
