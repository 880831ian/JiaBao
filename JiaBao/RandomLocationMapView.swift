import SwiftUI
import MapKit
import CoreLocation

// 新增一個符合 Identifiable 的結構體來存儲位置資訊
struct LocationPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct RandomLocationMapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.1477, longitude: 120.6736), // 台中市中心
        span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
    )

    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var locationPin: LocationPin?
    @State private var locationAddress: String = ""
    @State private var showingLocationCard = false
    @State private var isGenerating = false
    @State private var isMapMoving = false
    @State private var lastUpdateTime = Date()

    // 台中市的地理邊界
    private let taichungBounds = (
        minLat: 24.0382,  // 南邊（大肚、龍井）
        maxLat: 24.3382,  // 北邊（后里、東勢）
        minLong: 120.4612, // 西邊（大甲、清水）
        maxLong: 121.0004  // 東邊（和平）
    )

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 地圖視圖
                if let pin = locationPin {
                    Map(coordinateRegion: $region,
                        showsUserLocation: true,
                        annotationItems: [pin]) { pin in
                        MapAnnotation(coordinate: pin.coordinate) {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                .shadow(radius: 3)
                        }
                    }
                    .edgesIgnoringSafeArea(.all)
                } else {
                    Map(coordinateRegion: $region, showsUserLocation: true)
                        .edgesIgnoringSafeArea(.all)
                }

                VStack {
                    Spacer()

                    // 位置卡片
                    if let location = selectedLocation {
                        LocationCard(coordinate: location, address: locationAddress)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                                    .shadow(radius: 10)
                            )
                            .padding(.horizontal)
                            .transition(.move(edge: .bottom))
                            .animation(.spring(), value: showingLocationCard)
                    }

                    // 隨機按鈕
                    Button(action: generateRandomLocation) {
                        HStack {
                            if isGenerating {
                                ProgressView()
                                    .tint(.white)
                                    .padding(.trailing, 5)
                            }
                            Text(isGenerating ? "搜尋中..." : "隨機選擇台中地點")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(
                            Capsule()
                                .fill(isGenerating || isMapMoving ? Color.gray : Color.blue)
                                .shadow(radius: 5)
                        )
                    }
                    .disabled(isGenerating || isMapMoving)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 135) // 確保在 TabBar 上方
                }
            }
            .onChange(of: region.center.latitude) { _ in
                handleMapMovement()
            }
            .onChange(of: region.center.longitude) { _ in
                handleMapMovement()
            }
        }
    }

    private func handleMapMovement() {
        let now = Date()
        if now.timeIntervalSince(lastUpdateTime) > 0.1 {
            lastUpdateTime = now
            if !isMapMoving {
                isMapMoving = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isMapMoving = false
            }
        }
    }

    private func generateRandomLocation() {
        guard !isGenerating else { return }
        isGenerating = true
        isMapMoving = true
        locationAddress = "載入中..."

        // 生成隨機座標
        let randomLat = Double.random(in: taichungBounds.minLat...taichungBounds.maxLat)
        let randomLong = Double.random(in: taichungBounds.minLong...taichungBounds.maxLong)
        let location = CLLocation(latitude: randomLat, longitude: randomLong)

        // 立即更新座標
        withAnimation(.easeInOut(duration: 1.0)) {
            selectedLocation = location.coordinate
            locationPin = LocationPin(coordinate: location.coordinate)
            showingLocationCard = true
            region.center = location.coordinate
            region.span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        }

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

                // 重置狀態
                isGenerating = false
                isMapMoving = false
            }
        }
    }
}

struct LocationCard: View {
    let coordinate: CLLocationCoordinate2D
    let address: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(address)
                .font(.headline)
                .foregroundColor(.primary)

            HStack {
                Text("緯度: \(String(format: "%.4f", coordinate.latitude))")
                Spacer()
                Text("經度: \(String(format: "%.4f", coordinate.longitude))")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    RandomLocationMapView()
}
