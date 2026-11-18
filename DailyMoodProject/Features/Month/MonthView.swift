//
//  MonthView.swift
//  DailyMoodProject
//

import SwiftUI
import SwiftData
import Charts

/// 월간 탭(⑥). 한 달의 기록한 날, 연속 기록, 감정 분포, 대표 한 줄을 요약해서 보여 준다.
/// 달 이동(‹ ›)과 ＋는 시스템 툴바 버튼이라 iOS 26에서 자동으로 글래스가 된다.
struct MonthView: View {
    @Environment(AppRouter.self) private var router
    @Query(sort: \MoodEntry.dayKey) private var allEntries: [MoodEntry]

    @State private var month = MonthRange.current()

    /// 대표 한 줄을 고르는 기준. 기준이 정해지면(G-02) 이 한 줄만 바꾼다.
    private let highlightPicker: any HighlightPicker = RecentHighlightPicker()

    var body: some View {
        let today = DayKey.today()
        let snapshots = allEntries.map(\.snapshot)
        let monthEntries = snapshots.filter { month.contains($0.day) }
        let elapsedDays = month.elapsedDays(today: today)

        ScrollView {
            VStack(spacing: 10) {
                MonthTitle(year: month.yearText, title: month.summaryTitle)
                    .padding(.bottom, 4)

                AdaptiveStack(vAlignment: .leading, spacing: 10) {
                    RecordedDaysTile(
                        recordedDays: monthEntries.count,
                        elapsedDays: elapsedDays
                    )
                    StreakTile(info: StreakStats.info(snapshots, today: today))
                }

                EmotionDistributionCard(distribution: PeriodStats.distribution(monthEntries))

                HighlightList(entries: highlightPicker.pick(from: monthEntries, count: 3))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("")                                            // 제목은 화면 안의 큰 제목이 맡는다
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button("이전 달", systemImage: "chevron.left") {
                    month = month.previous
                }
                // 이번 달에서는 숨기지 않고 비활성으로 둔다.
                Button("다음 달", systemImage: "chevron.right") {
                    month = month.next
                }
                .disabled(!month.canGoNext(today: today))
            }
            ToolbarItem(placement: .primaryAction) {
                Button("오늘 기록하기", systemImage: "plus") {
                    recordToday(today)
                }
            }
        }
    }

    /// 오늘 기록이 이미 있으면 수정 시트로, 없으면 새 기록 시트로 연다. 하루 한 건이라 덮어쓰지 않게 한다.
    private func recordToday(_ today: DayKey) {
        let hasToday = allEntries.contains { $0.dayKey == today.rawValue }
        router.sheet = .editor(hasToday ? .edit(today) : .new(prompt: nil))
    }
}

// MARK: - 제목

/// 위에 연도, 아래에 큰 제목.
private struct MonthTitle: View {
    let year: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(year)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.largeTitle.weight(.bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

/// 카드 윗줄의 아이콘 + 제목.
private struct CardHeader: View {
    let title: String
    let systemImage: String
    var color: Color?

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(color.map { AnyShapeStyle($0) } ?? AnyShapeStyle(.tint))
            .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - 타일 (MON-03, MON-04)

/// "12 / 14일", 진행 막대, "기록률 86%". 누를 수 없는 타일이다.
private struct RecordedDaysTile: View {
    let recordedDays: Int
    let elapsedDays: Int

    var body: some View {
        let rate = PeriodStats.recordRate(recordedDays: recordedDays, elapsedDays: elapsedDays)

        Card(cornerRadius: 24) {
            VStack(alignment: .leading, spacing: 8) {
                CardHeader(title: "기록한 날", systemImage: "calendar")
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) { number; unit }
                    VStack(alignment: .leading, spacing: 0) { number; unit }
                }
                ProgressView(value: Double(recordedDays), total: Double(max(elapsedDays, 1)))
                // 기록이 하나도 없으면 0%라고 하지 않고 안내 문구를 둔다. (D-04)
                Text(rateText(rate))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
            }
        }
        .frame(maxHeight: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel(rate: rate))
    }

    private var number: some View {
        Text("\(recordedDays)").font(.largeTitle.weight(.bold))
    }

    private var unit: some View {
        Text("/ \(elapsedDays)일")
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.secondary)
    }

    private func rateText(_ rate: Int?) -> String {
        guard let rate, recordedDays > 0 else { return "아직 기록이 없어요" }
        return "기록률 \(rate)%"
    }

    private func accessibilityLabel(rate: Int?) -> String {
        let base = "기록한 날, \(elapsedDays)일 중 \(recordedDays)일"
        guard let rate, recordedDays > 0 else { return base }
        return "\(base), 기록률 \(rate)퍼센트"
    }
}

/// 현재 연속 일수와 최장 기록. 누를 수 없는 타일이다.
private struct StreakTile: View {
    let info: StreakInfo

