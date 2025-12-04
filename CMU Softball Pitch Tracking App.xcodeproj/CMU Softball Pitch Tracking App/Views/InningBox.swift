import SwiftUI

struct InningBox: View {
    @ObservedObject var session: Session

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Inning: \(session.inning.components(separatedBy: ".").first ?? "1")")
                .font(.headline)
                .foregroundColor(.white)

            Text("Outs: \(session.inning.components(separatedBy: ".").last ?? "0")")
                .font(.subheadline)
                .foregroundColor(.white)

            Button(action: {
                session.addManualOut()
            }) {
                Text("Add Out")
                    .font(.subheadline.bold())
                    .foregroundColor(.black)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(8)
            }
        }
        .padding(12)
        .background(Color.black.opacity(0.7))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
