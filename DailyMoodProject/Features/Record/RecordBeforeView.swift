//
//  RecordBeforeView.swift
//  DailyMoodProject
//

import SwiftUI

/// 기록 탭 · 오늘 기록 전(②). 버튼이나 오늘의 질문으로 부담 없이 기록을 시작하게 한다. (REC-08, 11~17)
/// 기록 후 화면(①)과 겹치는 부품(제목, 카드 줄, 감정별 기록)은 `RecordCommon.swift`에 있다.
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
            VStack(alignment: .leading, spacing: 0) {
                RecordHeader(today: today)

                emptyEmotionCard
                    .padding(.horizontal, 16)

                RecordCardRow {
                    questionCard
                    RecordStreakCard(
                        days: streak,
                        caption: "오늘 기록하면 \(streak + 1)일째예요",
                        today: today,
                        recorded: Set(entries.map(\.day))
                    )
                }

                RecordEntryList(entries: entries)
            }
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - REC-11 · 13

    private var emptyEmotionCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 0) {
                Label("오늘의 감정", systemImage: "face.smiling")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.tint)
                    .frame(minHeight: 21, alignment: .leading)      // 시안의 카드 높이 185를 맞춘다

                AdaptiveStack(hAlignment: .center, spacing: 14) {
                    DashedCircle()
                    VStack(alignment: .leading, spacing: 3) {
                        Text("오늘은 어떤 하루였나요?").font(.title3.weight(.semibold))
                        Text("이모지 하나와 한 줄로 남겨요")
                            .font(.subheadline)
                            .foregroundStyle(.primary.opacity(0.75))
                    }
                    Spacer(minLength: 0)
                }
                .padding(.top, 10)
                .padding(.bottom, 14)

                Button {
                    router.sheet = .editor(.new(prompt: nil))
                } label: {
                    Label("오늘의 감정 기록하기", systemImage: "plus")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(.tint, in: Capsule())
                        .shadow(color: .accentColor.opacity(0.3), radius: 10, y: 5)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - REC-14

    private var questionCard: some View {
        Button {
            router.sheet = .editor(.new(prompt: question))
        } label: {
            RecordMiniCard {
                RecordMiniHeader(title: "오늘의 질문", systemImage: "bubble.left", color: .accentColor)
                Spacer(minLength: 0)
                Text(question)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
                Text("탭하면 한 줄 쓰기로 이어져요")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
        .accessibilityHint("한 줄 입력칸이 바로 열려요")
    }
}

/// 점선 원. 아직 고른 감정이 없다는 뜻이다. 시안은 64pt 원, 안의 아이콘 32pt. (REC-11)
private struct DashedCircle: View {
    @ScaledMetric private var size: CGFloat = 64

    var body: some View {
        // 글자를 아주 크게 해도 원이 화면을 다 차지하지 않게 상한을 둔다.
        let side = min(size, 96)
        Circle()
            .strokeBorder(Color(.systemGray4), style: StrokeStyle(lineWidth: 2, dash: [5, 4]))
            .frame(width: side, height: side)
            .overlay {
                Image(systemName: "face.smiling")
                    .font(.system(size: side * 0.5))
                    .foregroundStyle(Color(.systemGray3))
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

#if DEBUG
#Preview("기록 전") {
    NavigationStack {
        RecordBeforeView(today: DayKey(rawValue: 20250514), entries: PreviewData.entries.reversed())
    }
    .environment(AppRouter())
    .tint(.indigo)
}

#Preview("처음 설치") {
    NavigationStack {
        RecordBeforeView(today: DayKey(rawValue: 20250514), entries: [])
    }
    .environment(AppRouter())
    .tint(.indigo)
}

#Preview("AX5") {
    NavigationStack {
        RecordBeforeView(today: DayKey(rawValue: 20250514), entries: PreviewData.entries.reversed())
    }
    .environment(AppRouter())
    .environment(\.dynamicTypeSize, .accessibility5)
    .tint(.indigo)
}
#endif
