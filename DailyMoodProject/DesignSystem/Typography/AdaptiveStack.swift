//
//  AdaptiveStack.swift
//  DailyMoodProject
//

import SwiftUI

/// 글자가 접근성 크기로 커지면 가로 배치(HStack)를 세로 배치(VStack)로 바꾼다.
/// `AnyLayout`을 쓰므로 배치가 바뀌어도 뷰 상태(입력 중인 글 등)가 유지된다.
struct AdaptiveStack<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var hAlignment: VerticalAlignment = .center
    var vAlignment: HorizontalAlignment = .leading
    var spacing: CGFloat = 12
    @ViewBuilder var content: () -> Content

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: vAlignment, spacing: spacing))
            : AnyLayout(HStackLayout(alignment: hAlignment, spacing: spacing))
        layout { content() }
    }
}

#Preview("기본") {
    AdaptiveStack {
        Text("왼쪽")
        Text("오른쪽")
    }
}

#Preview("AX3") {
    AdaptiveStack {
        Text("위")
        Text("아래")
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}
