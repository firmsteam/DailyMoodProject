//
//  EntryEditorSheet.swift
//  DailyMoodProject
//

import SwiftUI
import SwiftData

/// 감정 기록 시트. 새 기록, 수정, 질문으로 진입하는 세 경우를 `mode`로 구분한다.
/// 수정할 기록을 찾아 입력 폼에 처음 값을 넘기는 역할만 한다.
struct EntryEditorSheet: View {
    let mode: EditorMode

    @Query private var matches: [MoodEntry]
    /// 시트를 연 시점에 정한 날. 연 채로 자정이 지나도 이 날짜로 저장한다.
    private let openedDay: DayKey

    init(mode: EditorMode) {
        self.mode = mode
        switch mode {
        case .new: openedDay = .today()
        case .edit(let day): openedDay = day
        }
        let key = openedDay.rawValue
        _matches = Query(filter: #Predicate<MoodEntry> { $0.dayKey == key })
    }

    var body: some View {
        switch mode {
        case .new(let prompt):
            EntryEditorForm(initial: EntryDraft(newOn: openedDay), prompt: prompt, isEditing: false)
        case .edit:
            if let entry = matches.first {
                EntryEditorForm(initial: EntryDraft(editing: entry.snapshot), prompt: nil, isEditing: true)
            } else {
                MissingEntryView()
            }
        }
    }
}

private struct EntryEditorForm: View {
    let prompt: String?
    let isEditing: Bool

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var draft: EntryDraft
    @State private var showDiscard = false
    @State private var saveError = false
    @FocusState private var textFocused: Bool

    init(initial: EntryDraft, prompt: String?, isEditing: Bool) {
        _draft = State(initialValue: initial)
        self.prompt = prompt
        self.isEditing = isEditing
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("날짜", value: draft.day.formattedFull)
                }

                Section("감정 선택") {
                    EmotionPickerGrid(selection: $draft.emotion)
                }

                Section {
                    AdaptiveStack(hAlignment: .firstTextBaseline, spacing: 8) {
                        TextField("한 줄", text: $draft.text, prompt: Text(prompt ?? "오늘 하루를 한 줄로 남겨요"))
                            .focused($textFocused)
                            .submitLabel(.done)
                        Text("\(draft.text.count) / \(EntryValidator.maxLength)")
                            .font(.subheadline)
                            .monospacedDigit()
                            .foregroundStyle(draft.text.count >= EntryValidator.maxLength
                                             ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                            .accessibilityLabel("\(draft.text.count)자, 최대 \(EntryValidator.maxLength)자")
                    }
                } header: {
                    Text("한 줄")
                } footer: {
                    Text("하루에 한 번만 기록할 수 있어요.")
                }
            }
            .navigationTitle(isEditing ? "기록 수정" : "오늘의 기록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { requestClose() }
                        .confirmationDialog("작성 중인 내용을 버릴까요?", isPresented: $showDiscard, titleVisibility: .visible) {
                            Button("내용 버리기", role: .destructive) { dismiss() }
                            Button("계속 작성", role: .cancel) { }
                        }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) { save() }
                        .disabled(!draft.canSave)
                }
            }
            .interactiveDismissDisabled(draft.hasUnsavedChanges)
            // 끌어서 닫아도 확인을 거치게
            .alert("저장하지 못했어요", isPresented: $saveError) {
                Button("확인", role: .cancel) { }
            }
            .onChange(of: draft.text) { _, newValue in
                // 40자를 넘기면 더 입력되지 않는다. (R-03)
                if newValue.count > EntryValidator.maxLength {
                    draft.text = String(newValue.prefix(EntryValidator.maxLength))
                }
            }
            .onAppear {
                // 질문 카드로 들어오면 한 줄 입력칸에 바로 포커스를 준다. (③-2)
                if prompt != nil { textFocused = true }
            }
        }
        .tint(.indigo)
    }

    private func requestClose() {
        if draft.hasUnsavedChanges {
            showDiscard = true
        } else {
            dismiss()
        }
    }

    private func save() {
        guard let emotion = draft.emotion, draft.canSave else { return }
        do {
            try EntryStore(context: context).save(day: draft.day, emotion: emotion, text: draft.text)
            dismiss()
        } catch {
            saveError = true
            // 시트는 닫지 않는다
        }
    }
}

/// 수정하려던 기록이 그 사이 삭제된 경우.
private struct MissingEntryView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ContentUnavailableView("삭제된 기록이에요", systemImage: "tray")
                .navigationTitle("기록 수정")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .close) { dismiss() }
                    }
                }
        }
    }
}

#if DEBUG
#Preview("새 기록") {
    EntryEditorSheet(mode: .new(prompt: nil))
        .modelContainer(.preview)
}

#Preview("질문으로 진입") {
    EntryEditorSheet(mode: .new(prompt: "오늘 가장 고마웠던 순간은?"))
        .modelContainer(.preview)
}

#Preview("기록 수정") {
    EntryEditorSheet(mode: .edit(PreviewData.today))
        .modelContainer(.preview)
}

#Preview("AX5") {
    EntryEditorSheet(mode: .edit(PreviewData.today))
        .modelContainer(.preview)
        .environment(\.dynamicTypeSize, .accessibility5)
}
#endif
