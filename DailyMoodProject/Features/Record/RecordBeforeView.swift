//
//  RecordBeforeView.swift
//  DailyMoodProject
//

import SwiftUI

/// 기록 탭 · 오늘 기록 전(②). 버튼이나 오늘의 질문으로 부담 없이 기록을 시작하게 한다. (REC-11~17)
/// 다른 화면과 겹치지 않게 이 화면에서만 쓰는 부품은 모두 이 파일 안에 `private`으로 둔다.
struct RecordBeforeView: View {
    /// 오늘의 질문 후보. 이 중에서 무작위로 고르고, 목록은 이후에 늘린다. (REC-14)
    private static let questions = [
        "오늘 가장 고마웠던 순간은?",
    ]

    let today: DayKey
    /// 날짜 내림차순.
    let entries: [EntrySnapshot]

    @Environment(AppRouter.self) private var router
    /// 화면이 만들어질 때 한 번 고른다. 다시 그려져도 질문이 바뀌지 않는다.
    @State private var question = Self.questions.randomElement() ?? ""

    /// 어제까지 이어진 연속 기록 일수. (R-07)
    private var streak: Int {
        BeforeRecordStreak.days(before: today, recorded: Set(entries.map(\.day)))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                emptyEmotionCard
                questionCard
                streakCard
                BeforeRecordEntryList(entries: entries)
                    .padding(.top, 8)
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - REC-11 · 13

    private var emptyEmotionCard: some View {
        Card {
            VStack(spacing: 16) {
                DashedCircle()
                VStack(spacing: 4) {
                    Text("오늘은 어떤 하루였나요?").font(.title3.bold())
                    Text("이모지 하나와 한 줄로 남겨요")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)

                Button {
                    router.sheet = .editor(.new(prompt: nil))
                } label: {
                    Text("오늘의 감정 기록하기")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - REC-14

    private var questionCard: some View {
        Button {
            router.sheet = .editor(.new(prompt: question))
        } label: {
            Card {
                AdaptiveStack(hAlignment: .center, spacing: 12) {
                    Image(systemName: "text.bubble")
                        .font(.title3)
                        .foregroundStyle(.tint)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("오늘의 질문")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(question).font(.callout.weight(.semibold))
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                }
                .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
        .accessibilityHint("한 줄 입력칸이 바로 열려요")
    }

    // MARK: - REC-15

    private var streakCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 4) {
                Label("연속 기록", systemImage: "flame.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.orange)
                Text("\(streak)일").font(.title.bold())
                Text("오늘 기록하면 \(streak + 1)일째예요")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
        }
    }
}

/// 점선 원. 아직 고른 감정이 없다는 뜻이다. (REC-11)
private struct DashedCircle: View {
    @ScaledMetric private var size: CGFloat = 84

    var body: some View {
        // 글자를 아주 크게 해도 원이 화면을 다 차지하지 않게 상한을 둔다.
        let side = min(size, 120)
        Circle()
            .strokeBorder(.tertiary, style: StrokeStyle(lineWidth: 2, dash: [6, 5]))
            .frame(width: side, height: side)
            .overlay {
                Image(systemName: "face.smiling")
                    .font(.title)
                    .foregroundStyle(.tertiary)
            }
            .accessibilityHidden(true)
    }
}

/// 연속 기록 계산. 오늘 기록 전에는 어제부터 거꾸로 하루도 빠지지 않은 날 수를 센다. (R-07)
private enum BeforeRecordStreak {
    static func days(before today: DayKey, recorded: Set<DayKey>) -> Int {
        var count = 0
        var cursor = today.adding(days: -1)
        while recorded.contains(cursor) {
            count += 1
            cursor = cursor.adding(days: -1)
        }
        return count
    }
}

/// 감정별 기록. 감정 칩으로 목록을 걸러 보고, 행을 누르면 기록 관리(⑦)로 이동한다. (REC-17, REC-09·10)
private struct BeforeRecordEntryList: View {
    /// 날짜 내림차순(최근 기록이 위).
    let entries: [EntrySnapshot]

    @State private var selected: Emotion?

    /// 기록이 있는 감정만, 많은 순으로 둔다. 개수가 같으면 점수가 높은 감정이 먼저다. (R-10, R-16)
    private var emotionCounts: [(emotion: Emotion, count: Int)] {
        Dictionary(grouping: entries, by: \.emotion)
            .map { (emotion: $0.key, count: $0.value.count) }
            .sorted { ($0.count, $0.emotion.score) > ($1.count, $1.emotion.score) }
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
                ForEach(emotionCounts, id: \.emotion) { item in
                    EmotionChip(emotion: item.emotion, count: item.count, isSelected: activeFilter == item.emotion) {
                        selected = item.emotion
                    }
                }
            }
        }
    }
}

#if DEBUG
#Preview("기록 전") {
    NavigationStack {
        RecordBeforeView(today: DayKey(rawValue: 20250515), entries: PreviewData.entries.reversed())
    }
    .environment(AppRouter())
    .tint(.indigo)
}

#Preview("처음 설치") {
    NavigationStack {
        RecordBeforeView(today: DayKey(rawValue: 20250515), entries: [])
    }
    .environment(AppRouter())
}

#Preview("AX5") {
    NavigationStack {
        RecordBeforeView(today: DayKey(rawValue: 20250515), entries: PreviewData.entries.reversed())
    }
    .environment(AppRouter())
    .environment(\.dynamicTypeSize, .accessibility5)
}
#endif
