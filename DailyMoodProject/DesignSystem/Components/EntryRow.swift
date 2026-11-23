//
//  EntryRow.swift
//  DailyMoodProject
//

import SwiftUI

/// 이모지 + 한 줄 + 날짜 + › 행. 접근성 크기에서는 이모지가 윗줄로 올라간다.
/// 시안: 안쪽 여백 위아래 9 · 좌우 16, 최소 높이 56, 이모지 27(칸 너비 30), 간격 12, 한 줄 16, 날짜 12, › 12.
struct EntryRow: View {
    let entry: EntrySnapshot

    var body: some View {
        HStack(spacing: 12) {
            AdaptiveStack(hAlignment: .center, spacing: 12) {
                EmojiText(entry.emotion.emoji, size: 27, relativeTo: .title2)
                    .frame(minWidth: 30)
                VStack(alignment: .leading, spacing: 0) {
                    Text(entry.text)
                        .font(.callout)                                 // lineLimit을 걸지 않는다
                    Text(entry.day.formattedFull)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color(.tertiaryLabel))
                .accessibilityHidden(true)
        }
        .padding(.vertical, 9)                                          // 높이를 정하지 않고 여백과 최소값만
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(entry.emotion.name), \(entry.text), \(entry.day.formattedFull)")
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 0) {
        ForEach(PreviewData.entries.suffix(3)) { entry in
            EntryRow(entry: entry)
        }
    }
    .background(Color(.secondarySystemGroupedBackground))
    .padding()
}
#endif
