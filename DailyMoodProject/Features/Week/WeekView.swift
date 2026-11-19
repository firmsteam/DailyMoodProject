//
//  WeekView.swift
//  DailyMoodProject
//

import SwiftUI
import SwiftData

/// 주간 탭(⑤). 한 주(일~토)의 대표 감정, 요일별 감정, 요일별 기록을 보여 준다.
/// 주 이동(‹ ›)과 ＋는 시스템 툴바 버튼이라 iOS 26에서 자동으로 글래스가 된다.
struct WeekView: View {
    @Query(sort: \MoodEntry.dayKey) private var allEntries: [MoodEntry]

    @State private var week = WeekRange.current()

    var body: some View {
        let today = DayKey.today()
        let entries = Dictionary(
            week.days.compactMap { day in
                allEntries.first { $0.dayKey == day.rawValue }.map { (day, $0.snapshot) }
            },
            uniquingKeysWith: { first, _ in first }
        )

        ScrollView {
            VStack(spacing: 10) {
                WeekTitle(title: week.title(today: today), range: week.rangeText)
                WeekSummaryCard(summary: WeekSummary(entries: Array(entries.values)))
                WeekEmotionStrip(days: week.days, entries: entries, today: today)
                WeekDayList(days: week.days, entries: entries, today: today)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("")                                            // 제목은 화면 안의 큰 제목이 맡는다
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button("이전 주", systemImage: "chevron.left") {
                    week = week.previous
                }
                // 이번 주에서는 숨기지 않고 비활성으로 둔다.
                Button("다음 주", systemImage: "chevron.right") {
                    week = week.next
                }
                .disabled(!week.canGoNext(today: today))
            }
            ToolbarItem(placement: .primaryAction) {
                RecordDayMenu(days: week.days, entries: entries, today: today)
            }
        }
    }
}

/// 일요일부터 시작하는 요일 약자.
private let weekdaySymbols = ["일", "월", "화", "수", "목", "금", "토"]

// MARK: - 제목

/// 위에 날짜 범위, 아래에 큰 제목.
private struct WeekTitle: View {
    let title: String
    let range: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(range)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.largeTitle.weight(.bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .padding(.bottom, 4)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

/// 카드 윗줄의 아이콘 + 제목.
private struct CardHeader: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.tint)
            .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - 대표 감정 카드

/// 누를 수 없는 카드다. 오른쪽 ›도 두지 않는다.
private struct WeekSummaryCard: View {
    let summary: WeekSummary?

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 6) {
                CardHeader(title: "대표 감정", systemImage: "face.smiling")
                if let summary {
                    AdaptiveStack(hAlignment: .bottom, spacing: 8) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(summary.emotion.name)
                                .font(.largeTitle.weight(.bold))
                            Text("\(summary.recordedDays)일 중 \(summary.count)일")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        EmojiText(summary.emotion.emoji, size: 58, relativeTo: .largeTitle)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(
                        "대표 감정, \(summary.emotion.name), \(summary.recordedDays)일 중 \(summary.count)일"
                    )
                } else {
                    Text("이 주에는 기록이 없어요")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }
        }
    }
}

// MARK: - 요일별 감정 스트립

/// 일~토 7개 원. 오늘은 강조 테두리, 오지 않은 날은 점선 원이다.
/// 칸 수가 정해져 있어 글자 크기에 상한을 두고, 같은 정보는 아래 목록에서 크게 읽을 수 있다.
private struct WeekEmotionStrip: View {
    let days: [DayKey]
    let entries: [DayKey: EntrySnapshot]
    let today: DayKey

    @ScaledMetric(relativeTo: .body) private var circleSize: CGFloat = 34

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                CardHeader(title: "요일별 감정", systemImage: "chart.bar.fill")
                HStack(spacing: 0) {
                    ForEach(Array(days.enumerated()), id: \.element) { index, day in
                        VStack(spacing: 5) {
                            Text(weekdaySymbols[index])
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            circle(for: day)
                            Text("\(day.day)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(dateStyle(for: day))
                        }
                        .frame(maxWidth: .infinity)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(accessibilityLabel(for: day))
                    }
                }
            }
        }
        .cappedDynamicType()
    }

    private func dateStyle(for day: DayKey) -> AnyShapeStyle {
        if day == today { AnyShapeStyle(.tint) }
        else if day > today { AnyShapeStyle(.tertiary) }
        else { AnyShapeStyle(.primary) }
    }

    @ViewBuilder
    private func circle(for day: DayKey) -> some View {
        ZStack {
            if let entry = entries[day] {
                Circle().fill(Color(.tertiarySystemFill))
                Text(entry.emotion.emoji).font(.system(size: circleSize * 0.56))
            } else if day > today {
                Circle().strokeBorder(Color(.separator), style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
            } else {
                Circle().fill(Color(.tertiarySystemFill))
            }
        }
        .frame(width: circleSize, height: circleSize)
        .overlay {
            if day == today {
                Circle().stroke(.tint, lineWidth: 2).padding(-1)       // 원 바깥쪽 강조 테두리
            }
        }
    }

    private func accessibilityLabel(for day: DayKey) -> String {
        let prefix = day == today ? "오늘, " : ""
        if let entry = entries[day] { return "\(prefix)\(day.formattedFull), \(entry.emotion.name)" }
        return "\(prefix)\(day.formattedFull), \(day > today ? "아직 오지 않았어요" : "기록하지 않았어요")"
    }
}

