//
//  EntryDetailView.swift
//  DailyMoodProject
//

import SwiftUI
import SwiftData

/// 기록 관리(⑦). 기록 하나를 자세히 보고 수정하거나 삭제한다.
/// 모델 객체가 아니라 `DayKey`를 받아서, 삭제된 기록을 가리키는 일이 없게 한다.
/// - DTL-01 뒤로·제목, DTL-02 기록 내용, DTL-03 정보 목록, DTL-04 안내 문구
/// - DTL-05 수정, DTL-06 삭제 버튼, DTL-07 삭제 확인
struct EntryDetailView: View {
    let day: DayKey

    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var entries: [MoodEntry]

    @State private var confirmsDelete = false
    @State private var deleteFailed = false

    private let today: DayKey

    init(day: DayKey, today: DayKey = .today()) {
        self.day = day
        self.today = today
        let key = day.rawValue
        _entries = Query(filter: #Predicate<MoodEntry> { $0.dayKey == key })
    }

    private var entry: MoodEntry? { entries.first }

    /// 새 기록은 오늘만 남길 수 있어서(R-05), "삭제 후 다시 기록"은 오늘 기록에만 해당한다.
    private var canRerecord: Bool { day == today }

    var body: some View {
        Group {
            if let entry {
                content(for: entry.snapshot)
            } else {
                ContentUnavailableView("기록을 찾을 수 없어요", systemImage: "tray")
            }
        }
        .navigationTitle(day.formattedMonthDay)                 // DTL-01
        .navigationBarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)                // 하단 툴바가 보이도록 탭바를 숨긴다.
        .toolbar {
            if entry != nil {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("수정", systemImage: "pencil") {
                        router.sheet = .editor(.edit(day))       // DTL-05
                    }
                    .tint(.indigo)
                    deleteButton
                }
            }
        }
        .alert("삭제하지 못했어요", isPresented: $deleteFailed) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("잠시 후 다시 시도해 주세요.")
        }
    }

    // MARK: - 내용

    private func content(for entry: EntrySnapshot) -> some View {
        List {
            Section {
                hero(for: entry)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }

            Section {
                LabeledContent("기록 시각", value: time(entry.createdAt))
                if let modifiedAt = entry.modifiedAt {           // 수정한 적이 있을 때만 보여 준다. (DTL-03)
                    LabeledContent("수정 시각", value: time(modifiedAt))
                }
                LabeledContent("글자 수", value: "\(entry.text.count) / \(EntryValidator.maxLength)")
            } footer: {
                Text(footerText)                                  // DTL-04
            }
        }
    }

    /// 큰 이모지, 한 줄, 날짜와 기록 시각. (DTL-02)
    private func hero(for entry: EntrySnapshot) -> some View {
        VStack(spacing: 12) {
            EmojiText(entry.emotion.emoji, size: 76, relativeTo: .largeTitle)
                .accessibilityHidden(true)
            Text(entry.text)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text("\(day.formattedFull) · \(time(entry.createdAt))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(entry.emotion.name), \(entry.text), \(day.formattedFull), \(time(entry.createdAt))")
    }

    private var footerText: String {
        canRerecord
            ? "하루에 한 번만 기록할 수 있어요. 수정은 언제든 가능하고, 삭제하면 오늘 다시 기록할 수 있어요."
            : "하루에 한 번만 기록할 수 있어요. 수정은 언제든 가능해요."
    }

    // MARK: - 삭제 (DTL-06, DTL-07)

    private var deleteButton: some View {
        Button("삭제", systemImage: "trash", role: .destructive) {
            confirmsDelete = true
        }
        .tint(.red)
        .confirmationDialog(
            "이 기록을 삭제할까요?",
            isPresented: $confirmsDelete,
            titleVisibility: .visible
        ) {
            Button("기록 삭제", role: .destructive, action: delete)
            Button("취소", role: .cancel) {}
        } message: {
            Text(canRerecord
                 ? "삭제한 기록은 되돌릴 수 없어요.\n삭제 후 오늘 다시 기록할 수 있어요."
                 : "삭제한 기록은 되돌릴 수 없어요.")
        }
    }

    /// 기록을 지우고 이전 화면으로 돌아간다. 연속 기록과 통계는 저장하지 않고 날짜로 계산하므로 따로 고칠 것이 없다.
    private func delete() {
        do {
            try EntryStore(context: context).delete(day: day)
            dismiss()
        } catch {
            deleteFailed = true
        }
    }

    private func time(_ date: Date) -> String {
        date.formatted(.dateTime.hour().minute().locale(Locale(identifier: "ko_KR")))
    }
}

#if DEBUG
#Preview("오늘 기록") {
    NavigationStack {
        EntryDetailView(day: PreviewData.today, today: PreviewData.today)
    }
    .environment(AppRouter())
    .modelContainer(.preview)
}

#Preview("지난 날 기록") {
    NavigationStack {
        EntryDetailView(day: DayKey(rawValue: 20250512), today: PreviewData.today)
    }
    .environment(AppRouter())
    .modelContainer(.preview)
}
#endif
