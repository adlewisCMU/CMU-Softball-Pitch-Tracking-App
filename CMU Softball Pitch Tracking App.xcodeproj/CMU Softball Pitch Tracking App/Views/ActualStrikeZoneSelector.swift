import SwiftUI

struct ActualStrikeZoneSelector: View {
    @Binding var selectedZone: String?

    let zones: [[String]] = [
        ["3", "3-4", "4"],
        ["1-3", "0", "2-4"],
        ["1", "1-2", "2"]
    ]

    var body: some View {
        VStack(spacing: 4) {
            ForEach(zones, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(row, id: \.self) { zone in
                        zoneButton(zone)
                    }
                }
            }
        }
        .frame(width: 240, height: 240)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
    }

    func zoneButton(_ zone: String) -> some View {
        Button(action: {
            selectedZone = zone
        }) {
            ZStack {
                Rectangle()
                    .fill(selectedZone == zone ? Color.blue : Color.white)
                    .frame(width: 70, height: 70)
                    .border(Color.black, width: 1)

                Text(zone)
                    .font(.title2)
                    .foregroundColor(.black)
            }
        }
    }
}
