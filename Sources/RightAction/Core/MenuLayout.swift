import Foundation

/// Finder 右键菜单展示模式。
/// - flat: 已启用且当前可用的动作直接显示在一级菜单中，收藏置顶。
/// - grouped: 兼容旧版，按动作分类放入二级子菜单。
public enum MenuLayoutMode: String, Codable, CaseIterable, Equatable, Identifiable {
    case flat
    case grouped

    public var id: String { rawValue }

    public var localizedName: String {
        switch self {
        case .flat: return "直接显示"
        case .grouped: return "分类显示"
        }
    }
}

/// FinderSync 渲染前的菜单布局计划。
/// 这里刻意只保留 actionId 和标题，不依赖 AppKit，便于单测和复用。
public enum FinderMenuLayoutSection: Equatable {
    case directItems(actionIds: [String])
    case submenu(title: String, actionIds: [String])
    case separator
}

/// 把动作集合与用户配置转换成 renderer-neutral 菜单布局。
public enum FinderMenuLayoutBuilder {
    public static let defaultBrowserActionPrefix = "guyue.action.utility.defaultBrowser."

    public static func build(
        actions: [MenuAction],
        mode: MenuLayoutMode,
        isEnabled: (MenuAction) -> Bool,
        isFavorite: (MenuAction) -> Bool,
        isAvailable: (MenuAction) -> Bool
    ) -> [FinderMenuLayoutSection] {
        let eligible = actions.filter { action in
            isEnabled(action) && isAvailable(action)
        }
        let browsers = eligible
            .filter { $0.actionId.hasPrefix(Self.defaultBrowserActionPrefix) }
            .sorted { $0.actionId < $1.actionId }
        let others = eligible.filter { !$0.actionId.hasPrefix(Self.defaultBrowserActionPrefix) }

        var sections: [FinderMenuLayoutSection]
        switch mode {
        case .flat:
            sections = buildFlatSections(actions: others, isFavorite: isFavorite)
        case .grouped:
            sections = buildGroupedSections(actions: others, isFavorite: isFavorite)
        }
        if !browsers.isEmpty {
            sections.append(.submenu(
                title: "切换默认浏览器",
                actionIds: browsers.map(\.actionId)
            ))
        }
        return sections
    }

    private static func buildFlatSections(
        actions: [MenuAction],
        isFavorite: (MenuAction) -> Bool
    ) -> [FinderMenuLayoutSection] {
        let favoriteIds = actions
            .filter(isFavorite)
            .sortedForMenu()
            .map(\.actionId)

        let regularIds = ActionCategory.allCases.flatMap { category in
            actions
                .filter { $0.category == category && !isFavorite($0) }
                .sortedForMenu()
                .map(\.actionId)
        }

        let ids = favoriteIds + regularIds
        return ids.isEmpty ? [] : [.directItems(actionIds: ids)]
    }

    private static func buildGroupedSections(
        actions: [MenuAction],
        isFavorite: (MenuAction) -> Bool
    ) -> [FinderMenuLayoutSection] {
        var sections: [FinderMenuLayoutSection] = []

        let favoriteIds = actions
            .filter(isFavorite)
            .sortedForMenu()
            .map(\.actionId)
        if !favoriteIds.isEmpty {
            sections.append(.submenu(title: "常用", actionIds: favoriteIds))
        }

        for category in ActionCategory.allCases {
            let ids = actions
                .filter { $0.category == category && !isFavorite($0) }
                .sortedForMenu()
                .map(\.actionId)
            if !ids.isEmpty {
                sections.append(.submenu(title: category.localizedName, actionIds: ids))
            }
        }

        return sections
    }
}

private extension Array where Element == MenuAction {
    func sortedForMenu() -> [MenuAction] {
        sorted {
            if $0.localizedTitle == $1.localizedTitle {
                return $0.actionId < $1.actionId
            }
            return $0.localizedTitle < $1.localizedTitle
        }
    }
}
