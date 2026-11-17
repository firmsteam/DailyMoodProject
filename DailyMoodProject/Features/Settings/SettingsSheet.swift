//
//  SettingsSheet.swift
//  DailyMoodProject
//

import SwiftUI

/// 설정(⑧). 기록 탭의 ⚙ 버튼에서만 열린다.
/// 화면 구현 전까지 쓰는 자리표시 뷰.
struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ContentUnavailableView("설정", systemImage: "gearshape", description: Text("준비 중이에요"))
                .navigationTitle("설정")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("완료") { dismiss() }
                    }
                }
        }
    }
}

#Preview {
    SettingsSheet()
}
