//
//  InsightText.swift
//  DailyMoodProject
//

import Foundation

/// 인사이트 문구(R-12). 예: "평온한 날이 가장 많아요 (33%)"
enum InsightText {
    /// "OO 날"에 들어갈 꾸밈말. 감정 이름에 "한"을 붙이면 어색한 감정이 있어서 따로 둔다.
    static func adjective(for emotion: Emotion) -> String {
        switch emotion {
        case .joy: "기쁜"
        case .love: "사랑한"
        case .calm: "평온한"
        case .excited: "설레는"
        case .tired: "피곤한"
        case .anxious: "불안한"
        case .sad: "슬픈"
        case .angry: "화난"
        }
    }

    static func sentence(emotion: Emotion, percent: Int?) -> String {
        let base = "\(adjective(for: emotion)) 날이 가장 많아요"
        guard let percent else { return base }
        return "\(base) (\(percent)%)"
    }
}
