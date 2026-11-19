//
//  RecordAfterView.swift
//  DailyMoodProject
//

import SwiftUI

/// 기록 탭 · 오늘 기록 후(①). 오늘의 감정을 확인하고, 연속 기록과 인사이트로 돌아보고,
/// 지난 기록을 감정별로 걸러 본다. (REC-03~10)
/// 기록 전 화면(②)과 겹치는 부품은 `RecordCommon.swift`에 있다.
struct RecordAfterView: View {
    let today: DayKey
    /// 오늘 기록.
    let todayEntry: EntrySnapshot
    /// 날짜 내림차순. 오늘 기록도 들어 있다.
    let entries: [EntrySnapshot]

    @Environment(AppRouter.self) private var router

    var body: some View {
        let streak = StreakStats.info(entries, today: today)

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                RecordHeader(today: today)

                todayCard
                    .padding(.horizontal)

                RecordCardRow {
                    StreakCard(info: streak, today: today, recorded: Set(entries.map(\.day)))
                        .recordCardWidth()
                    if let insight = InsightCard(entries: entries) {
                        insight.recordCardWidth()
                    }
                }

                RecordEntryList(entries: entries)
                    .padding(.horizontal)
                    .padding(.top, 8)
            }
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - REC-03 · 04

    private var todayCard: some View {
        Card(cornerRadius: 32) {
            VStack(alignment: .leading, spacing: 16) {
                Label("오늘의 감정", systemImage: "face.smiling")
                    .font(.headline)
                    .foregroundStyle(.tint)

                AdaptiveStack(hAlignment: .center, spacing: 16) {
                    EmojiCircle(emoji: todayEntry.emotion.emoji)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(todayEntry.emotion.name).font(.title2.bold())
                        Text(todayEntry.text)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .accessibilityElement(children: .combine)

                Button {
                    router.sheet = .editor(.edit(todayEntry.day))
                } label: {
                    Label("오늘 기록 수정", systemImage: "pencil")
                        .font(.headline)
                        .foregroundStyle(.tint)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(.tint.opacity(0.15), in: Capsule())
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// 오늘 고른 이모지를 담는 둥근 배경. (REC-03)
private struct EmojiCircle: View {
    let emoji: String
    @ScaledMetric private var size: CGFloat = 64

    var body: some View {
        // 글자를 아주 크게 해도 원이 화면을 다 차지하지 않게 상한을 둔다.
        let side = min(size, 96)
        Circle()
            .fill(Color(.systemGray6))
            .frame(width: side, height: side)
            .overlay { Text(emoji).font(.system(size: side * 0.6)) }
            .accessibilityHidden(true)
    }
}

// MARK: - REC-05

/// 연속 일수, 이번 주 일~토 7개 점, 이전 최장 기록과 비교한 문구.
private struct StreakCard: View {
    let info: StreakInfo
    let today: DayKey
    let recorded: Set<DayKey>

    var body: some View {
        Card(cornerRadius: 28) {
            VStack(alignment: .leading, spacing: 8) {
                Label("연속 기록", systemImage: "flame")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.orange)
                HStack(alignment: .center) {
                    Text("\(info.current)일").font(.system(size: 36, weight: .bold))
                    Spacer(minLength: 8)
                    weekDots
                }
                Text(info.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("연속 기록, \(info.current)일, \(info.message)")
        }
    }

    /// 이번 주 일요일부터 토요일까지. 기록한 날은 채운 점이다.
    private var weekDots: some View {
        HStack(spacing: 6) {
            ForEach(WeekRange(containing: today).days, id: \.self) { day in
                Circle()
                    .fill(recorded.contains(day) ? AnyShapeStyle(.orange) : AnyShapeStyle(Color(.systemGray5)))
                    .frame(width: 14, height: 14)
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - REC-07

/// 가장 많이 기록한 감정과 일수, 비율. 기록이 없으면 만들어지지 않는다. (R-12)
private struct InsightCard: View {
    let emotion: Emotion
    let days: Int
    let sentence: String

    init?(entries: [EntrySnapshot]) {
        guard let top = PeriodStats.distribution(entries).first else { return nil }
        emotion = top.emotion
        days = top.days
        sentence = InsightText.sentence(
            emotion: top.emotion,
            percent: PeriodStats.recordRate(recordedDays: top.days, elapsedDays: entries.count)
        )
    }

    var body: some View {
        Card(cornerRadius: 28) {
            VStack(alignment: .leading, spacing: 8) {
                Label("인사이트", systemImage: "lightbulb")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.green)
                HStack(spacing: 8) {
                    EmojiText(emotion.emoji, size: 36, relativeTo: .largeTitle)
                    Text("\(days)일").font(.system(size: 36, weight: .bold))
                }
                Text(sentence)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("인사이트, \(sentence), \(days)일")
        }
    }
}

#if DEBUG
#Preview("기록 후") {
    let entries = Array(PreviewData.entries.reversed())
    NavigationStack {
        RecordAfterView(today: PreviewData.today, todayEntry: entries[0], entries: entries)
    }
    .environment(AppRouter())
    .tint(.indigo)
}

#Preview("AX5") {
    let entries = Array(PreviewData.entries.reversed())
    NavigationStack {
        RecordAfterView(today: PreviewData.today, todayEntry: entries[0], entries: entries)
    }
    .environment(AppRouter())
    .environment(\.dynamicTypeSize, .accessibility5)
    .tint(.indigo)
}
#endif
