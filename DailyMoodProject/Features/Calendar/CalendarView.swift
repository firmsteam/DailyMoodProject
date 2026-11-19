//
//  CalendarView.swift
//  DailyMoodProject
//

import SwiftUI
import SwiftData

/// 달력 탭(④). 한 달을 격자로 보여 주고, 기록이 있는 날을 누르면 아래에 그날의 기록을 보여 준다.
/// - CAL-01 제목, CAL-02 달 이동, CAL-04 요일 줄, CAL-05 날짜 칸
/// - CAL-06 날짜 칸 누르기, CAL-07 선택한 날 영역, CAL-08 지난 기록
/// - 제목의 연도를 누르면 팝오버에서 원하는 연도로 바로 이동한다.
/// - 날짜 칸을 누르면 그 날을 선택하고, 기록이 없는 날은 선택한 날 영역에서 기록한다.
/// - ADD-05 저장 알림, ADD-13 "나중에 기록" 표시
struct CalendarView: View {
    @Environment(AppRouter.self) private var router
    @Query private var entries: [MoodEntry]

    /// 화면에 보이는 달의 1일.
    @State private var monthStart: DayKey
    /// 아래 영역에 보여 줄 날. 기록이 없는 달로 옮기면 `nil`이다.
    @State private var selected: DayKey?
    /// 지난 날 기록을 저장한 뒤 2초 동안 보여 주는 알림. (ADD-05)
    @State private var toastText: String?
    /// 연도 고르기 팝오버.
    @State private var showsYearPicker = false

    /// 미리보기에서 "오늘"을 고정하는 용도. 실제 앱에서는 `nil`이라 매번 현재 날짜를 쓴다.
    private let fixedToday: DayKey?
    private var today: DayKey { fixedToday ?? .today() }

    private let calendar = Calendar.app

    init(today: DayKey? = nil) {
        fixedToday = today
        let base = today ?? .today()
        _monthStart = State(initialValue: base.firstOfMonth)
        _selected = State(initialValue: base)
    }

