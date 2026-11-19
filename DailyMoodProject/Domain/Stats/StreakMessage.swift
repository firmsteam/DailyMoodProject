//
//  StreakMessage.swift
//  DailyMoodProject
//

import Foundation

extension StreakInfo {
    /// 연속 기록 카드 아래 문구. 현재 연속을 이전 최장 기록과 비교해 고른다. (REC-05, R-07)
    /// 이전 최장 기록은 진행 중인 연속을 뺀 값이라, 처음 쓰는 사용자도 1일째부터 "N일째" 문구가 나온다.
    var message: String {
        if current < previousBest {
            return "최장 기록 \(previousBest)일까지 \(previousBest - current)일 남았어요"
        } else if current == previousBest {
            return "내일 기록하면 신기록이에요"
        } else {
            return "\(current)일째 연속으로 기록하고 있어요"
        }
    }
}
