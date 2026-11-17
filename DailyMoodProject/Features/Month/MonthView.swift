//
//  MonthView.swift
//  DailyMoodProject
//

import SwiftUI

/// 월간 탭(⑥). 화면 구현 전까지 쓰는 자리표시 뷰.
struct MonthView: View {
    var body: some View {
        ContentUnavailableView("월간", systemImage: "chart.pie", description: Text("준비 중이에요"))
            .navigationTitle("월간")
    }
}

#Preview {
    NavigationStack {
        MonthView()
    }
}
