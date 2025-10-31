import SwiftUI

struct OutcomeInputView: View {
    @Binding var actualPitchZone: String?
    @Binding var actualBallsOffPlate: Int?
    @Binding var outcome: OutcomeSelection?

    let calledPitchZone: Int
    let pitchType: String
    let calledBallsOffPlate: Int
    let pitchCount: String
    let isNewBatter: Bool

    var onSubmit: () -> Void
    
    @State private var showValidationAlert = false

    var body: some View {
        HStack(spacing: 40) {
            VStack {
                Text("Actual Pitch Zone")
                    .font(.headline)
                ActualStrikeZoneSelector(selectedZone: $actualPitchZone)
                Text("Select zone or zone between zones")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            VStack(spacing: 40) {
                VStack(alignment: .leading) {
                    Text("Balls Off Plate")
                        .font(.headline)
                    ActualBallsOffPlateSelector(selectedOffset: $actualBallsOffPlate)
                }

                VStack(alignment: .leading) {
                    Text("Pitch Outcome")
                        .font(.headline)
                    OutcomeSelector(selectedOutcome: $outcome)
                }

                Spacer()

                HStack {
                    Spacer()
                    Button(action: {
                        if isValid() {
                            switch outcome {
                            case .swing:
                                onSubmit()
                            case .noSwing:
                                onSubmit()
                            case .hbp:
                                onSubmit()
                            case .none:
                                break
                            }
                        } else {
                            showValidationAlert = true
                        }
                    }) {
                        Text("Submit")
                            .font(.title2.bold())
                            .padding()
                            .frame(width: 160)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Pitch Outcome")
        .alert("Missing Input", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please complete all fields before submitting.")
        }
    }

    private func isValid() -> Bool {
        return actualPitchZone != nil &&
               actualBallsOffPlate != nil &&
               outcome != nil
    }
}
