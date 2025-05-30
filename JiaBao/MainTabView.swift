import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    RandomLocationMapView()
                        .tag(0)
                        .ignoresSafeArea()

                    FoodSelectionView()
                        .tag(1)
                        .ignoresSafeArea()

                    SettingsView()
                        .tag(2)
                        .ignoresSafeArea()
                }

                // 自定義懸浮 TabBar
                HStack(spacing: 0) {
                    Spacer(minLength: 0)

                    // 地圖按鈕
                    TabBarButton(
                        title: "地圖",
                        icon: "map",
                        isSelected: selectedTab == 0
                    ) {
                        withAnimation(.easeInOut) {
                            selectedTab = 0
                        }
                    }

                    Spacer(minLength: 0)

                    // 要吃什麼按鈕
                    TabBarButton(
                        title: "要吃什麼",
                        icon: "fork.knife",
                        isSelected: selectedTab == 1
                    ) {
                        withAnimation(.easeInOut) {
                            selectedTab = 1
                        }
                    }

                    Spacer(minLength: 0)

                    // 設定按鈕
                    TabBarButton(
                        title: "設定",
                        icon: "gearshape",
                        isSelected: selectedTab == 2
                    ) {
                        withAnimation(.easeInOut) {
                            selectedTab = 2
                        }
                    }

                    Spacer(minLength: 0)
                }
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: -5)
                )
                .frame(width: geometry.size.width * 0.7)
                .padding(.bottom, geometry.safeAreaInsets.bottom == 0 ? 8 : 0) // 根據是否有安全區域調整間距
                .offset(y: geometry.safeAreaInsets.bottom == 0 ? 0 : -8) // 有安全區域時往上偏移一點
            }
            .ignoresSafeArea(.keyboard) // 忽略鍵盤
        }
    }
}

struct TabBarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 40, height: 40)
                    }

                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .blue : .gray)
                }

                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .frame(width: 60) // 減少按鈕寬度
        }
    }
}

#Preview {
    MainTabView()
}
