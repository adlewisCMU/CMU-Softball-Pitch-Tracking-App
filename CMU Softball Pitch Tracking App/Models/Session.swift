import Foundation

class Session {
    private(set) var pitches: [Pitch] = []
    private var overallPitchNum = 0
    private var batterNum = 0
    private var pitcherStats: [String: (pitchCount: Int, batterCount: Int)] = [:]

    func addPitch(
        pitcher: String,
        pitchCount: String,
        calledPitchZone: Int,
        pitchType: String,
        calledBallsOffPlate: Int,
        actualPitchZone: Int,
        actualBallsOffPlate: Int,
        isStrike: Bool,
        isHBP: Bool,
        didSwing: Bool,
        madeContact: Bool,
        isHit: Bool,
        isOut: Bool,
        isError: Bool,
        newBatter: Bool
    ) {
        overallPitchNum += 1

        if newBatter {
            batterNum += 1
        }

        // Initialize or update pitcher stats
        var pitcherPitchNum = 1
        var pitcherBatterNum = newBatter ? 1 : 0

        if var stats = pitcherStats[pitcher] {
            stats.pitchCount += 1
            if newBatter {
                stats.batterCount += 1
            }
            pitcherPitchNum = stats.pitchCount
            pitcherBatterNum = stats.batterCount
            pitcherStats[pitcher] = stats
        } else {
            pitcherStats[pitcher] = (1, newBatter ? 1 : 0)
        }

        let pitch = Pitch(
            pitchNum: overallPitchNum,
            pitcher: pitcher,
            pitcherPitchNum: pitcherPitchNum,
            batterNum: batterNum,
            pitcherBatterNum: pitcherBatterNum,
            pitchCount: pitchCount,
            calledPitchZone: calledPitchZone,
            pitchType: pitchType,
            calledBallsOffPlate: calledBallsOffPlate,
            actualPitchZone: actualPitchZone,
            actualBallsOffPlate: actualBallsOffPlate,
            isStrike: isStrike,
            isHBP: isHBP,
            didSwing: didSwing,
            madeContact: madeContact,
            isHit: isHit,
            isOut: isOut,
            isError: isError
        )

        pitches.append(pitch)
    }

    func reset() {
        pitches.removeAll()
        overallPitchNum = 0
        batterNum = 0
        pitcherStats.removeAll()
    }
}
