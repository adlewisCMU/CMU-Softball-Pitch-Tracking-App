import SwiftUI

struct PitchTrackingView: View {
    @ObservedObject var session: Session

    @State private var path = NavigationPath()

    // Pitch input states
    @State private var calledPitchZone: Int?
    @State private var pitchType: String = "Fastball"
    @State private var calledBallsOffPlate: Int?

    @State private var actualPitchZone: String?
    @State private var actualBallsOffPlate: Int?
    @State private var outcome: OutcomeSelection?

    var body: some View {
        NavigationStack(path: $path) {
            // First screen: CallInputView
            CallInputView(
                calledPitchZone: $calledPitchZone,
                pitchType: $pitchType,
                calledBallsOffPlate: $calledBallsOffPlate,
                session: session,
                onSubmit: {
                    path.append(Screen.outcome)
                },
                onEndSession: {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        if let viewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                            session.exportCSV(from: viewController)
                            session.reset()
                            path = NavigationPath()
                        }
                    }
                }
            )
            .navigationDestination(for: Screen.self) { screen in
                switch screen {
                case .outcome:
                    OutcomeInputView(
                        actualPitchZone: $actualPitchZone,
                        actualBallsOffPlate: $actualBallsOffPlate,
                        outcome: $outcome,
                        calledPitchZone: calledPitchZone ?? 0,
                        pitchType: pitchType,
                        calledBallsOffPlate: calledBallsOffPlate ?? 0,
                        pitchCount: session.currentPitchCountString(),
                        isNewBatter: false,
                        onSubmit: handleOutcomeSubmit
                    )
                case .swingResult:
                    SwingResultView(
                        actualPitchZone: actualPitchZone ?? "0",
                        actualBallsOffPlate: actualBallsOffPlate ?? 0,
                        calledPitchZone: calledPitchZone ?? 0,
                        pitchType: pitchType,
                        calledBallsOffPlate: calledBallsOffPlate ?? 0,
                        pitchCount: session.currentPitchCountString(),
                        isNewBatter: false
                    )
                case .noSwingResult:
                    NoSwingResultView(
                        actualPitchZone: actualPitchZone ?? "0",
                        actualBallsOffPlate: actualBallsOffPlate ?? 0,
                        calledPitchZone: calledPitchZone ?? 0,
                        pitchType: pitchType,
                        calledBallsOffPlate: calledBallsOffPlate ?? 0,
                        pitchCount: session.currentPitchCountString(),
                        isNewBatter: false
                    )
                }
            }
            .environmentObject(session)
            .onAppear {
                resetPitchInput()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func handleOutcomeSubmit() {
        guard let outcome = outcome else { return }

        switch outcome {
        case .swing:
            path.append(Screen.swingResult)
        case .noSwing:
            path.append(Screen.noSwingResult)
        case .hbp:
            session.addPitch(
                resultType: .hbp,
                pitcher: session.pitcherName,
                calledPitchZone: calledPitchZone ?? 0,
                pitchType: pitchType,
                calledBallsOffPlate: calledBallsOffPlate ?? 0,
                actualPitchZone: actualPitchZone ?? "0",
                actualBallsOffPlate: actualBallsOffPlate ?? 0
            )
            resetPitchInput()
            path = NavigationPath() // Return to CallInputView
        }
    }


    private func resetPitchInput() {
        calledPitchZone = nil
        pitchType = "Fastball"
        calledBallsOffPlate = nil
        actualPitchZone = nil
        actualBallsOffPlate = nil
        outcome = nil
    }

    enum Screen: Hashable {
        case outcome, swingResult, noSwingResult
    }
}
