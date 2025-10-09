import SwiftUI

struct SwingResultView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session: Session

    let actualPitchZone: String
    let actualBallsOffPlate: Int
    let calledPitchZone: Int
    let pitchType: String
    let calledBallsOffPlate: Int
    let pitchCount: String
    let isNewBatter: Bool

    let swingResults = ["Strike", "Foul", "Hit", "Out", "Error"]

    var body: some View {
        VStack(spacing: 24) {
            Text("Swing Outcome")
                .font(.largeTitle)
                .bold()

            ForEach(swingResults, id: \.self) { result in
                Button(action: {
                    handleSwingResult(result)
                }) {
                    Text(result)
                        .font(.title2)
                        .frame(width: 200, height: 50)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }

            Spacer()
        }
        .padding()
    }

    func handleSwingResult(_ result: String) {
        let resultType: PitchResultType

        switch result {
        case "Strike": resultType = .swingStrike
        case "Foul":   resultType = .swingFoul
        case "Hit":    resultType = .swingHit
        case "Out":    resultType = .swingOut
        case "Error":  resultType = .swingError
        default:       return
        }

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
