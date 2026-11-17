//
//  SettingsIcon.swift
//  DailyMoodProject
//

import SwiftUI

/// 설정 행 앞에 붙는 색 사각형 아이콘.
struct SettingsIcon: View {
    let systemImage: String
    let color: Color

    @ScaledMetric private var size: CGFloat = 30

    var body: some View {
        Image(systemName: systemImage)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(color, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .accessibilityHidden(true)                                  // 옆의 글자가 같은 뜻을 전한다
    }
}

#Preview {
    HStack {
        SettingsIcon(systemImage: "bell.fill", color: .red)
        SettingsIcon(systemImage: "clock.fill", color: .orange)
        SettingsIcon(systemImage: "square.and.arrow.up", color: .indigo)
    }
    .padding()
}
