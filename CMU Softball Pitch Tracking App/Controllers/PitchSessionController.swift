class PitchSessionController: ObservableObject {
    @Published var pitches: [Pitch] = []
    
    private var totalPitchNum = 0
    private var batterNum = 0
    private var pitcherPitchCounts: [String: Int] = [:]
    private var pitcherBatterCounts: [String: Int] = [:]
    
    func addPitch(pitch: Pitch) {
        pitches.append(pitch)
        totalPitchNum += 1
        // Logic for updating counts can go here
    }

    func startNewSession() {
        pitches.removeAll()
        totalPitchNum = 0
        batterNum = 0
        pitcherPitchCounts.removeAll()
        pitcherBatterCounts.removeAll()
    }

    func exportToCSV() -> String {
        var csvString = "pitch_num,pitcher,pitcher_pitch_num,batter_num,pitcher_batter_num,pitch_count,called_pitch_zone,pitch_type,called_balls_off_plate,actual_pitch_zone,actual_balls_off_plate,strike?,hbp?,swing?,contact?,hit?,out?,error?\n"
        
        for pitch in pitches {
            let row = "\(pitch.pitchNum),\(pitch.pitcher),\(pitch.pitcherPitchNum),\(pitch.batterNum),\(pitch.pitcherBatterNum),\(pitch.pitchCount),\(pitch.calledPitchZone),\(pitch.pitchType),\(pitch.calledBallsOffPlate),\(pitch.actualPitchZone),\(pitch.actualBallsOffPlate),\(pitch.isStrike),\(pitch.isHBP),\(pitch.didSwing),\(pitch.didContact),\(pitch.isHit),\(pitch.isOut),\(pitch.isError)"
            csvString.append("\(row)\n")
        }
        
        return csvString
    }
}
