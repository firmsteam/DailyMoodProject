//
//  AppContainer.swift
//  DailyMoodProject
//

import SwiftData

enum AppContainer {
    /// 테스트와 미리보기에서는 `inMemory: true`로 만들어 디스크에 아무것도 남기지 않는다.
    static func make(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema(versionedSchema: SchemaV1.self)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
