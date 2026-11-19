//
//  RecordCommon.swift
//  DailyMoodProject
//

import SwiftUI

// 기록 탭의 두 화면(기록 전 ②, 기록 후 ①)이 함께 쓰는 부품.
// 크기와 간격은 시안(screens.html)의 CSS 값을 그대로 옮겼다. 글자는 Dynamic Type을 따르도록 텍스트 스타일을 쓰고,
// 괄호 안의 숫자는 시안의 글자 크기다.

/// 오늘 날짜와 큰 제목 "기록". 날짜 15 semibold, 제목 34 bold. (REC-01)
struct RecordHeader: View {
    let today: DayKey

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(today.formattedFull)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.tint)
            Text("기록")
                .font(.largeTitle.bold())
        }
        .padding(.horizontal, 20)
        .padding(.top, 1)
        .padding(.bottom, 14)
    }
}

// MARK: - 가로 카드 줄 (REC-08)

/// 가로로 넘겨 보는 카드 줄. 카드 사이 간격 10, 양쪽 여백 16. 각 카드는 `RecordMiniCard`를 쓴다.
struct RecordCardRow<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 10) {
                content()
            }
            .fixedSize(horizontal: false, vertical: true)       // 가장 높은 카드에 높이를 맞춘다
        }
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .padding(.top, 10)
    }
}

/// 가로 카드 줄의 카드. 시안은 212 × 100pt, 모서리 24, 안쪽 여백 위아래 13 · 좌우 15.
/// 글자가 접근성 크기로 커지면 내용이 잘리지 않게 높이는 늘어나고 너비는 화면의 85%가 된다.
struct RecordMiniCard<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(.vertical, 13)
        .padding(.horizontal, 15)
        .frame(maxWidth: .infinity, minHeight: 100, maxHeight: .infinity, alignment: .topLeading)
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .modifier(MiniCardWidth(isLarge: dynamicTypeSize.isAccessibilitySize))
    }
}

private struct MiniCardWidth: ViewModifier {
    let isLarge: Bool

    func body(content: Content) -> some View {
        if isLarge {
            content.containerRelativeFrame(.horizontal) { length, _ in length * 0.85 }
        } else {
            content.frame(width: 212)
        }
    }
}

/// 카드 맨 윗줄. 아이콘과 이름을 같은 색으로 보여 준다. (13 semibold)
struct RecordMiniHeader: View {
    let title: String
    let systemImage: String
    let color: Color

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(color)
    }
}

/// 연속 기록 카드. 기록 전(②)과 기록 후(①)가 같은 모양을 쓴다. (REC-05, REC-15)
struct RecordStreakCard: View {
    let days: Int
    let caption: String
    let today: DayKey
    let recorded: Set<DayKey>

    var body: some View {
        RecordMiniCard {
            RecordMiniHeader(title: "연속 기록", systemImage: "flame", color: .orange)
            Spacer(minLength: 0)
            HStack(alignment: .center, spacing: 8) {
                Text("\(days)일").font(.title.bold())
                Spacer(minLength: 0)
                WeekDots(today: today, recorded: recorded)
            }
            Spacer(minLength: 0)
            Text(caption)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("연속 기록, \(days)일, \(caption)")
    }
}

/// 이번 주 일요일부터 토요일까지 점 7개. 기록한 날은 채우고, 오늘이 아직 기록 전이면 테두리만 그린다.
/// 점은 9pt, 간격은 4pt.
private struct WeekDots: View {
    let today: DayKey
    let recorded: Set<DayKey>

    var body: some View {
        HStack(spacing: 4) {
            ForEach(WeekRange(containing: today).days, id: \.self) { day in
                dot(for: day)
            }
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func dot(for day: DayKey) -> some View {
        if recorded.contains(day) {
            Circle().fill(.orange).frame(width: 9, height: 9)
        } else if day == today {
            Circle().strokeBorder(.orange, lineWidth: 1.5).frame(width: 9, height: 9)
        } else {
            Circle().fill(Color(.tertiarySystemFill)).frame(width: 9, height: 9)
        }
    }
}

// MARK: - 감정별 기록 (REC-09 · 10 · 17)

/// 감정 칩으로 목록을 걸러 보고, 행을 누르면 기록 관리(⑦)로 이동한다.
/// 화면 좌우 여백은 이 부품이 직접 둔다. 칩 줄은 화면 끝까지 스크롤되기 때문이다.
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
        VStack(alignment: .leading, spacing: 0) {
            // 제목 (22 bold) 과 총 개수 (13)
            AdaptiveStack(hAlignment: .firstTextBaseline, spacing: 4) {
                Text("감정별 기록").font(.title2.bold())
                Spacer(minLength: 0)
                Text("총 \(entries.count)개")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 25)
            .padding(.bottom, 12)

            if entries.isEmpty {
                // 처음 설치해서 기록이 하나도 없을 때
                Card {
                    Text("아직 기록이 없어요")
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
            } else {
                chips
                Text(listTitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                    .padding(.bottom, 7)
                list
                    .padding(.horizontal, 16)
            }
        }
    }

    /// 칩 사이 8, 줄 아래 2. 양쪽 끝은 16 띄우고 그 바깥까지 스크롤된다.
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
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .padding(.bottom, 2)
    }

    /// 모서리 26인 흰 카드. 행 사이 구분선은 이모지 칸을 지난 58pt 지점에서 시작한다.
    private var list: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(visibleEntries) { entry in
                NavigationLink(value: entry.day) {
                    EntryRow(entry: entry)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                if entry.id != visibleEntries.last?.id {
                    Divider().padding(.leading, 58)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 26, style: .continuous)
        )
    }
}
