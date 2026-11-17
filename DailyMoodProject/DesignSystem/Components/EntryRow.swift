//
//  EntryRow.swift
//  DailyMoodProject
//

import SwiftUI

/// 이모지 + 한 줄 + 날짜 행. 접근성 크기에서는 이모지가 윗줄로 올라간다.
struct EntryRow: View {
    let entry: EntrySnapshot

    var body: some View {
        AdaptiveStack(hAlignment: .top, spacing: 12) {
            EmojiText(entry.emotion.emoji, size: 28, relativeTo: .title2)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.text)
                    .font(.callout)                                     // lineLimit을 걸지 않는다
                Text(entry.day.formattedFull)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)                                          // 높이를 정하지 않고 여백만
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(entry.emotion.name), \(entry.text), \(entry.day.formattedFull)")
    }
}

#if DEBUG
#Preview {
    List(PreviewData.entries.suffix(3)) { entry in
        EntryRow(entry: entry)
    }
}
#endif