    var body: some View {
        Card(cornerRadius: 24) {
            VStack(alignment: .leading, spacing: 8) {
                CardHeader(title: "연속 기록", systemImage: "flame", color: .orange)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(info.current)").font(.largeTitle.weight(.bold))
                    Text("일")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                Text("최장 기록 \(info.overallBest)일")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
            }
        }
        .frame(maxHeight: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("연속 기록, \(info.current)일, 최장 기록 \(info.overallBest)일")
    }
}

// MARK: - 감정 분포 카드 (MON-05)

/// 도넛 차트와 범례(상위 5개). 카드에 ›를 두지 않고, 눌러도 이동하지 않는다.
private struct EmotionDistributionCard: View {
    let distribution: [EmotionCount]

    /// 범례에 보여 줄 감정 수. 도넛에는 모두 그린다. (R-10)
    private let legendLimit = 5

    @ScaledMetric(relativeTo: .body) private var chartSize: CGFloat = 116

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                CardHeader(title: "감정 분포", systemImage: "chart.pie")
                if let top = distribution.first {
                    AdaptiveStack(hAlignment: .center, spacing: 20) {
                        donut(top: top)
                        legend
                    }
                } else {
                    Text("이 달에는 기록이 없어요")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    /// 가운데에 대표 감정(이모지와 이름)을 둔다.
    /// 색만으로 구분하지 않도록, 차트 전체를 "평온 4일, 기쁨 3일"처럼 읽히게 한다.
    private func donut(top: EmotionCount) -> some View {
        Chart(distribution) { item in
            SectorMark(
                angle: .value("일수", item.days),
                innerRadius: .ratio(0.55),
                angularInset: 1.5
            )
            .foregroundStyle(item.emotion.color)
        }
        .chartLegend(.hidden)
        .frame(width: chartSize, height: chartSize)
        .overlay {
            VStack(spacing: 0) {
                EmojiText(top.emotion.emoji, size: 26, relativeTo: .title2)
                Text(top.emotion.name)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("감정 분포")
        .accessibilityValue(distribution.map { "\($0.emotion.name) \($0.days)일" }.joined(separator: ", "))
    }

    private var legend: some View {
        VStack(spacing: 8) {
            ForEach(distribution.prefix(legendLimit)) { item in
                HStack(spacing: 8) {
                    Circle()
                        .fill(item.emotion.color)
                        .frame(width: 10, height: 10)
                    Text(item.emotion.emoji)
                    Text(item.emotion.name)
                        .font(.callout)
                    Spacer(minLength: 8)
                    Text("\(item.days)")
                        .font(.callout.weight(.semibold))
                        .monospacedDigit()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityHidden(true)                                      // 같은 내용을 차트가 읽어 준다
    }
}

// MARK: - 대표 한 줄 (MON-06)

/// 이모지, 한 줄, 날짜. 행을 누르면 기록 관리(⑦)로 이동한다.
private struct HighlightList: View {
    let entries: [EntrySnapshot]

    @ScaledMetric(relativeTo: .title2) private var emojiWidth: CGFloat = 34
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if !entries.isEmpty {
            VStack(spacing: 0) {
                Text("대표 한 줄")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 7)
                    .accessibilityAddTraits(.isHeader)

                VStack(spacing: 0) {
                    ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                        if index > 0 {
                            // 구분선은 글자 위치부터 시작한다.
                            Divider().padding(.leading, dynamicTypeSize.isAccessibilitySize ? 16 : 16 + emojiWidth + 12)
                        }
                        NavigationLink(value: entry.day) {
                            HighlightRow(entry: entry, emojiWidth: emojiWidth)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(
                    Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 26, style: .continuous)
                )
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            }
            .padding(.top, 8)
        }
    }
}

private struct HighlightRow: View {
    let entry: EntrySnapshot
    let emojiWidth: CGFloat

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        AdaptiveStack(hAlignment: .center, spacing: 12) {
            EmojiText(entry.emotion.emoji, size: 30, relativeTo: .title2)
                .frame(width: dynamicTypeSize.isAccessibilitySize ? nil : emojiWidth)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.text)
                    .font(.body)                                        // lineLimit을 걸지 않는다
                Text(entry.day.formattedMonthDay)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .frame(minHeight: 56)                                           // 누르는 영역 최소 44pt
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(entry.emotion.name), \(entry.text), \(entry.day.formattedFull)")
        .accessibilityAddTraits(.isButton)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        MonthView()
    }
    .environment(AppRouter())
    .modelContainer(.preview)
    .tint(.indigo)
}

#Preview("기록 없음") {
    NavigationStack {
        MonthView()
    }
    .environment(AppRouter())
    .modelContainer(try! AppContainer.make(inMemory: true))
    .tint(.indigo)
}
#endif
