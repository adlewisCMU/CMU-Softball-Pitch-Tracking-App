import SwiftUI

struct OutcomeInputView: View {
    @Binding var actualPitchZone: String?
    @Binding var actualBallsOffPlate: Int?
    @Binding var outcome: OutcomeSelection?

    var onSubmit: () -> Void

    @State private var showValidationAlert = false

    var body: some View {
        HStack(spacing: 40) {
            // Actual Pitch Zone selector
            VStack {
                Text("Actual Pitch Zone")
                    .font(.headline)
                ActualStrikeZoneSelector(selectedZone: $actualPitchZone)
                Text("Select zone or zone between zones")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            VStack(spacing: 40) {
                // Balls off plate selector
                VStack(alignment: .leading) {
                    Text("Balls Off Plate")
                        .font(.headline)
                    ActualBallsOffPlateSelector(selectedOffset: $actualBallsOffPlate)
                }

                // Outcome selector
                VStack(alignment: .leading) {
                    Text("Pitch Outcome")
                        .font(.headline)
                    OutcomeSelector(selectedOutcome: $outcome)
                }

                Spacer()

                // Submit button with validation
                HStack {
                    Spacer()
                    Button(action: {
                        if isValid() {
                            onSubmit()
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
