import Foundation

/// 动态服务 helper 与 Host 之间的最小稳定协议。
public enum FinderQuickServiceProtocol {
    public static let bundleIdentifier = "ikxlpz.RightAction.QuickServices"
    public static let bundleDirectoryName = "RightActionQuickActions.service"
    public static let executableName = "RightActionQuickService"
    public static let providerPortName = "RightActionQuickActions"
    public static let forwardedActionPasteboardType = "ikxlpz.RightAction.direct-action-id"
    public static let hostPaletteMenuTitle = "RightAction…"
}
