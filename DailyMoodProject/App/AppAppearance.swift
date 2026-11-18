//
//  AppAppearance.swift
//  DailyMoodProject
//

import SwiftUI

/// 설정에서 고른 화면 모드를 앱 전체에 적용한다. (SET-02, COM-03)
/// `@AppStorage`가 값이 바뀔 때마다 화면을 다시 그리므로 앱을 다시 켜지 않아도 바로 바뀐다.
struct AppAppearance: ViewModifier {
    @AppStorage(SettingsKey.themeMode) private var theme: AppTheme = .system

    func body(content: Content) -> some View {
        content
            .preferredColorScheme(theme.colorScheme)            // nil이면 기기 설정을 따른다
    }
}

extension View {
    /// 앱 최상위 뷰에 한 번만 붙인다. 시트도 이 값을 따른다.
    func appAppearance() -> some View {
        modifier(AppAppearance())
    }
}
