import SwiftUI

struct BallsOffPlateSelector: View {
    @Binding var selectedOffset: Int?

    var body: some View {
        HStack(spacing: 8) {
            offsetButton(0)
            offsetButton(1)
        }
        .frame(height: 60)
    }

    func offsetButton(_ value: Int) -> some View {
        Button(action: {
            selectedOffset = value
        }) {
            Text("\(value)")
                .font(.title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedOffset == value ? Color.green : Color.gray.opacity(0.2))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 1)
                )
        }
    }
}
