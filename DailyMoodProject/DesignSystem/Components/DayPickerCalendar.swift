//
//  DayPickerCalendar.swift
//  DailyMoodProject
//

import SwiftUI

/// 기록할 날을 고르는 작은 달력. (ADD-08)
/// 기록이 없는 지난 날만 고를 수 있다. 이미 기록한 날과 미래 날짜는 흐리게 보이고 눌리지 않는다.
struct DayPickerCalendar: View {
    @Binding var selection: DayKey
    let today: DayKey
    let recorded: Set<DayKey>

    /// 화면에 보이는 달의 1일.
    @State private var month: DayKey

    private let calendar = Calendar.app
    @ScaledMetric private var circleSize: CGFloat = 34
    @ScaledMetric private var rowHeight: CGFloat = 44

    init(selection: Binding<DayKey>, today: DayKey, recorded: Set<DayKey>) {
        _selection = selection
        self.today = today
        self.recorded = recorded
        _month = State(initialValue: selection.wrappedValue.firstOfMonth)
    }

    private var range: ClosedRange<DayKey> { EntryValidator.recordableRange(today: today) }

    /// 가장 이른 날이 있는 달부터 이번 달까지 오갈 수 있다.
    private var canGoBack: Bool { month > range.lowerBound.firstOfMonth }
    private var canGoForward: Bool { month < today.firstOfMonth }

    var body: some View {
        VStack(spacing: 8) {
            header
            weekdayHeader
            ForEach(Array(CalendarGrid.weeks(of: month).enumerated()), id: \.offset) { _, week in
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { column in
                        cell(for: week[column])
                    }
                }
            }
        }
        .cappedDynamicType()                    // 칸 수가 정해진 격자라 글자 크기 상한을 둔다.
    }

    private var header: some View {
        HStack {
            Button("이전 달", systemImage: "chevron.left") { move(by: -1) }
                .disabled(!canGoBack)
            Spacer()
            Text(month.formattedYearMonth)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Button("다음 달", systemImage: "chevron.right") { move(by: 1) }
                .disabled(!canGoForward)
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
        .frame(minHeight: 44)
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(Array(calendar.veryShortStandaloneWeekdaySymbols.enumerated()), id: \.offset) { index, symbol in
                Text(symbol)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(index == 0 ? Color.red : .secondary)
                    .frame(maxWidth: .infinity)
                    .accessibilityHidden(true)
            }
        }
    }

    @ViewBuilder
    private func cell(for day: DayKey?) -> some View {
        if let day {
            if isSelectable(day) {
                Button { selection = day } label: { dayLabel(day, isSelectable: true) }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(day == selection ? .isSelected : [])
            } else {
                dayLabel(day, isSelectable: false)
            }
        } else {
            Color.clear.frame(maxWidth: .infinity, minHeight: rowHeight)
        }
    }

    private func dayLabel(_ day: DayKey, isSelectable: Bool) -> some View {
        let isSelected = day == selection
        return Text("\(day.day)")
            .font(.callout)
            .foregroundStyle(foreground(isSelectable: isSelectable, isSelected: isSelected))
            .frame(width: circleSize, height: circleSize)
            .background {
                if isSelected {
                    Circle().fill(.tint)
                } else if isSelectable {
                    Circle().fill(.tint.opacity(0.12))
                }
            }
            .frame(maxWidth: .infinity, minHeight: rowHeight)
            .contentShape(Rectangle())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityText(for: day, isSelectable: isSelectable))
    }

    private func foreground(isSelectable: Bool, isSelected: Bool) -> AnyShapeStyle {
        if isSelected { return AnyShapeStyle(.white) }
        return isSelectable ? AnyShapeStyle(.tint) : AnyShapeStyle(Color(.tertiaryLabel))
    }

    private func isSelectable(_ day: DayKey) -> Bool {
        range.contains(day) && !recorded.contains(day)
    }

    private func accessibilityText(for day: DayKey, isSelectable: Bool) -> String {
        if isSelectable { return day.formattedFull }
        if recorded.contains(day) { return "\(day.formattedFull), 이미 기록한 날" }
        if day > today { return "\(day.formattedFull), 아직 오지 않은 날" }
        return "\(day.formattedFull), 기록할 수 없는 날"
    }

    private func move(by value: Int) {
        let moved = month.firstOfMonth(adding: value)
        guard moved >= range.lowerBound.firstOfMonth, moved <= today.firstOfMonth else { return }
        month = moved
    }
}

#if DEBUG
#Preview {
    @Previewable @State var selection = DayKey(rawValue: 20250510)
    DayPickerCalendar(
        selection: $selection,
        today: DayKey(rawValue: 20250514),
        recorded: Set(SampleData.entries.map(\.day))
    )
    .padding()
    .tint(.indigo)
}
#endif
