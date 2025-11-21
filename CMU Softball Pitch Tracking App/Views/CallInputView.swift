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
    
    @State private var showChangePitcherConfirm = false
    @State private var showChangePitcherSheet = false
    @State private var newPitcherName = ""
    
    @State private var invalidPitchZone = false
    @State private var invalidPitchType = false
    @State private var invalidBallsOffPlate = false
    
    var body: some View {
        VStack {
            // Main Content Section (Pitch Zone, Pitch Type, Balls Off Plate)
            HStack(spacing: 40) {
                VStack {
                    Text("Called Pitch Zone")
                        .font(.headline)
                    StrikeZoneSelector(selectedZone: $calledPitchZone)
                        .border(invalidPitchZone ? Color.red : Color.clear, width: 2) // Highlight if invalid
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
                        .border(invalidPitchType ? Color.red : Color.clear, width: 2) // Highlight if invalid
                    }

                    VStack(alignment: .leading) {
                        Text("Balls Off Plate")
                            .font(.headline)
                        BallsOffPlateSelector(selectedOffset: $calledBallsOffPlate)
                            .border(invalidBallsOffPlate ? Color.red : Color.clear, width: 2) // Highlight if invalid
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

            Spacer() // This pushes the content upwards and ensures the InningBox is at the bottom
            
            // InningBox placed at the bottom-left of the screen
            HStack {
                InningBox(session: session)
                    .frame(width: 180) // Adjust the width as needed
                Spacer() // Pushes InningBox to the left
            }
            .padding(.leading, 16)
            .padding(.bottom, 20) // Gives some space from the bottom edge

        }
        .navigationTitle("Call Pitch")
        .alert("Missing Input", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(validationMessage())
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
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    showChangePitcherConfirm = true
                }) {
                    Text("Change Pitcher")
                        .font(.body)
                        .padding(8)
                        .foregroundColor(.blue)
                }
                .confirmationDialog("Change Pitcher?", isPresented: $showChangePitcherConfirm) {
                    Button("Yes, Change Pitcher") {
                        newPitcherName = ""
                        showChangePitcherSheet = true
                    }
                    Button("Cancel", role: .cancel) {}
                }

                Button(action: {
                    showExitAlert = true
                }) {
                    Text("Export & End")
                        .font(.body)
                        .padding(8)
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
            }
        }
    }

    private func isValid() -> Bool {
        invalidPitchZone = calledPitchZone == nil
        invalidPitchType = pitchType.isEmpty
        invalidBallsOffPlate = calledBallsOffPlate == nil

        return !invalidPitchZone && !invalidPitchType && !invalidBallsOffPlate
    }

    private func validationMessage() -> String {
        var message = "Please select a pitch zone, pitch type, and balls off plate value."
        if invalidPitchZone { message += "\n- Pitch Zone" }
        if invalidPitchType { message += "\n- Pitch Type" }
        if invalidBallsOffPlate { message += "\n- Balls Off Plate" }
        return message
    }
}
