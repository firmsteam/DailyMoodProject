//
//  EntryEditorSheet.swift
//  DailyMoodProject
//

import SwiftUI

/// 감정 기록 시트(③). 새 기록, 수정, 질문으로 진입하는 세 경우를 `mode`로 구분한다.
/// 화면 구현 전까지 쓰는 자리표시 뷰.
struct EntryEditorSheet: View {
    let mode: EditorMode
    @Environment(\.dismiss) private var dismiss

    private var isEditing: Bool {
        if case .edit = mode { true } else { false }
    }

    var body: some View {
        NavigationStack {
            ContentUnavailableView("감정 기록", systemImage: "face.smiling", description: Text("준비 중이에요"))
                .navigationTitle(isEditing ? "기록 수정" : "오늘의 기록")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("닫기") { dismiss() }
                    }
                }
        }
    }
}

#Preview {
    EntryEditorSheet(mode: .new(prompt: nil))
}
