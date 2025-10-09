import SwiftUI

struct BallsOffPlateSelector: View {
    @Binding var selectedOffset: Int?

    let values = [1, 2]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(values, id: \.self) { value in
                offsetButton(value)
            }
        }
        .frame(height: 60)
    }

    @ViewBuilder
    private func offsetButton(_ value: Int) -> some View {
        Button(action: {
            selectedOffset = value
        }) {
            Text("\(value)")
                .font(.title2)
                .frame(width: 80, height: 50)
                .background(selectedOffset == value ? Color.blue : Color.white)
                .foregroundColor(selectedOffset == value ? .white : .black)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black.opacity(0.5), lineWidth: 1)
                )
        }
    }
}

