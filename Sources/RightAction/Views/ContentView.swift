import SwiftUI

/// 设置页分页。使用系统标签栏，不再放左侧边栏。
enum SettingsPage: String, CaseIterable, Identifiable {
    case overview
    case actions
    case permissions
    case diagnostics
    case advanced

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview: return "概览"
        case .actions: return "动作"
        case .permissions: return "Finder"
        case .diagnostics: return "诊断"
        case .advanced: return "高级"
        }
    }

    var iconName: String {
        switch self {
        case .overview: return "gearshape"
        case .actions: return "list.bullet.rectangle"
        case .permissions: return "folder"
        case .diagnostics: return "waveform.path.ecg"
        case .advanced: return "exclamationmark.triangle"
        }
    }
}

public struct ContentView: View {
    @State private var selectedTab: SettingsPage = .overview

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(SettingsPage.allCases) { page in
                pageContent(page)
                    .tag(page)
                    .tabItem {
                        Label(page.title, systemImage: page.iconName)
                    }
            }
        }
        .systemTabBar()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func pageContent(_ page: SettingsPage) -> some View {
        switch page {
        case .overview:
            OverviewSettingsView()
        case .actions:
            ActionsHubView()
        case .permissions:
            PermissionsSettingsView()
        case .diagnostics:
            DiagnosticsSettingsView()
        case .advanced:
            AdvancedSettingsView()
        }
    }
}

private extension View {
    /// macOS 15 起强制使用标签栏。sidebarAdaptable 在 Mac 上会退回左侧边栏。
    @ViewBuilder
    func systemTabBar() -> some View {
        if #available(macOS 15.0, *) {
            self.tabViewStyle(.tabBarOnly)
        } else {
            self
        }
    }
}
