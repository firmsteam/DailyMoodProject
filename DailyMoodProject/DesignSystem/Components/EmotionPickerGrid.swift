//
//  EmotionPickerGrid.swift
//  DailyMoodProject
//

import SwiftUI

/// 감정 선택 격자. 글자가 커지면 열 수를 줄인다.
/// 기본 4열, `xxxLarge` 이상 3열, 접근성 크기 2열.
struct EmotionPickerGrid: View {
    @Binding var selection: Emotion?
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var columnCount: Int {
        if dynamicTypeSize >= .accessibility1 { 2 }
        else if dynamicTypeSize >= .xxxLarge { 3 }
        else { 4 }
    }

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: columnCount),
            spacing: 8
        ) {
            ForEach(Emotion.allCases) { emotion in
                Button {
                    selection = emotion
                } label: {
                    VStack(spacing: 4) {
                        EmojiText(emotion.emoji, size: 28)
                        Text(emotion.name).font(.caption2)
                    }
                    .frame(maxWidth: .infinity, minHeight: 62)         // 높이는 minHeight
                    .overlay {
                        if selection == emotion {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(.tint, lineWidth: 2)
                        }
                    }
                    .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(emotion.name)                       // 이모지 대신 이름을 읽는다
                .accessibilityAddTraits(selection == emotion ? .isSelected : [])
            }
        }
    }
}

#Preview {
    @Previewable @State var selection: Emotion? = .calm
    EmotionPickerGrid(selection: $selection)
        .padding()
        .tint(.indigo)
}
