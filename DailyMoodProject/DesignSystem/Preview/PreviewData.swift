//
//  PreviewData.swift
//  DailyMoodProject
//

#if DEBUG
import Foundation
import SwiftData

/// 미리보기용 샘플. 내용은 `SampleData`(시안과 같은 12건)를 그대로 쓴다.
enum PreviewData {
    static let today = SampleData.today
    static let entries = SampleData.entries
}

extension ModelContainer {
    /// 샘플이 들어 있는 메모리 컨테이너. 디스크에 아무것도 남기지 않는다.
    @MainActor
    static var preview: ModelContainer {
        let container = try! AppContainer.make(inMemory: true)
        try! SampleData.insert(into: container.mainContext)
        return container
    }

    /// 한 달치(30건) 테스트 기록이 들어 있는 메모리 컨테이너.
    @MainActor
    static var previewMonth: ModelContainer {
        let container = try! AppContainer.make(inMemory: true)
        try! SampleData.insert(into: container.mainContext, entries: SampleData.monthEntries)
        return container
    }
}
#endif
