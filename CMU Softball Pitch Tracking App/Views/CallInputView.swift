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
        GeometryReader { geometry in
            ZStack {
                // Main content (centered input form)
                VStack {
                    // Centered input form with selectors and submit button
                    VStack(spacing: 20) {
                        // Called Pitch Zone
                        VStack {
                            Text("Called Pitch Zone")
                                .font(.headline)
                            StrikeZoneSelector(selectedZone: $calledPitchZone)
                                .border(invalidPitchZone ? Color.red : Color.clear, width: 2) // Highlight if invalid
                        }

                        // Pitch Type
                        VStack {
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

                        // Balls Off Plate
                        VStack {
                            Text("Balls Off Plate")
                                .font(.headline)
                            BallsOffPlateSelector(selectedOffset: $calledBallsOffPlate)
                                .border(invalidBallsOffPlate ? Color.red : Color.clear, width: 2) // Highlight if invalid
                        }

                        // Submit Button
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
                    .frame(maxWidth: .infinity) // Make sure the form is centered and flexible
                    .padding(20) // Add padding to ensure the form has space around it
                    .background(RoundedRectangle(cornerRadius: 15).fill(Color.white).shadow(radius: 10)) // Optional styling
                    .padding(.top, geometry.safeAreaInsets.top + 50) // Add space from the top of the screen
                    .padding(.horizontal, 16) // Horizontal padding for consistency
                }

                // Top-left: Headline
                VStack {
                    HStack {
                        Text("Call Pitch")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.leading, 16)
                        Spacer()
                    }
                    Spacer()
                }

                // Bottom-left: InningBox
                VStack {
                    Spacer()
                    HStack {
                        InningBox(session: session)
                            .padding(.leading, 16) // Ensure it has proper space from the left
                            .padding(.bottom, 20)
                            .frame(maxWidth: .infinity)
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        StatsBox(session: session)  // This is the only stat box now
                            .padding(.trailing, 16)
                            .padding(.bottom, 20)
                            .frame(maxWidth: .infinity) // Allow it to expand based on content size
                    }
                }

                // Top-right: Toolbar (buttons for changing pitcher and exporting)
                VStack {
                    HStack {
                        Spacer()
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
                    .padding(.top, 16)
                    .padding(.trailing, 16)
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true) // Hide default navigation bar if needed
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
