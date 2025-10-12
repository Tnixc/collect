import SwiftUI
import AppKit

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var sourceDirectoryURL: URL?
    @State private var isSelectingDirectory = false
    
    private let sourceDirectoryBookmarkKey = "sourceDirectoryBookmark"
    
    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.title)
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Source Directory")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    HStack {
                        Text(sourceDirectoryURL?.path ?? "No directory selected")
                            .foregroundColor(sourceDirectoryURL != nil ? AppTheme.textPrimary : AppTheme.textSecondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        
                        Spacer()
                        
                        Button("Choose...") {
                            selectDirectory()
                        }
                        .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(8)
                    .background(AppTheme.backgroundSecondary.opacity(0.5))
                    .cornerRadius(6)
                }
                .padding(.horizontal)
                
                Spacer()
                
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .keyboardShortcut(.cancelAction)
                    .foregroundColor(AppTheme.textSecondary)
                    
                    Spacer()
                    
                    Button("Save") {
                        saveSettings()
                        dismiss()
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(sourceDirectoryURL == nil)
                    .foregroundColor(AppTheme.textPrimary)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .frame(width: 400, height: 200)
        .onAppear {
            loadSettings()
        }
    }
    
    private func selectDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.message = "Choose the directory containing your PDF files"
        panel.prompt = "Select"
        
        if panel.runModal() == .OK, let url = panel.url {
            sourceDirectoryURL = url
        }
    }
    
    private func loadSettings() {
        if let bookmarkData = UserDefaults.standard.data(forKey: sourceDirectoryBookmarkKey) {
            do {
                var isStale = false
                let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                if !isStale {
                    sourceDirectoryURL = url
                }
            } catch {
                print("Error resolving bookmark: \(error)")
            }
        }
    }
    
    private func saveSettings() {
        guard let url = sourceDirectoryURL else { return }
        
        do {
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(bookmarkData, forKey: sourceDirectoryBookmarkKey)
        } catch {
            print("Error creating bookmark: \(error)")
        }
    }
    
    // Method to get the source directory URL with security scope
    static func getSourceDirectoryURL() -> URL? {
        if let bookmarkData = UserDefaults.standard.data(forKey: "sourceDirectoryBookmark") {
            do {
                var isStale = false
                let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                if !isStale {
                    // Start accessing the security-scoped resource
                    if url.startAccessingSecurityScopedResource() {
                        return url
                    }
                }
            } catch {
                print("Error resolving bookmark: \(error)")
            }
        }
        return nil
    }
    
    // Method to stop accessing security scope when done
    static func stopAccessingSourceDirectory(_ url: URL) {
        url.stopAccessingSecurityScopedResource()
    }
}