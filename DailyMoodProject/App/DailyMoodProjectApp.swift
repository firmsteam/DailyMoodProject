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
}

#Preview {
    RootView()
        .environment(AppRouter())
        .modelContainer(try! AppContainer.make(inMemory: true))
}
