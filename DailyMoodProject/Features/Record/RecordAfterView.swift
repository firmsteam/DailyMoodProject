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
            VStack(alignment: .leading, spacing: 0) {
                RecordHeader(today: today)

                todayCard
                    .padding(.horizontal, 16)

                RecordCardRow {
                    RecordStreakCard(
                        days: streak.current,
                        caption: streak.message,
                        today: today,
                        recorded: Set(entries.map(\.day))
                    )
                    if let insight = InsightCard(entries: entries) {
                        insight
                    }
                }

                RecordEntryList(entries: entries)
            }
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - REC-03 · 04

    private var todayCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 0) {
                Label("오늘의 감정", systemImage: "face.smiling")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.tint)
                    .frame(minHeight: 21, alignment: .leading)      // 시안의 카드 높이 185를 맞춘다

                AdaptiveStack(hAlignment: .center, spacing: 14) {
                    EmojiCircle(emoji: todayEntry.emotion.emoji)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(todayEntry.emotion.name).font(.title3.weight(.semibold))
                        Text(todayEntry.text)
                            .font(.subheadline)
                            .foregroundStyle(.primary.opacity(0.75))
                    }
                    Spacer(minLength: 0)
                }
                .accessibilityElement(children: .combine)
                .padding(.top, 10)
                .padding(.bottom, 14)

                Button {
                    router.sheet = .editor(.edit(todayEntry.day))
                } label: {
                    Label("오늘 기록 수정", systemImage: "pencil")
                        .font(.headline)
                        .foregroundStyle(.tint)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(.tint.opacity(0.12), in: Capsule())
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
            .fill(Color(.tertiarySystemFill))
            .frame(width: side, height: side)
            .overlay { Text(emoji).font(.system(size: side * 0.625)) }
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
        RecordMiniCard {
            RecordMiniHeader(title: "인사이트", systemImage: "lightbulb", color: .green)
            Spacer(minLength: 0)
            HStack(spacing: 8) {
                EmojiText(emotion.emoji, size: 28, relativeTo: .title)
                Text("\(days)일").font(.title.bold())
            }
            Spacer(minLength: 0)
            Text(sentence)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("인사이트, \(sentence), \(days)일")
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