// MARK: - 요일별 기록 목록

/// 하루 한 행. 기록이 있는 행만 기록 관리(⑦)로 이동한다.
private struct WeekDayList: View {
    let days: [DayKey]
    let entries: [DayKey: EntrySnapshot]
    let today: DayKey

    @ScaledMetric(relativeTo: .body) private var dateWidth: CGFloat = 30
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(spacing: 0) {
            Text("요일별 기록")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 7)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 0) {
                ForEach(Array(days.enumerated()), id: \.element) { index, day in
                    if index > 0 {
                        // 구분선은 이모지 위치부터 시작한다.
                        Divider().padding(.leading, dynamicTypeSize.isAccessibilitySize ? 16 : 16 + dateWidth + 12)
                    }
                    if let entry = entries[day] {
                        NavigationLink(value: day) {
                            WeekDayRow(day: day, content: .recorded(entry), isToday: day == today)
                        }
                        .buttonStyle(.plain)
                    } else {
                        WeekDayRow(day: day, content: emptyContent(for: day), isToday: day == today)
                    }
                }
            }
            .background(
                Color(.secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: 26, style: .continuous)
            )
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
    }

    private func emptyContent(for day: DayKey) -> WeekDayRow.Content {
        if day > today { .future } else if day == today { .todayEmpty } else { .missed }
    }
}

private struct WeekDayRow: View {
    enum Content {
        case recorded(EntrySnapshot)
        /// 오늘이면서 아직 기록이 없는 경우. 지난 날도 오지 않은 날도 아니다.
        case todayEmpty
        case missed
        case future
    }

    let day: DayKey
    let content: Content
    let isToday: Bool

    @ScaledMetric(relativeTo: .body) private var dateWidth: CGFloat = 30
    @ScaledMetric(relativeTo: .title2) private var emojiWidth: CGFloat = 30
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        AdaptiveStack(hAlignment: .center, spacing: 12) {
            dateColumn
            switch content {
            case .recorded(let entry):
                EmojiText(entry.emotion.emoji, size: 27, relativeTo: .title2)
                    .frame(width: dynamicTypeSize.isAccessibilitySize ? nil : emojiWidth)
                Text(entry.text)
                    .font(.callout)                                     // lineLimit을 걸지 않는다
                    .frame(maxWidth: .infinity, alignment: .leading)
            case .todayEmpty:
                emptyLine("오늘의 감정을 기록해 보세요", style: AnyShapeStyle(.secondary))
            case .missed:
                emptyLine("기록하지 않았어요", style: AnyShapeStyle(.tertiary))
            case .future:
                emptyLine("아직 오지 않았어요", style: AnyShapeStyle(.tertiary))
            }
        }
        .padding(.vertical, 9)
        .padding(.horizontal, 16)
        .frame(minHeight: 56)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    /// 요일(작게) 위, 날짜(크게) 아래.
    private var dateColumn: some View {
        let weekday = weekdaySymbols[Calendar.app.component(.weekday, from: day.date()) - 1]
        return VStack(spacing: 1) {
            Text(weekday)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(day.day)")
                .font(.headline)
                .foregroundStyle(dateStyle)
        }
        .frame(width: dynamicTypeSize.isAccessibilitySize ? nil : dateWidth)
        .frame(maxWidth: dynamicTypeSize.isAccessibilitySize ? .infinity : nil, alignment: .leading)
    }

    private var dateStyle: AnyShapeStyle {
        if isToday { return AnyShapeStyle(.tint) }
        switch content {
        case .missed, .future: return AnyShapeStyle(.tertiary)
        case .recorded, .todayEmpty: return AnyShapeStyle(.primary)
        }
    }

    /// 이모지 자리를 비워 두어 한 줄의 시작 위치를 기록 있는 행과 맞춘다.
    private func emptyLine(_ text: String, style: AnyShapeStyle) -> some View {
        Text(text)
            .font(.callout)
            .foregroundStyle(style)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, dynamicTypeSize.isAccessibilitySize ? 0 : emojiWidth + 12)
    }

    private var accessibilityLabel: String {
        switch content {
        case .recorded(let entry): "\(day.formattedFull), \(entry.emotion.name), \(entry.text)"
        case .todayEmpty: "\(day.formattedFull), 오늘의 감정을 기록해 보세요"
        case .missed: "\(day.formattedFull), 기록하지 않았어요"
        case .future: "\(day.formattedFull), 아직 오지 않았어요"
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        WeekView()
    }
    .environment(AppRouter())
    .modelContainer(.preview)
    .tint(.indigo)
}
#endif
