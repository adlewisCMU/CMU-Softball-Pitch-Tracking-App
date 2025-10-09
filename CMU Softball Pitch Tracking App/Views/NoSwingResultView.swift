import SwiftUI

struct NoSwingResultView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session: Session

    let actualPitchZone: String
    let actualBallsOffPlate: Int
    let calledPitchZone: Int
    let pitchType: String
    let calledBallsOffPlate: Int
    let pitchCount: String
    let isNewBatter: Bool

    var body: some View {
        VStack(spacing: 24) {
            Text("No Swing Outcome")
                .font(.largeTitle)
                .bold()

            Button(action: {
                handleNoSwingResult("Strike")
            }) {
                Text("Strike")
                    .font(.title2)
                    .frame(width: 200, height: 50)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }

            Button(action: {
                handleNoSwingResult("Ball")
            }) {
                Text("Ball")
                    .font(.title2)
                    .frame(width: 200, height: 50)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
    }

    func handleNoSwingResult(_ result: String) {
        let resultType: PitchResultType = (result == "Strike") ? .noSwingStrike : .noSwingBall
        let outcome = resultType.outcome

        session.addPitch(
            pitcher: session.pitcherName,
            pitchCount: pitchCount,
            calledPitchZone: calledPitchZone,
            pitchType: pitchType,
            calledBallsOffPlate: calledBallsOffPlate,
            actualPitchZone: actualPitchZone,
            actualBallsOffPlate: actualBallsOffPlate,
            isStrike: outcome.isStrike,
            isHBP: outcome.isHBP,
            didSwing: outcome.didSwing,
            madeContact: outcome.madeContact,
            isHit: outcome.isHit,
            isOut: outcome.isOut,
            isError: outcome.isError,
            newBatter: isNewBatter
        )

        dismiss()
    }
}
