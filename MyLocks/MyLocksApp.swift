import SwiftUI
import SwiftData

@main
struct MyLocksApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .task {
                    // Seed once at app start if needed
                    await DataSeeder.seedIfNeeded(from: ModelContainerProvider.shared)
                }
        }
        .modelContainer(ModelContainerProvider.shared)
    }
}
