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
}

/// 감정 기록 시트(③)가 열리는 방식.
enum EditorMode: Hashable, Identifiable {
    /// 새 기록. 질문 카드로 들어오면 `prompt`가 있다. (③-2)
    case new(prompt: String?)
    /// 기존 기록 수정. (③-1)
    case edit(DayKey)

    var id: String {
        switch self {
        case .new(let prompt): "new-\(prompt ?? "")"
        case .edit(let day): "edit-\(day.rawValue)"
        }
    }
}

enum AppTab: Hashable {
    case record, calendar, week, month
}
