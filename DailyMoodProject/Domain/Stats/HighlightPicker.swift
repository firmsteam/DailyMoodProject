//
//  HighlightPicker.swift
//  DailyMoodProject
//

import Foundation

/// 월간 화면의 "대표 한 줄"(MON-06)을 고르는 기준.
/// 기준이 아직 정해지지 않아(G-02) 프로토콜 뒤에 두었다. 기준이 정해지면 구현체만 바꾼다.
protocol HighlightPicker {
    func pick(from monthEntries: [EntrySnapshot], count: Int) -> [EntrySnapshot]
}

/// 임시 기준: 그 달의 가장 최근 기록 `count`건.
struct RecentHighlightPicker: HighlightPicker {
    func pick(from monthEntries: [EntrySnapshot], count: Int) -> [EntrySnapshot] {
        Array(monthEntries.sorted { $0.day > $1.day }.prefix(count))
    }
}
