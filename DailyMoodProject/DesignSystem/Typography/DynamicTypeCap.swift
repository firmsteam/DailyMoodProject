//
//  DynamicTypeCap.swift
//  DailyMoodProject
//

import SwiftUI

extension View {
    /// 글자 크기 상한. 칸 수가 정해진 격자처럼 더 커지면 형태가 무너지는 곳에서만 쓴다.
    /// 상한을 건 곳에는 같은 정보를 크게 읽을 수 있는 다른 곳(예: 달력 아래 선택한 날 영역)을 함께 둔다.
    func cappedDynamicType(_ max: DynamicTypeSize = .xxxLarge) -> some View {
        dynamicTypeSize(...max)
    }
}
