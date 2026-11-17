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
            HStack(spacing: 6) {
                if let emotion {
                    Text(emotion.emoji)
                }
                Text(title)
                Text("\(count)")
                    .foregroundStyle(isSelected ? AnyShapeStyle(.white.opacity(0.8)) : AnyShapeStyle(.secondary))
            }
            .font(.subheadline)
            .foregroundStyle(isSelected ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
            .padding(.horizontal, 14)
            .frame(minHeight: 44)                       // 높이는 고정하지 않고 최소값만 둔다
            .background(
                isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(Color(.secondarySystemGroupedBackground)),
                in: Capsule()
            )
            .contentShape(Capsule())
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
