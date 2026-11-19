//
//  EmotionChip.swift
//  DailyMoodProject
//

import SwiftUI

/// 감정별 필터 칩. `emotion`이 `nil`이면 "전체" 칩이다.
struct EmotionChip: View {
    let emotion: Emotion?
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    private var title: String { emotion?.name ?? "전체" }

    var body: some View {
        Button(action: action) {
            // 시안: 높이 36, 좌우 14, 글자와 개수 사이 6, 글자 15 medium, 개수 13.
            HStack(spacing: 6) {
                if let emotion {
                    Text(emotion.emoji)
                }
                Text(title)
                Text("\(count)")
                    .font(.footnote)
                    .foregroundStyle(isSelected ? AnyShapeStyle(.white.opacity(0.75)) : AnyShapeStyle(.secondary))
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(isSelected ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
            .padding(.horizontal, 14)
            .frame(minHeight: 36)                       // 높이는 고정하지 않고 최소값만 둔다
            .background(
                isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(Color(.secondarySystemGroupedBackground)),
                in: Capsule()
            )
            // 눈에 보이는 높이는 36이지만, 누를 수 있는 영역은 위아래 4씩 넓혀 44를 맞춘다.
            .padding(.vertical, 4)
            .contentShape(Rectangle())
            .padding(.vertical, -4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title), \(count)개")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    HStack {
        EmotionChip(emotion: nil, count: 12, isSelected: true) {}
        EmotionChip(emotion: .calm, count: 4, isSelected: false) {}
        EmotionChip(emotion: .joy, count: 3, isSelected: false) {}
    }
    .padding()
    .tint(.indigo)
}
