import Foundation

class DownloadService {
    static let shared = DownloadService()

    private init() {}

    func downloadFile(from url: URL, to destinationDirectory: URL) async throws -> URL {
        // Convert arXiv abstract URLs to PDF URLs
        let downloadURL = convertArXivURL(url)
        // Check if curl is available
        guard isCurlAvailable() else {
            throw DownloadError.curlNotFound
        }

        // Create destination URL in the directory
        let filename = downloadURL.lastPathComponent
        let destinationURL = destinationDirectory.appendingPathComponent(filename)

        // Run curl
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/curl")
        process.arguments = ["-L", "-o", destinationURL.path, downloadURL.absoluteString]

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

    private func convertArXivURL(_ url: URL) -> URL {
        let urlString = url.absoluteString

        // Check if it's an arXiv abstract URL (https://arxiv.org/abs/XXXX.XXXXX)
        if urlString.contains("arxiv.org/abs/") {
            // Extract the article ID
            let articleID = url.lastPathComponent
            // Convert to PDF URL
            let pdfURLString = "https://arxiv.org/pdf/\(articleID).pdf"
            return URL(string: pdfURLString) ?? url
        }

        // Return original URL if not an arXiv abstract URL
        return url
    }

    enum DownloadError: Error {
        case curlNotFound
        case downloadFailed
        case notAPDF
    }
}
