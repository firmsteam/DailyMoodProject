//
//  AppRouter.swift
//  DailyMoodProject
//

import SwiftUI

/// 시트와 선택된 탭 상태. 시트는 앱 최상위에서 하나만 열고, 시트 위에서 또 시트를 열지 않는다.
@Observable
final class AppRouter {
    enum Sheet: Identifiable {
        case editor(EditorMode)
        case settings

        var id: String {
            switch self {
            case .editor(let mode): "editor-\(mode.id)"
            case .settings: "settings"
            }
        }
    }

    var sheet: Sheet?
    var selectedTab: AppTab = .record
    /// 시트에서 방금 저장한 기록. 달력이 이 날을 선택하고 알림을 보여 준다. (ADD-05)
    var savedEntry: SavedEntry?
}

/// 저장 알림용 이벤트. 같은 날을 지웠다가 다시 저장해도 변화로 감지되도록 `id`를 둔다.
struct SavedEntry: Equatable {
    let day: DayKey
    let id = UUID()
}

/// 감정 기록 시트(③)가 열리는 방식.
enum EditorMode: Hashable, Identifiable {
    /// 새 기록. 질문 카드로 들어오면 `prompt`가 있다. (③-2)
    case new(prompt: String?)
    /// 기존 기록 수정. (③-1)
    case edit(DayKey)
    /// 날짜를 바꿀 수 있는 새 기록. 달력 탭의 ＋에서 열린다. `initial`은 처음 선택된 날이다. (③-4)
    case backfill(initial: DayKey)

    var id: String {
        switch self {
        case .new(let prompt): "new-\(prompt ?? "")"
        case .edit(let day): "edit-\(day.rawValue)"
        case .backfill(let initial): "backfill-\(initial.rawValue)"
        }
    }
}

enum AppTab: Hashable {
    case record, calendar, week, month
}
