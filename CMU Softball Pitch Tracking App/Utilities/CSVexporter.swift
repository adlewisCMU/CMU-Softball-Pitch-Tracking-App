import UIKit

func generateTimestampedCSVFileName(opponentName: String?, prefix: String = "pitch_data") -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd_HH-mm"
    let timestamp = formatter.string(from: Date())

    let sanitizedOpponent = (opponentName ?? "opponent")
        .replacingOccurrences(of: " ", with: "-")
        .lowercased()

    return "\(prefix)_vs_\(sanitizedOpponent)_\(timestamp).csv"
}

func saveCSVToTempFile(csvString: String, fileName: String? = nil, opponentName: String? = nil) -> URL? {
    let name: String = fileName ?? generateTimestampedCSVFileName(opponentName: opponentName)
    let tempDir = FileManager.default.temporaryDirectory
    let fileURL = tempDir.appendingPathComponent(name)

    do {
        try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    } catch {
        print("Error writing CSV: \(error)")
        return nil
    }
}

func shareCSVFile(from viewController: UIViewController, csvString: String, opponentName: String?) {
    guard let fileURL = saveCSVToTempFile(csvString: csvString, opponentName: opponentName) else {
        print("Could not save CSV to temp file.")
        return
    }

    let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)

    if let popover = activityVC.popoverPresentationController {
        popover.sourceView = viewController.view
        popover.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                    y: viewController.view.bounds.midY,
                                    width: 0, height: 0)
        popover.permittedArrowDirections = []
    }

    viewController.present(activityVC, animated: true)
}
