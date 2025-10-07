import SwiftUI

struct StrikeZoneSelector: View {
    @Binding var selectedZone: Int?

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                zoneButton(1)
                zoneButton(2)
            }
            HStack(spacing: 4) {
                zoneButton(3)
                zoneButton(4)
            }
        }
        .frame(width: 200, height: 200)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
    }

    func zoneButton(_ zone: Int) -> some View {
        Button(action: {
            selectedZone = zone
        }) {
            ZStack {
                Rectangle()
                    .fill(selectedZone == zone ? Color.blue : Color.white)
                    .frame(width: 90, height: 90)
                    .border(Color.black, width: 1)

                Text("\(zone)")
                    .font(.title)
                    .foregroundColor(.black)
            }
        }
    }
}
