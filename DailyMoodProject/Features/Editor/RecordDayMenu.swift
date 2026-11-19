//
//  RecordDayMenu.swift
//  DailyMoodProject
//

import SwiftUI

/// 주간·월간 툴바의 ＋ 메뉴. 보고 있는 기간 중 오늘까지의 날을 골라 기록하거나 수정한다.
/// 기록이 있는 날은 수정 시트(③-1)로, 없는 날은 그 날짜로 새 기록 시트(③)를 연다.
/// 아직 오지 않은 날은 목록에 넣지 않는다.
struct RecordDayMenu: View {
    @Environment(AppRouter.self) private var router

    /// 보고 있는 기간의 모든 날.
    let days: [DayKey]
    let entries: [DayKey: EntrySnapshot]
    let today: DayKey

    var body: some View {
        // 가까운 날이 위에 오도록 최근 순으로 둔다.
        let selectable = days.filter { $0 <= today }.reversed()

        Menu("날짜를 골라 기록하기", systemImage: "plus") {
            ForEach(Array(selectable), id: \.self) { day in
                Button {
                    open(day)
                } label: {
                    if let entry = entries[day] {
                        Text("\(day.formattedFull) · \(entry.emotion.emoji) 수정")
                    } else {
                        Text("\(day.formattedFull) · 기록하기")
                    }
                }
            }
        }
        .disabled(selectable.isEmpty)
    }

    private func open(_ day: DayKey) {
        router.sheet = .editor(entries[day] != nil ? .edit(day) : .newOn(day))
    }
}
