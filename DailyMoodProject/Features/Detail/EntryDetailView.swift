//
//  EntryDetailView.swift
//  DailyMoodProject
//

import SwiftUI
import SwiftData

/// 기록 관리(⑦). 모델 객체가 아니라 `DayKey`를 받아서, 삭제된 기록을 가리키는 일이 없게 한다.
/// 기록 하나를 보여 주고 수정(③ 시트)과 삭제를 맡는다. (DTL-01~07)
struct EntryDetailView: View {
    let day: DayKey

    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var matches: [MoodEntry]
    @State private var showDeleteConfirm = false
    @State private var deleteError = false

    init(day: DayKey) {
        self.day = day
        let key = day.rawValue
        _matches = Query(filter: #Predicate<MoodEntry> { $0.dayKey == key })
    }

    var body: some View {
        Group {
            if let entry = matches.first {
                content(for: entry.snapshot)
            } else {
                ContentUnavailableView("기록이 없어요", systemImage: "tray")
            }
        }
        .navigationTitle(day.formattedMonthDay)
        .navigationBarTitleDisplayMode(.inline)
        .alert("삭제하지 못했어요", isPresented: $deleteError) {
            Button("확인", role: .cancel) { }
        }
    }

    private func content(for entry: EntrySnapshot) -> some View {
        List {
            // DTL-02 기록 내용
            Section {
                VStack(spacing: 12) {
                    EmojiText(entry.emotion.emoji, size: 76, relativeTo: .largeTitle)
                    Text(entry.text)
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                    Text("\(entry.day.formattedFull) · \(entry.createdAt.formatted(Self.timeStyle))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .accessibilityElement(children: .combine)
            }

            // DTL-03 정보 목록. 수정한 적이 없으면 수정 시각 행을 숨긴다. (R-04)
            Section {
                LabeledContent("기록 시각", value: entry.createdAt.formatted(Self.timeStyle))
                if let modifiedAt = entry.modifiedAt {
                    LabeledContent("수정 시각", value: modifiedAt.formatted(Self.timeStyle))
                }
                LabeledContent("글자 수", value: "\(entry.text.count) / \(EntryValidator.maxLength)")
            } footer: {
                // DTL-04
                Text("하루에 한 번만 기록할 수 있어요. 수정은 언제든 가능하고, 삭제하면 오늘 다시 기록할 수 있어요.")
            }

            Section {
                // DTL-05 수정
                Button("수정", systemImage: "pencil") {
                    router.sheet = .editor(.edit(day))
                }
                // DTL-06 삭제
                Button("삭제", systemImage: "trash", role: .destructive) {
                    showDeleteConfirm = true
                }
                .confirmationDialog(
                    "이 기록을 삭제할까요?",
                    isPresented: $showDeleteConfirm,
                    titleVisibility: .visible
                ) {
                    // DTL-07
                    Button("기록 삭제", role: .destructive) { delete() }
                    Button("취소", role: .cancel) { }
                } message: {
                    Text("삭제한 기록은 되돌릴 수 없어요. 삭제 후 오늘 다시 기록할 수 있어요.")
                }
            }
        }
    }

    private func delete() {
        do {
            try EntryStore(context: context).delete(day: day)
            dismiss()
        } catch {
            deleteError = true
        }
    }

    /// 오후 9:12
    private static let timeStyle = Date.FormatStyle(date: .omitted, time: .shortened)
        .locale(Locale(identifier: "ko_KR"))
}

#if DEBUG
#Preview("기록 있음") {
    NavigationStack {
        EntryDetailView(day: PreviewData.today)
    }
    .environment(AppRouter())
    .modelContainer(.preview)
}

#Preview("기록 없음") {
    NavigationStack {
        EntryDetailView(day: DayKey(rawValue: 20250504))
    }
    .environment(AppRouter())
    .modelContainer(.preview)
}
#endif
