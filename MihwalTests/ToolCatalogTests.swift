import XCTest
@testable import Mihwal

final class ToolCatalogTests: XCTestCase {
    func testCatalogContainsExactlyTwentyOneTools() {
        XCTAssertEqual(ToolCatalog.all.count, 21)
        XCTAssertEqual(Set(ToolCatalog.all.map(\.id)).count, 21)
    }

    func testEveryToolHasPresentationMetadata() {
        for tool in ToolCatalog.all {
            XCTAssertFalse(tool.titleKey.isEmpty)
            XCTAssertFalse(tool.subtitleKey.isEmpty)
            XCTAssertFalse(tool.symbolName.isEmpty)
        }
    }
}
