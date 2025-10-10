import SwiftUI
import SwiftData

@main
struct CMU_Softball_Pitch_Tracking_AppApp: App {
    @StateObject private var session = Session()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
