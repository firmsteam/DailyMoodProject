//
//  CalendarView.swift
//  DailyMoodProject
//

import SwiftUI
import SwiftData

/// 달력 탭(④). 한 달을 격자로 보여 주고, 기록이 있는 날을 누르면 아래에 그날의 기록을 보여 준다.
/// - CAL-01 제목, CAL-02 달 이동, CAL-03 ＋, CAL-04 요일 줄, CAL-05 날짜 칸
/// - CAL-06 날짜 칸 누르기, CAL-07 선택한 날 영역, CAL-08 지난 기록
struct CalendarView: View {
    @Environment(AppRouter.self) private var router
    @Query private var entries: [MoodEntry]

    /// 화면에 보이는 달의 1일.
    @State private var monthStart: DayKey
    /// 아래 영역에 보여 줄 날. 기록이 없는 달로 옮기면 `nil`이다.
    @State private var selected: DayKey?

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
                titleBlock
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
                Button("다음 달", systemImage: "chevron.right") { moveMonth(by: 1, byDay: byDay) }
                    .disabled(!canMoveToNextMonth)           // 이번 달에서는 비활성 (CAL-02)
            }
            ToolbarItem(placement: .primaryAction) {
                Button("오늘 기록하기", systemImage: "plus") { openEditorForToday(byDay: byDay) }
            }
        }
        .onChange(of: Set(entries.map(\.dayKey))) { _, days in
            // 선택한 날의 기록이 사라졌다면(삭제) 오늘로 돌아간다. 기록 없는 날은 선택할 수 없다. (CAL-06)
            guard let selected, selected != today, !days.contains(selected.rawValue) else { return }
            self.selected = today
            monthStart = today.firstOfMonth
        }
    }

    // MARK: - 제목 (CAL-01)

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(verbatim: "\(monthStart.year)년")      // 연도에 쉼표(2,026)가 붙지 않게 한다.
                .font(.headline)
                .foregroundStyle(.tint)
            Text("\(monthStart.month)월")
                .font(.largeTitle.bold())
        }
        .padding(.top, 4)
        .padding(.bottom, 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(monthStart.formattedYearMonth)
        .accessibilityAddTraits(.isHeader)
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
            let content = DayCell(
                day: day,
                emotion: entry?.emotion,
                isToday: day == today,
                isFuture: day > today,
                isSelected: day == selected
            )
            if entry != nil {
                // 기록이 있는 날만 선택할 수 있다.
                Button { selected = day } label: { content }
                    .buttonStyle(.plain)
            } else {
                // 기록이 없는 날(오늘 기록 전 포함)과 미래 날짜는 눌러도 반응하지 않는다.
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
                    Text("아직 기록이 없어요")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
                        .padding(.horizontal, 4)
                    Divider()
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
            Text(day.formattedFull)
                .foregroundStyle(.secondary)
            if day == today {
                Text("오늘")
                    .foregroundStyle(.tint)
            }
        }
        .font(.subheadline.weight(.semibold))
        .padding(.top, 20)
        .padding(.bottom, 8)
        .padding(.horizontal, 4)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
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
                        CalendarRecordRow(entry: entry, caption: entry.day.formattedMonthDay)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - 동작

    /// 오늘 기록하기. 오늘 기록이 이미 있으면 수정 모드로 연다. (CAL-03, R-02)
    private func openEditorForToday(byDay: [DayKey: MoodEntry]) {
        router.sheet = .editor(byDay[today] != nil ? .edit(today) : .new(prompt: nil))
    }

    private var canMoveToNextMonth: Bool {
        monthStart < today.firstOfMonth
    }

    private func moveMonth(by value: Int, byDay: [DayKey: MoodEntry]) {
        let moved = monthStart.firstOfMonth(adding: value)
        guard moved <= today.firstOfMonth else { return }       // 아직 오지 않은 달로는 갈 수 없다.
        monthStart = moved
        selected = defaultSelection(in: moved, byDay: byDay)
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

    /// 오늘은 "오늘 오후 9:12", 다른 날은 "오후 9:12". (CAL-07)
    private func timeCaption(for entry: EntrySnapshot) -> String {
        let time = entry.createdAt.formatted(
            .dateTime.hour().minute().locale(Locale(identifier: "ko_KR"))
        )
        return entry.day == today ? "오늘 \(time)" : time
    }
}

// MARK: - 날짜 칸

/// 달력 한 칸. 날짜 숫자와 이모지를 보여 준다.
/// 오늘은 강조색 원, 기록이 없는 지난 날은 점(·), 미래 날짜는 흐리게 보여 준다. (CAL-05, R-14)
private struct DayCell: View {
    let day: DayKey
    let emotion: Emotion?
    let isToday: Bool
    let isFuture: Bool
    let isSelected: Bool

    @ScaledMetric private var circleSize: CGFloat = 28
    @ScaledMetric private var markerHeight: CGFloat = 24
    @ScaledMetric private var minHeight: CGFloat = 48

    var body: some View {
        VStack(spacing: 2) {
            Text("\(day.day)")
                .font(.callout.weight(isToday ? .bold : .regular))
                .foregroundStyle(numberColor)
                .frame(width: circleSize, height: circleSize)
                .background {
                    if isToday { Circle().fill(.tint) }
                }
            marker.frame(height: markerHeight)       // 이모지가 없는 칸도 같은 높이를 써서 숫자 줄을 맞춘다.
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .top)
        .background {
            if isSelected && !isToday {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.tint.opacity(0.12))
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(emotion == nil ? [] : .isButton)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private var marker: some View {
        if let emotion {
            EmojiText(emotion.emoji, size: 22, relativeTo: .title3)
        } else if isFuture {
            Color.clear.frame(height: 1)
        } else {
            Text("·").font(.callout).foregroundStyle(.secondary)
        }
    }

    private var numberColor: Color {
        if isToday { return .white }
        return isFuture ? Color(.tertiaryLabel) : .primary
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

#Preview("기록 없음") {
    NavigationStack {
        CalendarView(today: PreviewData.today)
    }
    .environment(AppRouter())
    .modelContainer(try! AppContainer.make(inMemory: true))
}
#endif
