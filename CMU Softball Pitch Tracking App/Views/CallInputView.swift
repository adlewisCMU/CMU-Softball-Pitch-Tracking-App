import SwiftUI

struct CallInputView: View {
    @Binding var calledPitchZone: Int?
    @Binding var pitchType: String
    @Binding var calledBallsOffPlate: Int?

    let pitchTypes = ["Fastball", "Drop", "Rise", "Curve", "Screw", "Change Up", "Drop Curve"]

    @State private var showValidationAlert = false

    var body: some View {
        HStack(spacing: 40) {
            // Left: Strike Zone
            VStack {
                Text("Called Pitch Zone")
                    .font(.headline)
                StrikeZoneSelector(selectedZone: $calledPitchZone)
            }

            VStack(spacing: 40) {
                VStack(alignment: .leading) {
                    Text("Pitch Type")
                        .font(.headline)
                    Picker("Pitch Type", selection: $pitchType) {
                        ForEach(pitchTypes, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)
                }

                VStack(alignment: .leading) {
                    Text("Balls Off Plate")
                        .font(.headline)
                    BallsOffPlateSelector(selectedOffset: $calledBallsOffPlate)
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
                    .padding(.top, 20)
                }
            }
        }
        .padding()
        .navigationTitle("Call Pitch")
        .alert("Missing Input", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please select a pitch zone, pitch type, and balls off plate value.")
        }
    }

    private func isValid() -> Bool {
        return calledPitchZone != nil &&
               calledBallsOffPlate != nil &&
               !pitchType.isEmpty
    }
}
