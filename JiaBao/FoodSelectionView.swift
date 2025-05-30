import SwiftUI
import MapKit

// 更新餐廳資訊結構
struct Restaurant {
    let name: String
    let rating: Double
    let priceLevel: String
    let cuisine: String
    let openHours: String
    let phoneNumber: String
    let photos: [String]  // 餐廳照片名稱陣列
}

struct FoodSelectionView: View {
    @State private var showingFoodCard = false
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var locationAddress: String = ""
    @State private var isGenerating = false
    @State private var selectedRestaurant: Restaurant?

    // 更新模擬餐廳資料
    private let restaurants = [
        Restaurant(
            name: "阿明餐館",
            rating: 4.5,
            priceLevel: "$$",
            cuisine: "台式料理",
            openHours: "11:00 - 21:00",
            phoneNumber: "04-2222-3333",
            photos: ["https://hips.hearstapps.com/hmg-prod/images/fotojet-13-672caa74adf9c.jpg?crop=1.00xw:1.00xh;0,0&resize=1200:*", "restaurant1_2", "restaurant1_3"]  // 這裡需要實際的圖片資源
        ),
        Restaurant(
            name: "樂園麵食館",
            rating: 4.3,
            priceLevel: "$",
            cuisine: "麵食",
            openHours: "10:30 - 20:30",
            phoneNumber: "04-2333-4444",
            photos: ["https://gcp-obs.line-scdn.net/0h0lueR7Osb0NIHHpZmEcQFHFKYzJ7bmlLMWRyJW8dZXEyLjQWJy5wOWhMMXt5JSFAc2Yjdm4VNXtkLSpAdHs/w1200", "restaurant2_2", "restaurant2_3"]
        ),
        Restaurant(
            name: "日月食堂",
            rating: 4.7,
            priceLevel: "$$$",
            cuisine: "日本料理",
            openHours: "11:30 - 21:30",
            phoneNumber: "04-2444-5555",
            photos: ["https://wowlavie-aws.hmgcdn.com/files/article/a2/24484/atl_m_24484_20240426185857_574.jpg", "restaurant3_2", "restaurant3_3"]
        )
    ]

    var body: some View {
        ZStack {
            // 背景
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)

            // 主按鈕置中
            GeometryReader { geometry in
                CircleButton(
                    isGenerating: isGenerating,
                    action: generateRandomFood
                )
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height / 2 - 30 // 稍微往上移動一點
                )
            }

            // 彈出卡片
            if showingFoodCard {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showingFoodCard = false
                        }
                    }

                if let restaurant = selectedRestaurant {
                    FoodCard(
                        restaurant: restaurant,
                        isShowing: $showingFoodCard
                    )
                    .transition(.scale)
                }
            }
        }
        .animation(.spring(), value: showingFoodCard)
    }

    private func generateRandomFood() {
        guard !isGenerating else { return }
        isGenerating = true

        // 隨機選擇一家餐廳
        selectedRestaurant = restaurants.randomElement()

        // 台中市的地理邊界
        let taichungBounds = (
            minLat: 24.0382,
            maxLat: 24.3382,
            minLong: 120.4612,
            maxLong: 121.0004
        )

        // 生成隨機座標
        let randomLat = Double.random(in: taichungBounds.minLat...taichungBounds.maxLat)
        let randomLong = Double.random(in: taichungBounds.minLong...taichungBounds.maxLong)
        let location = CLLocation(latitude: randomLat, longitude: randomLong)

        // 更新座標
        selectedLocation = location.coordinate

        // 進行地理編碼
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let placemark = placemarks?.first {
                    let components = [
                        placemark.administrativeArea,
                        placemark.locality,
                        placemark.subLocality,
                        placemark.thoroughfare
                    ].compactMap { $0 }

                    locationAddress = components.isEmpty ? "未知位置" : components.joined(separator: " ")
                } else {
                    locationAddress = "未知位置"
                }

                // 顯示卡片
                withAnimation {
                    showingFoodCard = true
                    isGenerating = false
                }
            }
        }
    }
}

struct CircleButton: View {
    let isGenerating: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isGenerating ? Color.gray : Color.blue)
                    .frame(width: 150, height: 150)
                    .shadow(radius: 10)

                VStack(spacing: 10) {
                    if isGenerating {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 40))
                            .foregroundColor(.white)

                        Text("今天吃什麼？")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .disabled(isGenerating)
        .scaleEffect(isGenerating ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isGenerating)
    }
}

struct FoodCard: View {
    let restaurant: Restaurant
    @Binding var isShowing: Bool
    @State private var currentImageIndex = 0
    @State private var showingCallAlert = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        // 照片輪播
                        TabView(selection: $currentImageIndex) {
                            ForEach(0..<restaurant.photos.count, id: \.self) { index in
                                if let url = URL(string: restaurant.photos[index]) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        case .failure(_):
                                            Image(systemName: "photo")
                                                .font(.largeTitle)
                                                .foregroundColor(.gray)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                } else {
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 15))

                        // 餐廳名稱和評分
                        HStack {
                            Text(restaurant.name)
                                .font(.title2)
                                .fontWeight(.bold)

                            Spacer()

                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", restaurant.rating))
                                    .fontWeight(.semibold)
                            }
                        }

                        // 基本資訊
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.blue)
                                Text("費用：\(restaurant.priceLevel)")
                            }

                            HStack(spacing: 8) {
                                Image(systemName: "fork.knife.circle.fill")
                                    .foregroundColor(.blue)
                                Text("料理：\(restaurant.cuisine)")
                            }

                            HStack(spacing: 8) {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.blue)
                                Text("營業時間：\(restaurant.openHours)")
                            }

                            Button(action: {
                                showingCallAlert = true
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "phone.circle.fill")
                                        .foregroundColor(.blue)
                                    Text(restaurant.phoneNumber)
                                        .foregroundColor(.blue)
                                        .underline()
                                }
                            }
                        }
                        .font(.system(size: 16))
                    }
                    .padding()
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(radius: 10)
            )
            .frame(
                width: geometry.size.width * 0.9,
                height: geometry.size.height * 0.6
            )
            .position(
                x: geometry.size.width / 2,
                y: geometry.size.height / 2
            )
        }
        .alert("撥打電話", isPresented: $showingCallAlert) {
            Button("取消", role: .cancel) { }
            Button("撥打") {
                let number = restaurant.phoneNumber.replacingOccurrences(
                    of: "[^0-9]",
                    with: "",
                    options: .regularExpression
                )
                if let url = URL(string: "tel://\(number)"),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("是否要撥打 \(restaurant.phoneNumber)?")
        }
    }
}

extension View {
    func maxHeight(_ height: CGFloat) -> some View {
        frame(maxHeight: height)
    }
}

#Preview {
    FoodSelectionView()
}
