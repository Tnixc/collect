import Foundation

class DownloadService {
    static let shared = DownloadService()

    private init() {}

    func downloadFile(from url: URL, to destinationDirectory: URL) async throws -> URL {
        // Check if wget is available
        guard isWgetAvailable() else {
            throw DownloadError.wgetNotFound
        }

        // Create destination URL in the directory
        let filename = url.lastPathComponent
        let destinationURL = destinationDirectory.appendingPathComponent(filename)

        // Run wget
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/local/bin/wget") // Assuming installed via homebrew
        process.arguments = ["-P", destinationDirectory.path, url.absoluteString]

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus == 0 {
            return destinationURL
        } else {
            throw DownloadError.downloadFailed
        }
    }

    private func isWgetAvailable() -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = ["wget"]

        let pipe = Pipe()
        process.standardOutput = pipe

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }

    enum DownloadError: Error {
        case wgetNotFound
        case downloadFailed
    }
}
