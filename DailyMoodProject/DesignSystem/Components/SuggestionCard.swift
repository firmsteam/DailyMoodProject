//
//  SuggestionCard.swift
//  DailyMoodProject
//

import SwiftUI

/// 기록한 감정에 맞는 옷차림과 활동 추천 카드. 달력 아래 선택한 날 영역에 보여 준다.
struct SuggestionCard: View {
    let emotion: Emotion

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 14) {
                Text("기분 맞춤 추천")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .accessibilityAddTraits(.isHeader)
                row(systemImage: "tshirt", title: "옷차림", text: emotion.outfitSuggestion)
                row(systemImage: "figure.walk", title: "활동", text: emotion.activitySuggestion)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func row(systemImage: String, title: String, text: String) -> some View {
        AdaptiveStack(hAlignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(emotion.color)
                .frame(width: 28)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(text)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)      // 줄 수를 제한하지 않는다.
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 12) {
            SuggestionCard(emotion: .calm)
            SuggestionCard(emotion: .tired)
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
    .tint(.indigo)
}
