import Foundation

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
    var actualPitchZone: String  // can be 0 through 4, but can also be "Zone-Zone" to indicate between zones
    var actualBallsOffPlate: Int  // 1, 2, 3
    var isStrike: Bool
    var isHBP: Bool
    var didSwing: Bool
    var madeContact: Bool
    var isHit: Bool
    var isOut: Bool
    var isError: Bool
}