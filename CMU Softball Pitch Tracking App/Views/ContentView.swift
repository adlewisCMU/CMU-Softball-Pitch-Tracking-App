import SwiftUI

struct ContentView: View {
    @State private var sessionStarted = false
    @EnvironmentObject var session: Session

    var body: some View {
        if sessionStarted {
            PitchTrackingView(sessionActive: $sessionStarted)
                .environmentObject(session)
        } else {
            StartSessionView(onStart: {
                sessionStarted = true
            })
            .environmentObject(session)
        }
    }
}
