import SwiftUI

struct StatsBox: View {
    @ObservedObject var session: Session

    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            Text("Pitcher: \(session.pitcherName)")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Pitcher's Total Pitches: \(session.currentPitcherStats.pitchCount)")
                .font(.subheadline)
                .foregroundColor(.white)

            Text("Pitcher's Batters Faced: \(session.currentPitcherStats.batterCount)")
                .font(.subheadline)
                .foregroundColor(.white)
            
            Text("Pitch Count: \(session.currentPitchCountString())")
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding(12)
        .background(Color.black.opacity(0.7))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .topTrailing)
    }
}
