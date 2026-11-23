//
//  Card.swift
//  DailyMoodProject
//

import SwiftUI

/// 카드 배경. 모서리는 26pt(작은 카드는 24pt), 안쪽 여백은 위아래 14pt, 좌우 16pt.
/// 글래스는 조작 요소에만 쓰므로 카드에는 쓰지 않는다.
struct Card<Content: View>: View {
    var cornerRadius: CGFloat = 26
    @ViewBuilder var content: () -> Content

    @ScaledMetric private var verticalPadding: CGFloat = 14
    @ScaledMetric private var horizontalPadding: CGFloat = 16

    var body: some View {
        content()
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Color(.secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
    }
}

#Preview {
    Card {
        Text("카드 안의 내용").font(.body)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
