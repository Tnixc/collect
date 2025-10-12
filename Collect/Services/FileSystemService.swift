import Foundation
import PDFKit

class FileSystemService {
    static let shared = FileSystemService()

    private init() {}

    // Scan directory recursively for PDF files
    func scanDirectory(at url: URL) -> [URL] {
        let fileManager = FileManager.default
        var pdfURLs: [URL] = []

        guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]) else {
            return []
        }

        for case let fileURL as URL in enumerator {
            if fileURL.pathExtension.lowercased() == "pdf" {
                pdfURLs.append(fileURL)
            }
        }

        return pdfURLs
    }

    // Read extended attribute for file ID
    func getFileID(for url: URL) -> UUID? {
        let data = url.withUnsafeFileSystemRepresentation { path -> Data? in
            let length = getxattr(path, "com.collect.fileid", nil, 0, 0, 0)
            guard length > 0 else { return nil }
            var buffer = [UInt8](repeating: 0, count: length)
            getxattr(path, "com.collect.fileid", &buffer, length, 0, 0)
            return Data(buffer)
        }

        guard let data = data, let idString = String(data: data, encoding: .utf8) else {
            return nil
        }

        return UUID(uuidString: idString)
    }

    // Write extended attribute for file ID
    func setFileID(for url: URL, id: UUID) {
        let idString = id.uuidString
        _ = url.withUnsafeFileSystemRepresentation { path in
            if let path = path {
                setxattr(path, "com.collect.fileid", idString, idString.utf8.count, 0, 0)
            }
        }
    }

    // Ensure file has an ID, read or create
    func ensureFileID(for url: URL) -> UUID {
        if let existingID = getFileID(for: url) {
            return existingID
        } else {
            let newID = UUID()
            setFileID(for: url, id: newID)
            return newID
        }
    }

    // Get PDF page count
    func getPageCount(for url: URL) -> Int? {
        guard let pdf = PDFDocument(url: url) else { return nil }
        return pdf.pageCount
    }

    // Copy file to destination directory
    func copyFile(from sourceURL: URL, to destinationDirectory: URL) throws -> URL {
        let filename = sourceURL.lastPathComponent
        let destinationURL = destinationDirectory.appendingPathComponent(filename)

        // If file already exists, make a unique name
        var finalDestinationURL = destinationURL
        var counter = 1
        while FileManager.default.fileExists(atPath: finalDestinationURL.path) {
            let nameWithoutExtension = (filename as NSString).deletingPathExtension
            let `extension` = (filename as NSString).pathExtension
            let newName = "\(nameWithoutExtension) (\(counter)).\(`extension`)"
            finalDestinationURL = destinationDirectory.appendingPathComponent(newName)
            counter += 1
        }

        try FileManager.default.copyItem(at: sourceURL, to: finalDestinationURL)
        return finalDestinationURL
    }
}
