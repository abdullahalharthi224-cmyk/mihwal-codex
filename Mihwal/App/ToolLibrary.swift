import Foundation
import Combine

@MainActor
final class ToolLibrary: ObservableObject {
    @Published private(set) var favoriteIDs: Set<ToolID>
    @Published private(set) var recentIDs: [ToolID]

    private let favoritesKey = "favoriteToolIDs"
    private let recentsKey = "recentToolIDs"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        favoriteIDs = Set(defaults.stringArray(forKey: favoritesKey)?.compactMap(ToolID.init(rawValue:)) ?? [])
        recentIDs = defaults.stringArray(forKey: recentsKey)?.compactMap(ToolID.init(rawValue:)) ?? []
    }

    func toggleFavorite(_ tool: ToolDefinition) {
        if favoriteIDs.contains(tool.id) {
            favoriteIDs.remove(tool.id)
        } else {
            favoriteIDs.insert(tool.id)
        }
        persist()
    }

    func recordUse(of tool: ToolDefinition) {
        recentIDs.removeAll { $0 == tool.id }
        recentIDs.insert(tool.id, at: 0)
        recentIDs = Array(recentIDs.prefix(6))
        persist()
    }

    private func persist() {
        defaults.set(favoriteIDs.map(\.rawValue).sorted(), forKey: favoritesKey)
        defaults.set(recentIDs.map(\.rawValue), forKey: recentsKey)
    }
}
