//
//  SchemaV1.swift
//  DailyMoodProject
//

import SwiftData

/// 저장 구조의 첫 버전. 이후 구조가 바뀌면 SchemaV2를 추가해 마이그레이션한다.
enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [MoodEntry.self] }
}
