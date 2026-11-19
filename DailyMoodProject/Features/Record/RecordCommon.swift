//
//  RecordCommon.swift
//  DailyMoodProject
//

import SwiftUI

// 기록 탭의 두 화면(기록 전 ②, 기록 후 ①)이 함께 쓰는 부품.

/// 오늘 날짜와 큰 제목 "기록". (REC-01)
struct RecordHeader: View {
    let today: DayKey

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(today.formattedFull)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.tint)
            Text("기록")
                .font(.system(size: 48, weight: .bold))
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

/// 가로로 넘겨 보는 카드 줄. 각 카드에 `.recordCardWidth()`를 붙인다. 다음 카드가 살짝 보인다. (REC-08)
struct RecordCardRow<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                content()
            }
            .scrollTargetLayout()
            .fixedSize(horizontal: false, vertical: true)       // 가장 높은 카드에 높이를 맞춘다
        }
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
    }
}

extension View {
    /// 가로 카드 줄 안의 카드 너비. 화면의 85%라서 다음 카드가 살짝 보인다.
    func recordCardWidth() -> some View {
        containerRelativeFrame(.horizontal) { length, _ in length * 0.85 }
            .frame(maxHeight: .infinity, alignment: .top)
    }
}

/// 감정별 기록. 감정 칩으로 목록을 걸러 보고, 행을 누르면 기록 관리(⑦)로 이동한다. (REC-09·10, REC-17)
struct RecordEntryList: View {
    /// 날짜 내림차순(최근 기록이 위).
    let entries: [EntrySnapshot]

    @State private var selected: Emotion?

    /// 기록이 있는 감정만, 많은 순으로 둔다. 개수가 같으면 점수가 높은 감정이 먼저다. (R-10, R-16)
    private var emotionCounts: [EmotionCount] {
        PeriodStats.distribution(entries)
    }

    /// 선택한 감정의 기록이 모두 사라졌다면 "전체"로 돌아간다.
    private var activeFilter: Emotion? {
        guard let selected, entries.contains(where: { $0.emotion == selected }) else { return nil }
        return selected
    }

    private var visibleEntries: [EntrySnapshot] {
        guard let activeFilter else { return entries }
        return entries.filter { $0.emotion == activeFilter }
    }

    private var listTitle: String {
        guard let activeFilter else { return "최근 기록" }
        return "\(activeFilter.emoji) \(activeFilter.name) · \(visibleEntries.count)개의 기록"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AdaptiveStack(hAlignment: .firstTextBaseline, spacing: 4) {
                Text("감정별 기록").font(.title3.bold())
                Spacer(minLength: 0)
                Text("총 \(entries.count)개")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if entries.isEmpty {
                // 처음 설치해서 기록이 하나도 없을 때
                Card {
                    Text("아직 기록이 없어요")
                        .foregroundStyle(.secondary)
                }
            } else {
                chips
                Text(listTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Card {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(visibleEntries) { entry in
                            NavigationLink(value: entry.day) {
                                EntryRow(entry: entry)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            if entry.id != visibleEntries.last?.id {
                                Divider()
                            }
                        }
                    }
                }
            }
        }
    }

    private var chips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                EmotionChip(emotion: nil, count: entries.count, isSelected: activeFilter == nil) {
                    selected = nil
                }
                ForEach(emotionCounts) { item in
                    EmotionChip(emotion: item.emotion, count: item.days, isSelected: activeFilter == item.emotion) {
                        selected = item.emotion
                    }
                }
            }
        }
    }
}
