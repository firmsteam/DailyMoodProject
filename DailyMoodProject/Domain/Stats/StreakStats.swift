//
//  StreakStats.swift
//  DailyMoodProject
//

import Foundation

/// 연속 기록(R-07). 하루도 빠지지 않고 이어진 기록 날짜 묶음을 구간으로 보고 센다.
struct StreakInfo: Equatable, Sendable {
    /// 현재 연속. 오늘 기록이 있으면 오늘로 끝나는 구간, 없으면 어제로 끝나는 구간이다. 어제도 없으면 0.
    var current: Int
    /// 현재 연속을 뺀 나머지 구간 중 가장 긴 값.
    var previousBest: Int
    /// 현재 연속을 포함한 가장 긴 값. 월간 타일의 "최장 기록"이다.
    var overallBest: Int
}

enum StreakStats {
    static func info(_ entries: [EntrySnapshot], today: DayKey) -> StreakInfo {
        let days = Set(entries.map(\.day)).sorted()
        guard !days.isEmpty else { return StreakInfo(current: 0, previousBest: 0, overallBest: 0) }

        // 하루씩 이어지는 날짜끼리 묶는다.
        var runs: [(end: DayKey, length: Int)] = []
        var previous: DayKey?
        for day in days {
            if let previous, previous.adding(days: 1) == day {
                runs[runs.count - 1] = (day, runs[runs.count - 1].length + 1)
            } else {
                runs.append((day, 1))
            }
            previous = day
        }

        // 현재 연속이 끝나는 날. 오늘 기록 전이면 어제까지 이어진 연속도 끊기지 않은 것으로 본다.
        let anchor = days.contains(today) ? today : today.adding(days: -1)
        let currentIndex = runs.firstIndex { $0.end == anchor }

        let current = currentIndex.map { runs[$0].length } ?? 0
        let others = runs.enumerated().filter { $0.offset != currentIndex }.map(\.element.length)
        let previousBest = others.max() ?? 0
        return StreakInfo(current: current, previousBest: previousBest, overallBest: max(current, previousBest))
    }
}
