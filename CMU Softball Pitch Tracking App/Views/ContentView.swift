import SwiftUI

struct ContentView: View {
    var body: some View {
        PitchTrackingView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
