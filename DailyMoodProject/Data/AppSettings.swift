//
//  AppSettings.swift
//  DailyMoodProject
//

import SwiftUI

/// `@AppStorage` 키 이름. 문자열을 여러 곳에 흩어 쓰면 오타로 값이 갈라지므로 한 곳에 모은다.
enum SettingsKey {
    static let themeMode = "themeMode"
    static let fontSizeOption = "fontSizeOption"
    static let reminderEnabled = "reminderEnabled"
    static let reminderMinutes = "reminderMinutes"
    static let hasLaunchedBefore = "hasLaunchedBefore"
}

/// 화면 모드. (SET-02)
enum AppTheme: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }

    /// `nil`이면 시스템 설정을 따른다.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

/// 앱 안에서 고르는 글꼴 크기. (D-02)
enum AppFontSize: String, CaseIterable, Identifiable {
    case system, small, standard, large, extraLarge

    var id: String { rawValue }

    /// `nil`이면 시스템 글자 크기를 그대로 따른다.
    var dynamicTypeSize: DynamicTypeSize? {
        switch self {
        case .system: nil
        case .small: .small
        case .standard: .large
        case .large: .xxxLarge
        case .extraLarge: .accessibility2
        }
    }
}

/// 알림 시간 기본값(21:00)을 자정부터 지난 분으로 나타낸 값.
enum SettingsDefault {
    static let reminderMinutes = 21 * 60
}
