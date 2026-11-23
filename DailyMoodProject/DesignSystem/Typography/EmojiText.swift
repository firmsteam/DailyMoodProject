//
//  EmojiText.swift
//  DailyMoodProject
//

import SwiftUI

/// 글자 크기 설정에 따라 함께 커지는 이모지.
/// 이모지처럼 크기를 숫자로 정해야 하는 것은 `@ScaledMetric`으로 감싼다.
struct EmojiText: View {
    @ScaledMetric private var size: CGFloat
    private let emoji: String

    init(_ emoji: String, size: CGFloat, relativeTo style: Font.TextStyle = .title) {
        self.emoji = emoji
        _size = ScaledMetric(wrappedValue: size, relativeTo: style)
    }

    var body: some View {
        Text(emoji).font(.system(size: size))
    }
}

#Preview {
    HStack {
        EmojiText("😊", size: 28)
        EmojiText("😌", size: 40)
        EmojiText("🥰", size: 76)
    }
}
