import Foundation
import SwiftUI
import Combine

class Session: ObservableObject {
    @Published private(set) var pitches: [Pitch] = []
    @Published var pitcherName: String = ""
    @Published var opponentName: String = "Practice"
    private var overallPitchNum = 0
    private var batterNum = 0
    private var pitcherStats: [String: (pitchCount: Int, batterCount: Int)] = [:]

    func addPitch(
        pitcher: String,
        pitchCount: String,
        calledPitchZone: Int,
        pitchType: String,
        calledBallsOffPlate: Int,
        actualPitchZone: String,
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

    func startSession(pitcher: String, opponent: String?) {
        self.pitcherName = pitcher
        self.opponentName = opponent?.isEmpty == false ? opponent! : "Practice"
        reset()
    }

    func exportCSV(from viewController: UIViewController, opponentName: String? = nil) {
        let csv = generateCSV()
        shareCSVFile(from: viewController, csvString: csv, opponentName: opponentName)
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
