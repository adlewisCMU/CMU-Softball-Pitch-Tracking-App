import SwiftUI

struct ContentView: View {
    @State private var sessionStarted = false
    @EnvironmentObject var session: Session

    var body: some View {
        if sessionStarted {
            PitchTrackingView()
        } else {
            StartSessionView(onStart: {
                sessionStarted = true
            })
        }
    }
}
