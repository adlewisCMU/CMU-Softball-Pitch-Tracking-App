import SwiftUI

struct CallInputView: View {
    @Binding var calledPitchZone: Int?
    @Binding var pitchType: String
    @Binding var calledBallsOffPlate: Int?
    
    let session: Session
    let onSubmit: () -> Void
    let onEndSession: () -> Void

    let pitchTypes = ["Fastball", "Drop", "Rise", "Curve", "Screw", "Change Up", "Drop Curve"]

    @State private var showValidationAlert = false
    @State private var showExitAlert = false

    // variables for pitcher change
    @State private var showChangePitcherConfirm = false
    @State private var showChangePitcherSheet = false
    @State private var newPitcherName = ""

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

                Button(action: {
                    showChangePitcherConfirm = true
                }) {
                    Text("Change Pitcher")
                        .font(.body)
                        .padding()
                        .background(Color.blue.opacity(0.15))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                }
                .confirmationDialog("Change Pitcher?", isPresented: $showChangePitcherConfirm) {
                    Button("Yes, Change Pitcher") {
                        newPitcherName = ""
                        showChangePitcherSheet = true
                    }
                    Button("Cancel", role: .cancel) {}
                }

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

            Button(action: {
                showExitAlert = true
            }) {
                Text("End Session")
                    .font(.body)
                    .padding(12)
                    .foregroundColor(.red)
            }
            .alert("End Session?", isPresented: $showExitAlert) {
                Button("Export & End", role: .destructive) {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        if let viewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                            session.exportCSV(from: viewController)
                            session.reset()
                        }
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
            .padding(.leading, 20)
            .padding(.bottom, 20)
        }
        .padding()
        .navigationTitle("Call Pitch")
        .alert("Missing Input", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please select a pitch zone, pitch type, and balls off plate value.")
        }

        .sheet(isPresented: $showChangePitcherSheet) {
            VStack(spacing: 20) {
                Text("New Pitcher Name")
                    .font(.title2.bold())

                TextField("Enter new pitcher name", text: $newPitcherName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                HStack {
                    Button("Cancel") {
                        showChangePitcherSheet = false
                    }

                    Spacer()

                    Button("Confirm") {
                        let trimmed = newPitcherName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            session.changePitcher(to: trimmed)
                            showChangePitcherSheet = false
                        }
                    }
                    .disabled(newPitcherName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)
            }
            .padding()
            .presentationDetents([.height(260)])
        }
    }

    private func isValid() -> Bool {
        return calledPitchZone != nil &&
               calledBallsOffPlate != nil &&
               !pitchType.isEmpty
    }
}
