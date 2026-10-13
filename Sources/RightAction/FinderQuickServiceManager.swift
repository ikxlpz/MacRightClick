import AppKit
import Foundation

/// 把运行时依赖收口为一个解析入口，动态清单和服务授权始终使用同一份当前状态。
enum FinderQuickActionRuntime {
    static func currentItems() -> [FinderServiceActionItem] {
        let storage = SharedStorageManager.shared
        return FinderQuickActionPolicy.resolveDirectItems(
            actions: ActionDispatcher.shared.allActions,
            favoriteActionIDs: storage.favoriteActionIds,
            isEnabled: { storage.isActionEnabled($0) },
            isExternalAppAvailable: { InstalledAppRegistry.shared.isInstalled($0) }
        )
    }
}

/// 不再向「服务」菜单注册快捷项，启动时清掉当前和改名前的动态服务。
@MainActor
final class FinderQuickServiceManager {
    static let shared = FinderQuickServiceManager()

    private let ioQueue = DispatchQueue(
        label: "ikxlpz.RightAction.quick-services",
        qos: .utility
    )
    private let store: FinderQuickServiceBundleStore

    private init() {
        let libraryDirectory = FileManager.default.urls(
            for: .libraryDirectory,
            in: .userDomainMask
        ).first ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library")
        store = FinderQuickServiceBundleStore(
            servicesDirectoryURL: libraryDirectory.appendingPathComponent("Services", isDirectory: true)
        )
    }

    func start() {
        let current = store.bundleURL
        let legacy = store.servicesDirectoryURL.appendingPathComponent(
            "RightClickAssistantQuickActions.service",
            isDirectory: true
        )
        ioQueue.async {
            let fileManager = FileManager.default
            var didRemove = false
            for url in [current, legacy] where fileManager.fileExists(atPath: url.path) {
                try? fileManager.removeItem(at: url)
                didRemove = true
            }
            guard didRemove else { return }
            DispatchQueue.main.async {
                NSUpdateDynamicServices()
            }
        }
    }

    func stop() {}
}
