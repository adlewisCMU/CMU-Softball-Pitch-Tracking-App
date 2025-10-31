import Foundation
import SwiftUI
import Combine

class Session: ObservableObject {
    @Published private(set) var pitches: [Pitch] = []
    @Published var pitcherName: String = ""
    @Published var opponentName: String = "Practice"
    @Published var overallPitchNum = 0
    @Published var batterNum = 0
    private var pitcherStats: [String: (pitchCount: Int, batterCount: Int)] = [:]

    private var currentStrikes = 0
    private var currentBalls = 0

    func addPitch(
        resultType: PitchResultType,
        pitcher: String,
        calledPitchZone: Int,
        pitchType: String,
        calledBallsOffPlate: Int,
        actualPitchZone: String,
        actualBallsOffPlate: Int
    ) {
        let outcome = resultType.outcome
        updatePitchCount(from: resultType)
        let isStrikeout = currentStrikes >= 3 && outcome.isStrike
        let pitchCount = currentPitchCountString()
        let newBatter = shouldResetCount(from: resultType)

        if newBatter {
            resetPitchCount()
            batterNum += 1
        }

        overallPitchNum += 1
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
            pitcher: self.pitcherName,
            pitcherPitchNum: pitcherPitchNum,
            batterNum: batterNum,
            pitcherBatterNum: pitcherBatterNum,
            pitchCount: pitchCount,
            calledPitchZone: calledPitchZone,
            pitchType: pitchType,
            calledBallsOffPlate: calledBallsOffPlate,
            actualPitchZone: actualPitchZone,
            actualBallsOffPlate: actualBallsOffPlate,
            isStrike: outcome.isStrike,
            isHBP: outcome.isHBP,
            didSwing: outcome.didSwing,
            madeContact: outcome.madeContact,
            isHit: outcome.isHit,
            isOut: outcome.isOut || isStrikeout,
            isError: outcome.isError
        )

        pitches.append(pitch)
    }

    func reset() {
        pitches.removeAll()
        overallPitchNum = 0
        batterNum = 0
        pitcherStats.removeAll()
    }

    func startSession(pitcher: String, opponent: String?) {
        self.pitcherName = pitcher
        self.opponentName = opponent?.isEmpty == false ? opponent! : "Practice"
        reset()
    }

    func exportCSV(from viewController: UIViewController, opponentName: String? = nil) {
        let csv = generateCSV()
        shareCSVFile(from: viewController, csvString: csv, opponentName: opponentName)
    }

    func currentPitchCountString() -> String {
        return "\(currentBalls)-\(currentStrikes)"
    }

    private func resetPitchCount() {
        currentBalls = 0
        currentStrikes = 0
    }

    private func updatePitchCount(from resultType: PitchResultType) {
        switch resultType {
        case .swingStrike, .noSwingStrike:
            if currentStrikes < 3 {
                currentStrikes += 1
            }
        case .swingFoul:
            if currentStrikes < 2 {
                currentStrikes += 1
            }
        case .noSwingBall:
            currentBalls += 1
        default:
            break
        }
    }

    private func shouldResetCount(from resultType: PitchResultType) -> Bool {
        switch resultType {
        case .hbp, .swingHit, .swingOut, .swingError:
            return true
        case .noSwingBall:
            return currentBalls >= 4
        case .swingStrike, .noSwingStrike, .swingFoul:
            return currentStrikes >= 3
        default:
            return false
        }
    }

    private func generateCSV() -> String {
        var rows: [String] = []
        let header = [
            "pitchNum", "pitcher", "pitcherPitchNum", "batterNum", "pitcherBatterNum",
            "pitchCount", "calledPitchZone", "pitchType", "calledBallsOffPlate",
            "actualPitchZone", "actualBallsOffPlate",
            "isStrike", "isHBP", "didSwing", "madeContact", "isHit", "isOut", "isError"
        ]
        rows.append(header.joined(separator: ","))

        for pitch in pitches {
            let row = [
                String(pitch.pitchNum),
                pitch.pitcher,
                String(pitch.pitcherPitchNum),
                String(pitch.batterNum),
                String(pitch.pitcherBatterNum),
                pitch.pitchCount,
                String(pitch.calledPitchZone),
                pitch.pitchType,
                String(pitch.calledBallsOffPlate),
                pitch.actualPitchZone,
                String(pitch.actualBallsOffPlate),
                String(pitch.isStrike),
                String(pitch.isHBP),
                String(pitch.didSwing),
                String(pitch.madeContact),
                String(pitch.isHit),
                String(pitch.isOut),
                String(pitch.isError)
            ]
            rows.append(row.joined(separator: ","))
        }

        return rows.joined(separator: "\n")
    }
}
