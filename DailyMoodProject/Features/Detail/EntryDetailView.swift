//
//  EntryDetailView.swift
//  DailyMoodProject
//

import SwiftUI

/// 기록 관리(⑦). 모델 객체가 아니라 `DayKey`를 받아서, 삭제된 기록을 가리키는 일이 없게 한다.
/// 화면 구현 전까지 쓰는 자리표시 뷰.
struct EntryDetailView: View {
    let day: DayKey

    var body: some View {
        ContentUnavailableView("기록 관리", systemImage: "tray", description: Text("준비 중이에요"))
            .navigationTitle("\(day.month)월 \(day.day)일")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        EntryDetailView(day: .today())
    }
}
