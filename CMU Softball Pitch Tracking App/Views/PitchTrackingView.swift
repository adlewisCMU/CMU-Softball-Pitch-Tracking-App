import SwiftUI

struct PitchTrackingView: View {
    @EnvironmentObject var session: Session
    @Binding var sessionActive: Bool

    @State private var path = NavigationPath()

    @State private var calledPitchZone: Int?
    @State private var pitchType: String = "Fastball"
    @State private var calledBallsOffPlate: Int?

    @State private var actualPitchZone: String?
    @State private var actualBallsOffPlate: Int?
    @State private var outcome: OutcomeSelection?

    var body: some View {
        NavigationStack(path: $path) {
            CallInputView(
                calledPitchZone: $calledPitchZone,
                pitchType: $pitchType,
                calledBallsOffPlate: $calledBallsOffPlate,
                session: session,
                onSubmit: {
                    path.append(Screen.outcome)
                },
                onEndSession: handleEndSession
            )
            StatsBox(session: session)
                .padding(.top, 16)
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
                        isNewBatter: false,
                        onDone: {
                            resetPitchInput()
                            path = NavigationPath()
                        }
                    )
                case .noSwingResult:
                    NoSwingResultView(
                        actualPitchZone: actualPitchZone ?? "0",
                        actualBallsOffPlate: actualBallsOffPlate ?? 0,
                        calledPitchZone: calledPitchZone ?? 0,
                        pitchType: pitchType,
                        calledBallsOffPlate: calledBallsOffPlate ?? 0,
                        pitchCount: session.currentPitchCountString(),
                        isNewBatter: false,
                        onDone: {
                            resetPitchInput()
                            path = NavigationPath()
                        }
                    )
                }
            }
            .onAppear {
                resetPitchInput()
                path = NavigationPath()
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
            path = NavigationPath()
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
    
    private func handleEndSession() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let viewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                session.exportCSV(from: viewController, opponentName: session.opponentName)
        }
        session.reset()
        path = NavigationPath()
        resetPitchInput()
        sessionActive = false
    }

    enum Screen: Hashable {
        case outcome, swingResult, noSwingResult
    }
}
