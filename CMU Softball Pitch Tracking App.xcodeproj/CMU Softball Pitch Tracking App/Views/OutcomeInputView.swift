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
        GeometryReader { geometry in
            ZStack(alignment: .top) {   // ★ FIX #1 — align from top instead of center

                // MARK: - Center Card (same position as CallInputView)
                HStack(alignment: .top, spacing: 30) {

                    // LEFT COLUMN
                    VStack(alignment: .center, spacing: 12) {
                        Text("Actual Pitch Zone")
                            .font(.headline)

                        ActualStrikeZoneSelector(selectedZone: $actualPitchZone)

                        Text("Select zone or zone between zones")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)

                    // RIGHT COLUMN
                    VStack(alignment: .leading, spacing: 20) {

                        VStack(alignment: .leading) {
                            Text("Balls Off Plate")
                                .font(.headline)
                            ActualBallsOffPlateSelector(selectedOffset: $actualBallsOffPlate)
                        }

                        VStack(alignment: .leading) {
                            Text("Pitch Outcome")
                                .font(.headline)
                            OutcomeSelector(selectedOutcome: $outcome)
                                .fixedSize(horizontal: true, vertical: true)
                        }

                        Spacer()

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
                    .frame(maxWidth: .infinity)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(radius: 10)
                )
                .frame(
                    maxWidth: .infinity,
                    maxHeight: geometry.size.height * 0.55
                )
                .padding(.top, geometry.safeAreaInsets.top + 50)   // ★ FIX #2 — correct position
                .padding(.horizontal, 16)


                // MARK: - Top-left Title (matches CallInputView)
                HStack {
                    Text("Pitch Outcome")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.leading, 16)
                    Spacer()
                }
                .padding(.top, geometry.safeAreaInsets.top)


                // MARK: - Bottom-left placeholder
                VStack {
                    Spacer()
                    HStack {
                        Spacer().frame(width: 0)
                        Spacer()
                    }
                    .padding(.leading, 16)
                    .padding(.bottom, 20)
                }

                // MARK: - Bottom-right placeholder
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Spacer().frame(width: 0)
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .alert("Missing Input", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please complete all fields before submitting.")
        }
    }

    private func isValid() -> Bool {
        actualPitchZone != nil &&
        actualBallsOffPlate != nil &&
        outcome != nil
    }
}
