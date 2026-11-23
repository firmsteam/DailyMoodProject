//
//  GlassIconButton.swift
//  DailyMoodProject
//

import SwiftUI

/// 직접 만든 원형 글래스 버튼. 시스템 툴바 버튼은 iOS 26에서 자동으로 글래스가 되므로
/// 툴바 밖에서 직접 그릴 때만 쓴다.
struct GlassIconButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    @ScaledMetric private var minSize: CGFloat = 44                    // 누르는 영역 44pt 이상

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .labelStyle(.iconOnly)
                .font(.body.weight(.semibold))
                .frame(minWidth: minSize, minHeight: minSize)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .circle)
    }
}

#Preview {
    GlassIconButton(title: "이전", systemImage: "chevron.left") {}
        .padding()
}
