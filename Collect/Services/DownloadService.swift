import Foundation

class DownloadService {
    static let shared = DownloadService()

    private init() {}

    func downloadFile(from url: URL, to destinationDirectory: URL) async throws -> URL {
        // Check if curl is available
        guard isCurlAvailable() else {
            throw DownloadError.curlNotFound
        }

        // Create destination URL in the directory
        let filename = url.lastPathComponent
        let destinationURL = destinationDirectory.appendingPathComponent(filename)

        // Run curl
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/curl")
        process.arguments = ["-L", "-o", destinationURL.path, url.absoluteString]

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus == 0 {
            // Validate that the downloaded file is a PDF
            guard destinationURL.pathExtension.lowercased() == "pdf" else {
                // Try to delete the non-PDF file
                try? FileManager.default.removeItem(at: destinationURL)
                throw DownloadError.notAPDF
            }
            return destinationURL
        } else {
            throw DownloadError.downloadFailed
        }
    }

    private func isCurlAvailable() -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = ["curl"]

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
        case curlNotFound
        case downloadFailed
        case notAPDF
    }
}
