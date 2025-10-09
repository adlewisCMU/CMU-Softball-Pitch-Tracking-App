import SwiftUI

struct StartSessionView: View {
    @ObservedObject var session: Session

    @State private var pitcherName = ""
    @State private var opponentName = ""
    @State private var navigateToTracking = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Start Pitch Tracking")
                    .font(.largeTitle)
                    .padding(.top, 20)

                VStack(alignment: .leading) {
                    Text("Pitcher Name")
                        .font(.headline)
                    TextField("Enter pitcher's name", text: $pitcherName)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading) {
                    Text("Opponent Name (Optional)")
                        .font(.headline)
                    TextField("Leave blank for Practice", text: $opponentName)
                        .textFieldStyle(.roundedBorder)
                }

                Spacer()

                NavigationLink(
                    destination: PitchTrackingView(session: session),
                    isActive: $navigateToTracking
                ) {
                    EmptyView()
                }

                Button(action: {
                    session.startSession(pitcher: pitcherName, opponent: opponentName)
                    navigateToTracking = true
                }) {
                    Text("Start Session")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(pitcherName.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(pitcherName.isEmpty)

                Spacer()
            }
            .padding()
        }
    }
}
