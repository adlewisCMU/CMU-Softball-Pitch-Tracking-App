import SwiftUI

struct ActualBallsOffPlateSelector: View {
    @Binding var selectedOffset: Int?

    let values = [1, 2, 3]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(values, id: \.self) { value in
                Button(action: {
                    selectedOffset = value
                }) {
                    Text(value == 3 ? "3+" : "\(value)")
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
        .frame(height: 60)
    }
}
