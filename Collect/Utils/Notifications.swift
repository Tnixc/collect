import Foundation

// Shared notification container and keys used throughout the app.
public enum Notifications {
    public enum Keys {
        // userInfo keys for the source directory change notification
        public static let oldSourceURL = "oldSourceURL" // URL?
        public static let newSourceURL = "newSourceURL" // URL
    }
}

public extension Notification.Name {
    /// Posted when the user selects a different source directory in Settings.
    /// - userInfo:
    ///   - Notifications.Keys.oldSourceURL: URL? (previously selected directory, if any)
    ///   - Notifications.Keys.newSourceURL: URL (newly selected directory)
    static let sourceDirectoryDidChange = Notification.Name("collect.sourceDirectoryDidChange")
}
