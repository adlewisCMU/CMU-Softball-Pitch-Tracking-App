struct Pitch: Identifiable, Codable {
    let id = UUID()
    
    // pitch identifiers
    var pitchNum: Int
    var pitcher: String
    var pitcherPitchNum: Int
    var batterNum: Int
    var pitcherBatterNum: Int

    // extra details
    var pitchCount: String  // Example: "3-2", "0-0"
    
    // coach's call
    var calledPitchZone: Int  // 1-4
    var pitchType: String     // Example: "Fastball"
    var calledBallsOffPlate: Int  // 1, 2
    
    // actual outcome
    var actualPitchZone: Int  // 1-9
    var actualBallsOffPlate: Int  // 1, 2, 3
    var isStrike: Bool
    var isHBP: Bool
    var didSwing: Bool
    var madeContact: Bool
    var isHit: Bool
    var isOut: Bool
    var isError: Bool
}

func updateCount(currentCount: String, call: String) -> String {
    let parts: [String.SubSequence] = currentCount.split(separator: "-")
    guard parts.count == 2,
          var balls: Int = Int(parts[0]),
          var strikes: Int = Int(parts[1]) else {
        return currentCount
    }

    switch call.lowercased() {
        case "ball":
            balls += 1
        case "strike":
            strikes += 1
        case "foul":
            if strikes < 2 {
                strikes += 1
            }
        default:
            print("Invalid pitch call: \(call)")
    }

    return "\(balls)-\(strikes)"
}

func resetCount() -> String {
    return "0-0"
}