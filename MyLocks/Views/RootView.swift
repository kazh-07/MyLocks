import SwiftUI

// MARK: - Tab Bar Visibility Environment Key

private struct TabBarVisibilityKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(true)
}

extension EnvironmentValues {
    var tabBarVisible: Binding<Bool> {
        get { self[TabBarVisibilityKey.self] }
        set { self[TabBarVisibilityKey.self] = newValue }
    }
}

struct RootView: View {
    enum Tab: Hashable {
        case home, locations, add, michelin, events
    }

    @State private var selectedTab: Tab = .home
    @State private var showAddSheet = false
    @State private var isTabBarVisible = true

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home: HomeView()
                case .locations: LocationsView()
                case .add: HomeView()
                case .michelin: MichelinView()
                case .events: EventsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .environment(\.tabBarVisible, $isTabBarVisible)

            if isTabBarVisible {
                CustomTabBar(
                    selectedTab: $selectedTab,
                    isTabBarVisible: $isTabBarVisible,
                    onAdd: { showAddSheet = true }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showAddSheet) {
            AddView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .animation(.easeInOut(duration: 0.2), value: isTabBarVisible)
    }
}

private struct CustomTabBar: View {
    @Binding var selectedTab: RootView.Tab
    @Binding var isTabBarVisible: Bool
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            tabButton(.home, title: "Home", systemImage: "house")
            tabButton(.locations, title: "Locations", systemImage: "mappin")

            Button(action: onAdd) {
                Image(systemName: "plus")
                    .font(TabBarStyles.addIcon)
                    .foregroundStyle(.white)
                    .frame(width: AppDimensions.buttonHeight, height: AppDimensions.buttonHeight)
                    .background(Circle().fill(AppColors.label))
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(.plain)

            tabButton(.michelin, title: "Michelin", systemImage: "fork.knife")
            tabButton(.events, title: "Events", systemImage: "ticket")
        }
        .padding(.horizontal, TabBarStyles.horizontal)
        .padding(.top, TabBarStyles.top)
        .background(AppColors.background)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppColors.label.opacity(TabBarStyles.dividerOpacity))
                .frame(height: TabBarStyles.dividerHeight)
        }
    }

    private func tabButton(
        _ tab: RootView.Tab,
        title: String,
        systemImage: String
    ) -> some View {
        Button {
            selectedTab = tab
            // Hide tab bar when navigating to Locations view, show for other tabs
            isTabBarVisible = (tab != .locations)
        } label: {
            VStack(spacing: AppSpacing.sm) {
                Image(systemName: systemImage)
                    .font(TabBarStyles.icon)
                    .frame(height: AppDimensions.iconSize)

                Text(title)
                    .font(TabBarStyles.label)
            }
            .foregroundStyle(selectedTab == tab ? AppColors.label : AppColors.secondaryLabel)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
