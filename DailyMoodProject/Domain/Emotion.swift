//
//  Emotion.swift
//  DailyMoodProject
//

import Foundation

/// 감정 8종. 저장할 때는 이모지가 아니라 영문 키(rawValue)를 쓴다.
enum Emotion: String, CaseIterable, Codable, Identifiable, Sendable {
    case joy, love, calm, excited, tired, anxious, sad, angry

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .joy: "😊"
        case .love: "🥰"
        case .calm: "😌"
        case .excited: "🤩"
        case .tired: "😴"
        case .anxious: "😰"
        case .sad: "😢"
        case .angry: "😡"
        }
    }

    var name: String {
        switch self {
        case .joy: "기쁨"
        case .love: "사랑"
        case .calm: "평온"
        case .excited: "설렘"
        case .tired: "피곤"
        case .anxious: "불안"
        case .sad: "슬픔"
        case .angry: "화남"
        }
    }

    /// 같은 일수일 때 어느 감정을 먼저 보여 줄지 정하는 데만 쓴다. (R-16)
    var score: Int {
        switch self {
        case .joy: 8
        case .love: 7
        case .calm: 6
        case .excited: 5
        case .tired: 4
        case .anxious: 3
        case .sad: 2
        case .angry: 1
        }
    }
}
