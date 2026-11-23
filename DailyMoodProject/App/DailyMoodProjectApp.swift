//
//  DailyMoodProjectApp.swift
//  DailyMoodProject
//

import SwiftUI
import SwiftData

@main
struct DailyMoodProjectApp: App {
    @State private var router = AppRouter()
    private let container: ModelContainer

    init() {
        do {
            container = try AppContainer.make()
            #if DEBUG && targetEnvironment(simulator)
            try Self.seedSamplesIfEmpty(container)
            #endif
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(router)
                .appAppearance()
                .syncReminders()
        }
        .modelContainer(container)
    }

    #if DEBUG && targetEnvironment(simulator)
    /// 시뮬레이터 DEBUG 빌드에서만 쓴다. 저장된 기록이 하나도 없을 때 샘플(어제 기준 12건)을 넣는다.
    /// 기록이 있으면 건드리지 않아 직접 쓴 기록이 샘플과 섞이지 않는다. 샘플을 새로 받으려면 앱을 지우고 다시 설치한다.
    private static func seedSamplesIfEmpty(_ container: ModelContainer) throws {
        let context = container.mainContext
        guard try context.fetchCount(FetchDescriptor<MoodEntry>()) == 0 else { return }
        try SampleData.insert(into: context)
    }
    #endif
}

#Preview {
    RootView()
        .environment(AppRouter())
        .modelContainer(try! AppContainer.make(inMemory: true))
}
