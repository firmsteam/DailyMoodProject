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
            VStack(alignment: .leading, spacing: 16) {
                RecordHeader(today: today)

                emptyEmotionCard
                    .padding(.horizontal)
                RecordCardRow {
                    questionCard.recordCardWidth()
                    streakCard.recordCardWidth()
                }
                RecordEntryList(entries: entries)
                    .padding(.horizontal)
                    .padding(.top, 8)
            }
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - REC-11 · 13

    private var emptyEmotionCard: some View {
        Card(cornerRadius: 32) {
            VStack(alignment: .leading, spacing: 16) {
                Label("오늘의 감정", systemImage: "face.smiling")
                    .font(.headline)
                    .foregroundStyle(.tint)

                HStack(spacing: 16) {
                    DashedCircle()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("오늘은 어떤 하루였나요?").font(.title3.bold())
                        Text("이모지 하나와 한 줄로 남겨요")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }

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
            Card(cornerRadius: 28) {
                VStack(alignment: .leading, spacing: 10) {
                    Label("오늘의 질문", systemImage: "bubble.left")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.tint)
                    Text(question)
                        .font(.callout.weight(.bold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                    Text("탭하면 한 줄 쓰기로 이어져요")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityHint("한 줄 입력칸이 바로 열려요")
    }

    // MARK: - REC-15

    private var streakCard: some View {
        Card(cornerRadius: 28) {
            VStack(alignment: .leading, spacing: 8) {
                Label("연속 기록", systemImage: "flame")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.orange)
                HStack(alignment: .center) {
                    Text("\(streak)일").font(.system(size: 36, weight: .bold))
                    Spacer(minLength: 8)
                    streakDots
                }
                Text("오늘 기록하면 \(streak + 1)일째예요")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
        }
    }

    /// 어제까지 기록한 날은 채운 점, 오늘은 테두리만 있는 점이다. 최대 5개까지 보여 준다.
    private var streakDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<min(streak, 4), id: \.self) { _ in
                Circle().fill(.orange).frame(width: 14, height: 14)
            }
            Circle().strokeBorder(.orange, lineWidth: 2).frame(width: 14, height: 14)
        }
        .accessibilityHidden(true)
    }
}

/// 점선 원. 아직 고른 감정이 없다는 뜻이다. (REC-11)
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
