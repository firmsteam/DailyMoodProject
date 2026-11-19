//
//  DayChip.swift
//  DailyMoodProject
//

import SwiftUI

/// 날짜를 고르는 알약 모양 칩. 시트의 "빠뜨린 날" 줄에 쓴다. (ADD-07)
struct DayChip: View {
    let title: String
    let accessibilityText: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
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
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    HStack {
        DayChip(title: "오늘", accessibilityText: "오늘", isSelected: true) {}
        DayChip(title: "5월 10일", accessibilityText: "5월 10일", isSelected: false) {}
        DayChip(title: "5월 4일", accessibilityText: "5월 4일", isSelected: false) {}
    }
    .padding()
    .background(Color(.systemGroupedBackground))
    .tint(.indigo)
}
