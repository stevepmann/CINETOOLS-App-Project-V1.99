//
//  MainTabView.swift
//  CineTools — Restyle v4
//
//  App root: Tools / Kit Bag / Support tabs with the floating pill tab bar.
//  The bar shows on the three tab roots and hides on pushed detail screens.
//

import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case tools = "Tools"
    case kitBag = "Kit Bag"
    case support = "Support"
    var id: String { rawValue }
}

// MARK: - Tab switching from inside a tab (Home "See all", Support pill)

private struct SelectTabKey: EnvironmentKey {
    static let defaultValue: ((AppTab) -> Void)? = nil
}

extension EnvironmentValues {
    /// Switch tabs from inside a screen. `nil` when the screen isn't hosted in MainTabView.
    var selectTab: ((AppTab) -> Void)? {
        get { self[SelectTabKey.self] }
        set { self[SelectTabKey.self] = newValue }
    }
}

// MARK: - Root

struct MainTabView: View {
    @StateObject private var settings = UserSettings()
    @State private var tab: AppTab = .tools
    /// How many tab-root screens are on screen. 0 = a detail screen is pushed → hide the bar.
    @State private var visibleRoots = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch tab {
                case .tools:
                    HomePageView() // marks its own root with .countsAsTabRoot()
                case .kitBag:
                    NavigationStack {
                        UserSettingsView(showsBackButton: false)
                            .countsAsTabRoot()
                    }
                case .support:
                    NavigationStack {
                        SupportPageView(showsBackButton: false)
                            .countsAsTabRoot()
                    }
                }
            }
            .environmentObject(settings)
            .environment(\.tabRootCounter, $visibleRoots)
            .environment(\.selectTab, { newTab in
                withAnimation(.snappy(duration: 0.25)) { tab = newTab }
            })

            if visibleRoots > 0 {
                FloatingTabBar(selection: $tab)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.snappy(duration: 0.25), value: visibleRoots > 0)
        .ignoresSafeArea(.keyboard)
        .themedScreen()
    }
}

// MARK: - Tab-root tracking (hides the bar on pushed screens)

private struct TabRootCounterKey: EnvironmentKey {
    static let defaultValue: Binding<Int>? = nil
}

extension EnvironmentValues {
    var tabRootCounter: Binding<Int>? {
        get { self[TabRootCounterKey.self] }
        set { self[TabRootCounterKey.self] = newValue }
    }
}

private struct TabRootModifier: ViewModifier {
    @Environment(\.tabRootCounter) private var counter

    func body(content: Content) -> some View {
        content
            .onAppear { counter?.wrappedValue += 1 }
            .onDisappear {
                if let counter { counter.wrappedValue = max(counter.wrappedValue - 1, 0) }
            }
    }
}

extension View {
    /// Put on the root screen inside each tab's NavigationStack. While it's visible the
    /// floating tab bar shows; when a detail screen is pushed over it, the bar hides.
    func countsAsTabRoot() -> some View {
        modifier(TabRootModifier())
    }
}

// MARK: - Floating tab bar

struct FloatingTabBar: View {
    @Binding var selection: AppTab
    @Namespace private var pill

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases) { tab in
                let isActive = tab == selection
                Button {
                    withAnimation(.snappy(duration: 0.25)) { selection = tab }
                } label: {
                    Text(tab.rawValue)
                        .font(Theme.Fonts.archivo(17, .semibold))
                        .foregroundStyle(isActive ? Theme.Colors.ink : Theme.Colors.textSecondary)
                        .padding(.horizontal, 20)
                        .frame(height: 46)
                        .background {
                            if isActive {
                                Capsule()
                                    .fill(Theme.Colors.paper)
                                    .matchedGeometryEffect(id: "activeTab", in: pill)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isActive ? .isSelected : [])
            }
        }
        .padding(5)
        .background(Theme.Colors.heroCard, in: Capsule())
        .overlay(Capsule().stroke(Theme.Colors.separator, lineWidth: 1))
        .shadow(color: .black.opacity(0.35), radius: 16, y: 6)
    }
}

#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
}
