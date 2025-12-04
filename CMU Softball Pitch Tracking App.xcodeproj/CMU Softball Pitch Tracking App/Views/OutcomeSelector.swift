import SwiftUI

enum OutcomeSelection: String, Codable {
    case swing = "Swing"
    case noSwing = "No Swing"
    case hbp = "HBP"
}

struct OutcomeSelector: View {
    @Binding var selectedOutcome: OutcomeSelection?

    let options: [OutcomeSelection] = [.swing, .noSwing, .hbp]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(options, id: \.self) { outcome in
                Button(action: {
                    selectedOutcome = outcome
                }) {
                    Text(outcome.rawValue)
                        .font(.title3)
                        .padding()
                        .frame(width: 100)
                        .background(selectedOutcome == outcome ? Color.blue : Color.white)
                        .foregroundColor(selectedOutcome == outcome ? .white : .black)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black.opacity(0.5), lineWidth: 1)
                        )
                }
            }
        }
    }
}

