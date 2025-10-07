import SwiftUI

struct CallInputView: View {
    @Binding var calledPitchZone: Int?
    @Binding var pitchType: String
    @Binding var calledBallsOffPlate: Int?

    let pitchTypes = ["Fastball", "Drop", "Rise", "Curve", "Screw", "Change Up", "Drop Curve"]

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
            }
        }
        .padding()
        .navigationTitle("Call Pitch")
    }
}
