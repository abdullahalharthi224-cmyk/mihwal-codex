import Foundation

/// The common boundary for every on-device conversion or editing tool.
/// Engines must remain free of SwiftUI so they can be exercised with XCTest.
protocol FileTool {
    var definition: ToolDefinition { get }

    func run(
        input: ToolInput,
        options: ToolOptions,
        progress: ToolProgressReporting
    ) async throws -> ToolOutput
}

struct ToolInput: Sendable {
    let fileURLs: [URL]
}

struct ToolOptions: Sendable {
    let values: [String: String]
}

struct ToolOutput: Sendable {
    let fileURLs: [URL]
}

protocol ToolProgressReporting: Sendable {
    func report(completedUnitCount: Int64, totalUnitCount: Int64) async
}
