import Foundation
import SwiftUI
import Combine

class Session: ObservableObject {
    @Published private(set) var pitches: [Pitch] = []
    @Published var pitcherName: String = ""
    @Published var opponentName: String = "Practice"
    @Published var overallPitchNum = 0
    @Published var batterNum = 0
    
    @Published private(set) var inning: String = "1.0"
    private var inningNumber: Int = 1
    private var outs: Int = 0
    
    private var inningPendingUpdate: Bool = false
    private var outPendingUpdate: Bool = false

    private var pitcherStats: [String: (pitchCount: Int, batterCount: Int)] = [:]
    var currentPitcherStats: (pitchCount: Int, batterCount: Int) {
        pitcherStats[pitcherName] ?? (0, 0)
    }

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
        let pitchCountAtTimeOfPitch = currentPitchCountString()
        updatePitchCount(from: resultType)

        let isStrikeout = currentStrikes >= 3 && resultType.outcome.isStrike
        let isRecordedOut = resultType.outcome.isOut || isStrikeout

        let newBatter = shouldResetCount(from: resultType)

        if isRecordedOut {
            outPendingUpdate = true
        }

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
            pitchCount: pitchCountAtTimeOfPitch,
            inning: inning,
            calledPitchZone: calledPitchZone,
            pitchType: pitchType,
            calledBallsOffPlate: calledBallsOffPlate,
            actualPitchZone: actualPitchZone,
            actualBallsOffPlate: actualBallsOffPlate,
            isStrike: resultType.outcome.isStrike,
            isHBP: resultType.outcome.isHBP,
            didSwing: resultType.outcome.didSwing,
            madeContact: resultType.outcome.madeContact,
            isHit: resultType.outcome.isHit,
            isOut: isRecordedOut,
            isError: resultType.outcome.isError
        )

        pitches.append(pitch)

        if outPendingUpdate {
            advanceOuts()
            outPendingUpdate = false
        }

        if inningPendingUpdate {
            advanceInning()
            inningPendingUpdate = false
        }
    }


    private func advanceOuts() {
        outs += 1
        if outs >= 3 {
            inningPendingUpdate = true
            advanceInning()
            outs = 0
        }
        updateInningString()
    }
    
    func addManualOut() {
        advanceOuts()
    }

    private func advanceInning() {
        inningNumber += 1
        updateInningString()
    }

    private func updateInningString() {
        inning = "\(inningNumber).\(outs)"
    }

    func reset() {
        pitches.removeAll()
        overallPitchNum = 0
        batterNum = 0
        pitcherStats.removeAll()
        inningNumber = 1
        outs = 0
        inning = "1.0"
        
        currentBalls = 0
        currentStrikes = 0
    }

    func startSession(pitcher: String, opponent: String?) {
        self.pitcherName = pitcher
        self.opponentName = opponent?.isEmpty == false ? opponent! : "Practice"
        reset()
    }
    
    func changePitcher(to newPitcher: String) {
        self.pitcherName = newPitcher
        pitcherStats[newPitcher] = (pitchCount: 0, batterCount: 0)
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
            if currentStrikes < 3 { currentStrikes += 1 }
        case .swingFoul:
            if currentStrikes < 2 { currentStrikes += 1 }
        case .noSwingBall:
            currentBalls += 1
        default: break
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

    func exportCSV(from viewController: UIViewController, opponentName: String? = nil) {
        let nameToUse = opponentName ?? self.opponentName
        let csv = generateCSV()
        shareCSVFile(from: viewController, csvString: csv, opponentName: nameToUse)
    }

    private func generateCSV() -> String {
        var rows: [String] = []
        
        let header = [
            "pitchNum", "pitcher", "pitcherPitchNum", "batterNum", "pitcherBatterNum",
            "inning", "pitchCount", "calledPitchZone", "pitchType", "calledBallsOffPlate",
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
                pitch.inning,
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
