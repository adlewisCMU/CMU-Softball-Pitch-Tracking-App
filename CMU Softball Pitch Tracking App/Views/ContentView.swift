import SwiftUI

struct ContentView: View {
    @StateObject private var session = Session()
    
    var body: some View {
        PitchTrackingView(session: session)
    }
}
