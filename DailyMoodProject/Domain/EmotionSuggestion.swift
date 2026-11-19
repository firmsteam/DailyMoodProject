//
//  EmotionSuggestion.swift
//  DailyMoodProject
//

import Foundation

/// 감정에 맞는 옷차림과 활동 추천. 날씨나 네트워크 없이 감정만으로 정해지는 고정 문구다.
/// 문구는 SwiftUI와 무관해서 Domain에 둔다.
extension Emotion {
    /// 옷차림 추천 한 줄.
    var outfitSuggestion: String {
        switch self {
        case .joy: "밝은 노랑이나 파스텔 톤 상의에 편한 청바지"
        case .love: "부드러운 핑크나 베이지 계열의 니트, 셔츠"
        case .calm: "린넨 셔츠나 면 소재의 편안한 옷"
        case .excited: "포인트 컬러 소품에 활동하기 편한 스니커즈"
        case .tired: "신축성 좋은 후디와 조거 팬츠처럼 몸이 편한 옷"
        case .anxious: "촉감 좋은 면 소재에 차분한 단색 옷"
        case .sad: "포근한 가디건처럼 따뜻한 겉옷"
        case .angry: "답답하지 않은 헐렁한 티셔츠와 가벼운 운동화"
        }
    }

    /// 활동 추천 한 줄.
    var activitySuggestion: String {
        switch self {
        case .joy: "기분 좋은 순간을 사진으로 남기거나 좋아하는 사람에게 연락해 보세요"
        case .love: "소중한 사람과 식사하거나 짧은 손편지를 써 보세요"
        case .calm: "공원을 산책하거나 차 한 잔과 함께 책을 읽어 보세요"
        case .excited: "가 보고 싶던 곳에 가거나 새로운 취미를 시작해 보세요"
        case .tired: "따뜻하게 샤워하고 일찍 누워 화면 보는 시간을 줄여 보세요"
        case .anxious: "천천히 심호흡을 하거나 10분쯤 걸으며 생각을 비워 보세요"
        case .sad: "좋아하는 음악을 듣거나 믿는 사람과 이야기를 나눠 보세요"
        case .angry: "빠르게 걷거나 가볍게 운동하며 열을 식혀 보세요"
        }
    }
}
