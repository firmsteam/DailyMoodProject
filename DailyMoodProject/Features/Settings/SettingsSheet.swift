//
//  SettingsSheet.swift
//  DailyMoodProject
//

import SwiftUI
import SwiftData

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @AppStorage(SettingsKey.themeMode) private var theme: AppTheme = .system
    @AppStorage(SettingsKey.reminderEnabled) private var reminderEnabled = false
    @AppStorage(SettingsKey.reminderMinutes) private var reminderMinutes = SettingsDefault.reminderMinutes

    @State private var showDeleteAll = false
    @State private var deleteError = false

    /// 영역 사이 간격. 삭제 영역은 다른 영역보다 더 띄워서 실수로 누르기 어렵게 한다.
    private let sectionSpacing: CGFloat = 24
    private let deleteSectionSpacing: CGFloat = 44

    var body: some View {
        NavigationStack {
            Form {
                themeSection
                reminderSection
                aboutSection
                deleteSection
            }
            .listSectionSpacing(.custom(sectionSpacing))
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") { dismiss() }
                }
            }
            .alert("삭제하지 못했어요", isPresented: $deleteError) {
                Button("확인", role: .cancel) { }
            }
        }
        .tint(.indigo)
    }

    // MARK: - 섹션

    /// 화면 모드. 고르면 앱 전체에 바로 적용된다. (SET-02)
    private var themeSection: some View {
        Section {
            Picker("화면 모드", selection: $theme) {
                ForEach(AppTheme.allCases) { option in
                    Label(option.title, systemImage: option.systemImage).tag(option)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        } header: {
            Text("화면 모드")
        } footer: {
            Text("'시스템 설정'을 선택하면 기기의 화면 모드를 자동으로 따라가요.")
        }
    }

    /// 매일 기록 알림. 시간은 알림을 켰을 때만 보인다. (SET-03, SET-04)
    private var reminderSection: some View {
        Section {
            Toggle(isOn: $reminderEnabled) {
                SettingsLabel("매일 기록 알림", systemImage: "bell.fill", color: .red)
            }
            if reminderEnabled {
                DatePicker(selection: reminderTime, displayedComponents: .hourAndMinute) {
                    SettingsLabel("알림 시간", systemImage: "clock.fill", color: .orange)
                }
            }
        } header: {
            Text("알림")
        } footer: {
            Text("정한 시간에 오늘의 감정을 기록하도록 알려드려요.")
        }
    }

    /// 앱 버전. (SET-08)
    private var aboutSection: some View {
        Section("정보") {
            LabeledContent {
                Text(appVersion)
            } label: {
                SettingsLabel("버전", systemImage: "info.circle.fill", color: .gray)
            }
        }
        .listSectionSpacing(.custom(deleteSectionSpacing))      // 삭제 영역과의 간격
    }

    /// 모든 기록 삭제. 확인창은 누른 버튼 위에 나온다. (SET-09, ⑧-1)
    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                showDeleteAll = true
            } label: {
                Text("모든 기록 삭제")
                    .frame(maxWidth: .infinity)
            }
            .confirmationDialog(
                "모든 기록을 삭제할까요?",
                isPresented: $showDeleteAll,
                titleVisibility: .visible
            ) {
                Button("모든 기록 삭제", role: .destructive) { deleteAll() }
                Button("취소", role: .cancel) { }
            } message: {
                Text("삭제한 기록은 되돌릴 수 없어요.")
            }
        } footer: {
            Text("삭제한 기록은 되돌릴 수 없어요.")
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - 값

    /// `@AppStorage`는 `Date`를 저장하지 못해서 자정부터 지난 분으로 바꿔 저장한다.
    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(
                    bySettingHour: reminderMinutes / 60,
                    minute: reminderMinutes % 60,
                    second: 0,
                    of: .now
                ) ?? .now
            },
            set: { newValue in
                let parts = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                reminderMinutes = (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
            }
        )
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
    }

    private func deleteAll() {
        do {
            try EntryStore(context: context).deleteAll()
        } catch {
            deleteError = true
        }
    }
}

/// 색 사각형 아이콘과 글자로 된 설정 행의 제목.
private struct SettingsLabel: View {
    let title: String
    let systemImage: String
    let color: Color

    init(_ title: String, systemImage: String, color: Color) {
        self.title = title
        self.systemImage = systemImage
        self.color = color
    }

    var body: some View {
        Label {
            Text(title)
        } icon: {
            SettingsIcon(systemImage: systemImage, color: color)
        }
    }
}

// MARK: - 화면에 보이는 이름

private extension AppTheme {
    var title: String {
        switch self {
        case .system: "시스템 설정"
        case .light: "라이트"
        case .dark: "다크"
        }
    }

    var systemImage: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max.fill"
        case .dark: "moon.fill"
        }
    }
}

#if DEBUG
#Preview("기본") {
    SettingsSheet()
        .modelContainer(.preview)
}

#Preview("AX5") {
    SettingsSheet()
        .modelContainer(.preview)
        .environment(\.dynamicTypeSize, .accessibility5)
}
#endif
