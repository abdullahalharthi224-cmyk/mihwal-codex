import SwiftUI

@main
struct MihwalApp: App {
    @StateObject private var toolLibrary = ToolLibrary()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(toolLibrary)
                .tint(DesignSystem.Colors.tint)
        }
    }
}
