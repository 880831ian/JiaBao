import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("版本 v0.0.1")
                } header: {
                    Text("關於")
                }
                Section {
                    Text("CHUANG,PIN-YI")
                } header: {
                    Text("作者")
                }
            }
            .navigationTitle("設定")
        }
    }
}

#Preview {
    SettingsView()
}
