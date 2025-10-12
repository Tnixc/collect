import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var isSelectingDirectory = false
    @State private var selectedURL: URL?
    let onDirectorySelected: () -> Void
    
    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Welcome Header
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 64))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text("Welcome to Collect")
                        .font(Typography.largeTitle)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("Organize your PDF library with ease")
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)
                
                // Features
                VStack(spacing: 20) {
                    FeatureRow(
                        icon: "folder.fill",
                        title: "Choose Your Library",
                        description: "Select a folder containing your PDF files"
                    )
                    
                    FeatureRow(
                        icon: "tag.fill",
                        title: "Tag & Categorize",
                        description: "Add metadata, authors, and custom tags to your documents"
                    )
                    
                    FeatureRow(
                        icon: "magnifyingglass",
                        title: "Quick Search & Filter",
                        description: "Find documents by title, author, or category instantly"
                    )
                    
                    FeatureRow(
                        icon: "eye.fill",
                        title: "Preview & Open",
                        description: "Quick Look previews and seamless opening in your preferred app"
                    )
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Setup Button
                VStack(spacing: 16) {
                    UIButton(
                        action: selectDirectory,
                        style: .primary,
                        label: "Choose PDF Directory",
                        icon: "folder.badge.plus"
                    )
                    .frame(width: 200)
                    
                    Text("You'll be able to change this later in Settings")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textTertiary)
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $isSelectingDirectory) {
            DirectorySelectionSheet(selectedURL: $selectedURL) { url in
                saveSourceDirectory(url)
                onDirectorySelected()
            }
        }
    }
    
    private func selectDirectory() {
        isSelectingDirectory = true
    }

    private func saveSourceDirectory(_ url: URL) {
        do {
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(bookmarkData, forKey: "sourceDirectoryBookmark")
        } catch {
            print("Error saving bookmark: \(error)")
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppTheme.textPrimary)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct DirectorySelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedURL: URL?
    let onComplete: (URL) -> Void
    
    @State private var isSelecting = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select PDF Directory")
                .font(.title)
                .padding(.top)
            
            Text("Choose a folder that contains your PDF files. Collect will scan this folder and all its subfolders for PDF documents.")
                .font(.body)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let url = selectedURL {
                VStack(spacing: 8) {
                    Text("Selected:")
                        .font(.headline)
                    Text(url.path)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .padding(8)
                        .background(AppTheme.backgroundSecondary.opacity(0.5))
                        .cornerRadius(6)
                }
                .padding(.horizontal)
            }
            
            HStack {
                UIButton(action: { dismiss() }, label: "Cancel")
                
                UIButton(
                    action: {
                        if let url = selectedURL {
                            onComplete(url)
                            dismiss()
                        } else {
                            selectDirectory()
                        }
                    },
                    style: .primary,
                    label: selectedURL != nil ? "Continue" : "Choose Directory"
                )
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(width: 450, height: 300)
        .onAppear {
            if selectedURL == nil {
                selectDirectory()
            }
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
            selectedURL = url
        }
    }
}