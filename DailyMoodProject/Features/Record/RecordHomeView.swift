//
//  RecordHomeView.swift
//  DailyMoodProject
//

import SwiftUI

/// 기록 탭(①②). 오늘 기록 유무에 따른 화면 구성은 이후에 구현한다.
/// 지금은 시트와 push 연결만 확인할 수 있게 버튼을 둔다.
struct RecordHomeView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        List {
            Button("오늘의 감정 기록하기") {
                router.sheet = .editor(.new(prompt: nil))
            }
            NavigationLink("오늘 기록 보기", value: DayKey.today())
        }
        .navigationTitle("기록")
        .toolbar {
            // 설정 버튼은 기록 탭에만 있다.
            ToolbarItem(placement: .primaryAction) {
                Button("설정", systemImage: "gearshape") {
                    router.sheet = .settings
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RecordHomeView()
    }
    .environment(AppRouter())
}