    var body: some View {
        // 날짜별 조회가 칸마다 반복되지 않게 한 번만 만든다.
        let byDay = entriesByDay

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                titleBlock(byDay: byDay)
                weekdayHeader
                monthGrid(byDay: byDay)
                selectedDayArea(byDay: byDay)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("달력")                       // 뒤로 가기 버튼의 이름으로만 쓴다.
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(removing: .title)
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button("이전 달", systemImage: "chevron.left") { moveMonth(by: -1, byDay: byDay) }
                    .disabled(!canMoveToPreviousMonth)       // 가장 이른 날이 있는 달에서는 비활성
                Button("다음 달", systemImage: "chevron.right") { moveMonth(by: 1, byDay: byDay) }
                    .disabled(!canMoveToNextMonth)           // 이번 달에서는 비활성 (CAL-02)
            }
            ToolbarItem(placement: .primaryAction) {
                // 모양만 보여 주는 ＋. 버튼이 아니라서 눌러도 아무 반응이 없다.
                Image(systemName: "plus")
                    .accessibilityHidden(true)
            }
        }
        .overlay(alignment: .bottom) { toast }
        .onChange(of: router.savedEntry) { _, saved in
            guard let saved else { return }
            showSaved(saved.day)
        }
        .onChange(of: Set(entries.map(\.dayKey))) { _, days in
            // 선택한 날의 기록이 사라졌어도(삭제) 기록할 수 있는 날이면 그대로 둔다. 기록할 수 없는 날이면 오늘로 돌아간다. (CAL-06)
            guard let selected, !days.contains(selected.rawValue),
                  !EntryValidator.isRecordable(selected, today: today) else { return }
            self.selected = today
            monthStart = today.firstOfMonth
        }
    }

    // MARK: - 제목 (CAL-01)

    /// 연도를 누르면 연도 고르기 팝오버가 열린다. 월은 누를 수 없고, 달 이동은 툴바의 화살표로 한다.
    private func titleBlock(byDay: [DayKey: MoodEntry]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button { showsYearPicker = true } label: {
                Text(verbatim: "\(monthStart.year)년")          // 연도에 쉼표(2,026)가 붙지 않게 한다.
                    .font(.headline)
                    .foregroundStyle(.tint)
                    .frame(minHeight: 44, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showsYearPicker) { yearPicker(byDay: byDay) }
            .accessibilityLabel("\(monthStart.year)년")
            .accessibilityHint("눌러서 연도 이동")

            Text("\(monthStart.month)월")
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)
        }
        .padding(.top, 4)
        .padding(.bottom, 12)
    }

    /// 연도를 휠로 고른다. 고르는 즉시 달력이 그 해의 같은 달로 옮겨 가고, 이번 달 이후는 고를 수 없다.
    private func yearPicker(byDay: [DayKey: MoodEntry]) -> some View {
        let years = Array(EntryValidator.earliestDay.year...today.year)

        return Picker("연도", selection: Binding(
            get: { monthStart.year },
            set: { jump(toYear: $0, month: monthStart.month, byDay: byDay) }
        )) {
            ForEach(years, id: \.self) { Text(verbatim: "\($0)년").tag($0) }
        }
        .pickerStyle(.wheel)
        .frame(width: 160, height: 180)
        .padding(.horizontal)
        .presentationCompactAdaptation(.popover)               // 아이폰에서도 시트가 아니라 팝오버로 보여 준다.
    }

    // MARK: - 요일 줄 (CAL-04)

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            // `firstWeekday`가 일요일(1)이라 기호 배열의 순서가 곧 화면 순서다.
            ForEach(Array(calendar.veryShortStandaloneWeekdaySymbols.enumerated()), id: \.offset) { index, symbol in
                Text(symbol)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(index == 0 ? Color.red : .secondary)   // 일요일은 빨간색 (R-13)
                    .frame(maxWidth: .infinity)
                    .accessibilityHidden(true)                               // 날짜 칸이 요일까지 읽는다.
            }
        }
        .padding(.bottom, 8)
        .cappedDynamicType()
    }

    // MARK: - 날짜 격자 (CAL-05, CAL-06)

    private func monthGrid(byDay: [DayKey: MoodEntry]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(CalendarGrid.weeks(of: monthStart).enumerated()), id: \.offset) { _, week in
                Divider()
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { column in
                        cell(for: week[column], byDay: byDay)
                    }
                }
            }
            Divider()
        }
        .cappedDynamicType()                    // 칸 수가 정해진 격자라 글자 크기 상한을 둔다.
    }

    @ViewBuilder
    private func cell(for day: DayKey?, byDay: [DayKey: MoodEntry]) -> some View {
        if let day {
            let entry = byDay[day]
            // 기록이 있는 날과 기록할 수 있는 날(오늘까지의 모든 날)을 선택할 수 있다.
            let isSelectable = entry != nil || EntryValidator.isRecordable(day, today: today)
            let content = DayCell(
                day: day,
                emotion: entry?.emotion,
                isToday: day == today,
                isFuture: day > today,
                isSelected: day == selected,
                isSelectable: isSelectable
            )
            if isSelectable {
                Button { selected = day } label: { content }
                    .buttonStyle(.plain)
            } else {
                // 미래 날짜는 눌러도 반응하지 않는다.
                content
            }
        } else {
            Color.clear.frame(maxWidth: .infinity)
        }
    }

    // MARK: - 선택한 날과 지난 기록 (CAL-07, CAL-08)

    @ViewBuilder
    private func selectedDayArea(byDay: [DayKey: MoodEntry]) -> some View {
        if let selected {
            VStack(alignment: .leading, spacing: 0) {
                selectedHeader(for: selected)
                if let entry = byDay[selected] {
                    NavigationLink(value: selected) {
                        CalendarRecordRow(
                            entry: entry.snapshot,
                            caption: timeCaption(for: entry.snapshot)
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    emptyDay
                }
                previousRecords(before: selected, byDay: byDay)
            }
        } else {
            Text("이 달에는 기록이 없어요")
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 56)
                .padding(.top, 16)
        }
    }

    private func selectedHeader(for day: DayKey) -> some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                Text(day.formattedFull)
                    .foregroundStyle(.secondary)
                if day == today {
                    Text("오늘")
                        .foregroundStyle(.tint)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 8)
        }
        .font(.subheadline.weight(.semibold))
        .padding(.top, 20)
        .padding(.bottom, 8)
        .padding(.horizontal, 4)
    }

    /// 기록이 없는 날. 달력에서는 새로 기록할 수 없어서 안내 문구만 보여 준다.
    private var emptyDay: some View {
        Text("아직 기록이 없어요")
            .font(.callout)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .padding(.vertical, 10)
            .padding(.horizontal, 4)
            .overlay(alignment: .bottom) { Divider() }
    }

    /// 선택한 날 이전의 기록을 최근 순으로 보여 준다. 없으면 제목도 숨긴다.
    @ViewBuilder
    private func previousRecords(before day: DayKey, byDay: [DayKey: MoodEntry]) -> some View {
        let previous = byDay.values
            .filter { $0.day < day }
            .sorted { $0.day > $1.day }
            .map(\.snapshot)

        if !previous.isEmpty {
            Text("지난 기록")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.top, 20)
                .padding(.bottom, 8)
                .padding(.horizontal, 4)
                .accessibilityAddTraits(.isHeader)

            LazyVStack(spacing: 0) {
                ForEach(previous) { entry in
                    NavigationLink(value: entry.day) {
                        CalendarRecordRow(entry: entry, caption: previousCaption(for: entry))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - 저장 알림 (ADD-05)

    @ViewBuilder
    private var toast: some View {
        if let toastText {
            Text(toastText)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(.regularMaterial, in: Capsule())
                .padding(.bottom, 24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .accessibilityHidden(true)                       // 같은 문구를 음성 안내로 따로 읽어 준다.
        }
    }

    /// 지난 기록 행의 보조 글. 나중에 남긴 기록은 "5월 10일 · 나중에 기록". (ADD-13)
    private func previousCaption(for entry: EntrySnapshot) -> String {
        entry.isRecordedLater ? "\(entry.day.formattedMonthDay) · 나중에 기록" : entry.day.formattedMonthDay
    }

    // MARK: - 동작

    /// 저장한 날로 달력을 옮기고 그 날을 선택한 뒤, 알림을 2초 동안 보여 준다. (ADD-05)
    private func showSaved(_ day: DayKey) {
        monthStart = day.firstOfMonth
        selected = day
        let message = "\(day.formattedMonthDay) 기록을 저장했어요"
        withAnimation { toastText = message }
        AccessibilityNotification.Announcement(message).post()
        Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled, toastText == message else { return }
            withAnimation { toastText = nil }
        }
    }

    private var canMoveToPreviousMonth: Bool {
        monthStart > EntryValidator.earliestDay.firstOfMonth
    }

    private var canMoveToNextMonth: Bool {
        monthStart < today.firstOfMonth
    }

    private func moveMonth(by value: Int, byDay: [DayKey: MoodEntry]) {
        let moved = monthStart.firstOfMonth(adding: value)
        guard moved <= today.firstOfMonth, moved >= EntryValidator.earliestDay.firstOfMonth else { return }   // 아직 오지 않은 달과 가장 이른 달 이전으로는 갈 수 없다.
        monthStart = moved
        selected = defaultSelection(in: moved, byDay: byDay)
    }

    /// 연도(와 월)를 골라 바로 이동한다. 이번 달보다 뒤로는 갈 수 없어서, 넘어서면 이번 달로 맞춘다.
    private func jump(toYear year: Int, month: Int, byDay: [DayKey: MoodEntry]) {
        let requested = DayKey(rawValue: year * 10_000 + month * 100 + 1)
        let target = min(requested, today.firstOfMonth)
        guard target != monthStart else { return }
        monthStart = target
        selected = defaultSelection(in: target, byDay: byDay)
    }

    /// 달을 옮긴 뒤 아래에 보여 줄 날. 이번 달이면 오늘, 아니면 그 달의 마지막 기록. 기록이 없으면 `nil`.
    private func defaultSelection(in month: DayKey, byDay: [DayKey: MoodEntry]) -> DayKey? {
        if month == today.firstOfMonth { return today }
        return byDay.keys.filter { $0.firstOfMonth == month }.max()
    }

    /// 날짜별 기록. 하루 한 건이 보장되지만, 중복이 있어도 앱이 멈추지 않게 먼저 만든 기록을 쓴다.
    private var entriesByDay: [DayKey: MoodEntry] {
        Dictionary(
            entries.map { ($0.day, $0) },
            uniquingKeysWith: { first, second in first.createdAt <= second.createdAt ? first : second }
        )
    }

    /// 오늘은 "오늘 오후 9:12", 다른 날은 "오후 9:12". 나중에 남긴 기록은 "나중에 기록 · 5월 14일 오후 9:30". (CAL-07, ADD-13)
    private func timeCaption(for entry: EntrySnapshot) -> String {
        let time = entry.createdAt.formatted(
            .dateTime.hour().minute().locale(Locale(identifier: "ko_KR"))
        )
        if entry.isRecordedLater {
            return "나중에 기록 · \(DayKey(entry.createdAt).formattedMonthDay) \(time)"
        }
        return entry.day == today ? "오늘 \(time)" : time
    }
}

// MARK: - 날짜 칸

/// 달력 한 칸. 날짜 숫자와 이모지를 보여 준다.
/// 오늘은 강조색 원, 선택한 지난 날은 흰 배경에 강조색 테두리 원과 강조색 숫자, 기록이 없는 지난 날은 점(·), 미래 날짜는 흐리게 보여 준다. (CAL-05, R-14)
private struct DayCell: View {
    let day: DayKey
    let emotion: Emotion?
    let isToday: Bool
    let isFuture: Bool
    let isSelected: Bool
    let isSelectable: Bool

    @ScaledMetric private var circleSize: CGFloat = 28
    @ScaledMetric private var markerHeight: CGFloat = 24
    @ScaledMetric private var minHeight: CGFloat = 48
    @ScaledMetric private var emptyDotSize: CGFloat = 6

    var body: some View {
        VStack(spacing: 2) {
            Text("\(day.day)")
                .font(.callout.weight(isToday || isSelected ? .bold : .regular))
                .foregroundStyle(numberColor)
                .frame(width: circleSize, height: circleSize)
                .background {
                    if isToday {
                        Circle().fill(.tint)
                    } else if isSelected {
                        // 선택한 지난 날은 흰 배경에 오늘과 같은 강조색 테두리 동그라미로 보여 준다.
                        Circle()
                            .fill(.white)
                            .overlay { Circle().strokeBorder(.tint, lineWidth: 2) }
                    }
                }
            marker.frame(height: markerHeight)       // 이모지가 없는 칸도 같은 높이를 써서 숫자 줄을 맞춘다.
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .top)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(isSelectable ? .isButton : [])
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private var marker: some View {
        if let emotion {
            EmojiText(emotion.emoji, size: 22, relativeTo: .title3)
        } else if isFuture {
            Color.clear.frame(height: 1)
        } else {
            Circle()                                    // 기록이 없는 지난 날의 점. 글자(·)보다 굵게 보이도록 도형으로 그린다.
                .fill(.secondary)
                .frame(width: emptyDotSize, height: emptyDotSize)
        }
    }

    private var numberColor: AnyShapeStyle {
        if isToday { return AnyShapeStyle(.white) }
        if isSelected { return AnyShapeStyle(.tint) }        // 오늘 동그라미와 같은 강조색
        return isFuture ? AnyShapeStyle(Color(.tertiaryLabel)) : AnyShapeStyle(.primary)
    }

    private var accessibilityText: String {
        var text = day.formattedFull
        if isToday { text += ", 오늘" }
        if let emotion {
            text += ", \(emotion.name)"
        } else if isFuture {
            text += ", 아직 오지 않은 날"
        } else {
            text += ", 기록 없음"
        }
        return text
    }
}

// MARK: - 기록 행

/// 달력 아래 영역의 기록 한 행. 이모지, 한 줄, 보조 글(시각 또는 날짜).
private struct CalendarRecordRow: View {
    let entry: EntrySnapshot
    let caption: String

    var body: some View {
        VStack(spacing: 0) {
            AdaptiveStack(hAlignment: .center, spacing: 14) {
                EmojiText(entry.emotion.emoji, size: 36, relativeTo: .title)
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.text)
                        .font(.body)                                    // 줄 수를 제한하지 않는다.
                        .multilineTextAlignment(.leading)
                    Text(caption)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .padding(.vertical, 10)
            .padding(.horizontal, 4)
            Divider()
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(entry.emotion.name), \(entry.text), \(caption)")
        .accessibilityHint("눌러서 기록을 관리합니다")
        .accessibilityAddTraits(.isButton)
    }
}

#if DEBUG
#Preview("오늘 기록 후") {
    NavigationStack {
        CalendarView(today: PreviewData.today)
            .navigationDestination(for: DayKey.self) { Text($0.formattedFull) }
    }
    .environment(AppRouter())
    .modelContainer(.preview)
}

#Preview("한 달치 기록") {
    NavigationStack {
        CalendarView(today: PreviewData.today)
            .navigationDestination(for: DayKey.self) { Text($0.formattedFull) }
    }
    .environment(AppRouter())
    .modelContainer(.previewMonth)
}

#Preview("기록 없음") {
    NavigationStack {
        CalendarView(today: PreviewData.today)
    }
    .environment(AppRouter())
    .modelContainer(try! AppContainer.make(inMemory: true))
}
#endif
