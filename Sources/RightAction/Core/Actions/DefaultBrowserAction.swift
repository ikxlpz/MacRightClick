import AppKit
import Foundation

public enum DefaultBrowserChoice: String, CaseIterable, Sendable {
    case chrome
    case safari

    public var title: String {
        switch self {
        case .chrome: return "Google Chrome"
        case .safari: return "Safari"
        }
    }

    public var bundleIdentifier: String {
        switch self {
        case .chrome: return "com.google.Chrome"
        case .safari: return "com.apple.Safari"
        }
    }

    public var isInstalled: Bool {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) != nil
    }

    public static var current: DefaultBrowserChoice? {
        guard let probe = URL(string: "https://example.com"),
              let appURL = NSWorkspace.shared.urlForApplication(toOpen: probe),
              let bundleID = Bundle(url: appURL)?.bundleIdentifier else { return nil }
        return allCases.first { $0.bundleIdentifier == bundleID }
    }

    public static func apply(_ appURL: URL, schemes: [String], completion: @escaping (String?) -> Void) {
        func step(_ index: Int) {
            guard index < schemes.count else {
                completion(nil)
                return
            }
            NSWorkspace.shared.setDefaultApplication(at: appURL, toOpenURLsWithScheme: schemes[index]) { error in
                if let error {
                    completion(error.localizedDescription)
                } else {
                    step(index + 1)
                }
            }
        }
        step(0)
    }
}

public final class DefaultBrowserAction: MenuAction {
    public let browser: DefaultBrowserChoice
    public let actionId: String
    public let localizedTitle: String
    public let iconName: String?
    public let category: ActionCategory = .utility
    public let tier: ActionTier = .professional
    public let isEnabledByDefault = true
    public let requiresExistingTargets = false

    public init(browser: DefaultBrowserChoice) {
        self.browser = browser
        actionId = "guyue.action.utility.defaultBrowser.\(browser.rawValue)"
        localizedTitle = browser.title
        iconName = browser == .safari ? "safari" : "globe"
    }

    public var isCurrent: Bool {
        DefaultBrowserChoice.current == browser
    }

    public func isAvailable(for targetURLs: [URL], isContainer: Bool) -> Bool {
        browser.isInstalled
    }

    public func execute(targetURLs: [URL]) -> Bool {
        submit(targetURLs: targetURLs, completion: { _ in }) == .accepted
    }

    public func submit(
        targetURLs: [URL],
        completion: @escaping @Sendable (ActionCompletionStatus) -> Void
    ) -> ActionSubmission {
        if isCurrent {
            completion(.succeeded)
            return .accepted
        }
        let title = browser.title
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: browser.bundleIdentifier) else {
            SharedHUDManager.show(
                title: "未安装 \(title)",
                content: "请先安装后再设为默认浏览器",
                isSuccess: false
            )
            completion(.failed)
            return .rejected
        }
        DefaultBrowserChoice.apply(appURL, schemes: ["https", "http"]) { error in
            if let error {
                SharedHUDManager.show(title: "切换默认浏览器失败", content: error, isSuccess: false)
                completion(.failed)
            } else {
                completion(.succeeded)
            }
        }
        return .accepted
    }
}
