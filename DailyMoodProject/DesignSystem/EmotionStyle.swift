//
//  EmotionStyle.swift
//  DailyMoodProject
//

import SwiftUI

/// 감정별 색. `Color`는 SwiftUI 타입이라 Domain이 아니라 여기에 둔다.
/// 16진수 대신 시스템 색을 써서 라이트·다크와 '대비 높이기' 설정을 자동으로 따른다.
extension Emotion {
    var color: Color {
        switch self {
        case .joy: .yellow
        case .love: .pink
        case .calm: .green
        case .excited: .purple
        case .tired: .indigo
        case .anxious: .orange
        case .sad: .cyan
        case .angry: .red
        }
    }
}
