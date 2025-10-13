import AppKit
import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isSidebarVisible: Bool = true
    @State private var showingSettings = false
    @State private var showingAddURL = false
    @State private var showingCreateCategory = false
    @State private var needsOnboarding: Bool = true
    @State private var currentSourceDirectoryURL: URL?

    var body: some View {
        Group {
            if needsOnboarding {
                // Show onboarding if no source directory is selected
                OnboardingView(onDirectorySelected: {
                    self.needsOnboarding = false
                    self.loadData()
                })
                .environmentObject(appState)
            } else {
                // Show main app interface
                HStack(spacing: 0) {
                    // Custom Sidebar (fixed width, not user-resizable)
                    SidebarView(
                        showingSettings: $showingSettings,
                        showingCreateCategory: $showingCreateCategory
                    )
                    .environmentObject(appState)
                    .frame(width: isSidebarVisible ? 240 : 0)
                    .clipped()

                    // Main Detail View
                    DetailView()
                        .environmentObject(appState)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsSheet()
                }
                .sheet(isPresented: $showingAddURL) {
                    AddURLSheet()
                        .environmentObject(appState)
                }
                .sheet(isPresented: $showingCreateCategory) {
                    CreateCategorySheet { name, color in
                        appState.tagColors[name] = color
                        MetadataService.shared.tagColors = appState.tagColors
                        MetadataService.shared.save(metadata: appState.metadata)
                        appState.updateCategories()
                    }
                    .environmentObject(appState)
                }
                .animation(.snappy(), value: isSidebarVisible)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        UIButton(
                            action: {
                                toggleSidebar()
                            },
                            style: .ghost,
                            icon: "sidebar.left",
                            width: 32
                        )
                        .help("Toggle Sidebar")
                    }

                    ToolbarItem(placement: .navigation) {
                        // Breadcrumb
                        HStack(spacing: 6) {
                            Text("My Library")
                                .font(.system(size: 13))
                                .foregroundStyle(AppTheme.textSecondary)

                            Text("/")
                                .font(.system(size: 13))
                                .foregroundStyle(AppTheme.textTertiary)

                            if let category = appState.categories.first(where: {
                                $0.name == appState.selectedCategory
                            }) {
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(
                                            AppTheme.categoryColor(
                                                for: category.color
                                            )
                                        )
                                        .frame(width: 8, height: 8)
                                    Text(category.name)
                                        .font(.system(size: 13))
                                        .foregroundStyle(AppTheme.textPrimary)
                                }
                            } else {
                                Text("All Items")
                                    .font(.system(size: 13))
                                    .foregroundStyle(AppTheme.textPrimary)
                            }
                        }
                    }

                    ToolbarItem(placement: .automatic) {
                        Spacer()
                    }
                    ToolbarItem(placement: .automatic) {
                        UIButton(
                            action: { showingAddURL = true },
                            style: .plain,
                            label: "Add Item",
                            icon: "plus"
                        )
                        .help("Add items")
                    }
                }
                .toolbarBackground(AppTheme.backgroundSecondary, for: .windowToolbar)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .onAppear {
            // Set the background color for the window
            updateWindowBackground()
            loadData()
            NSApp.keyWindow?.tabbingMode = .disallowed

            // Add observer for app activation to refresh data
            NotificationCenter.default.addObserver(
                forName: NSApplication.didBecomeActiveNotification,
                object: nil,
                queue: .main
            ) { _ in
                refreshDataIfNeeded()
            }

            // Observe source directory changes to refresh immediately
            NotificationCenter.default.addObserver(
                forName: .sourceDirectoryDidChange,
                object: nil,
                queue: .main
            ) { note in
                handleSourceDirectoryChanged(note)
            }
        }
        .onChange(of: themeManager.effectiveColorScheme) {
            updateWindowBackground()
        }
        .onChange(of: showingSettings) { isPresented in
            // When Settings is dismissed, reload if the source changed
            if !isPresented {
                handleSettingsDismissed()
            }
        }
        .onDisappear {
            // Remove observers when view disappears
            NotificationCenter.default.removeObserver(
                self,
                name: NSApplication.didBecomeActiveNotification,
                object: nil
            )
            NotificationCenter.default.removeObserver(
                self,
                name: .sourceDirectoryDidChange,
                object: nil
            )
        }
    }

    private func toggleSidebar() {
        withAnimation(.snappy()) {
            isSidebarVisible.toggle()
        }
    }

    private func handleSettingsDismissed() {
        let newURL = SettingsSheet.getSourceDirectoryURL()
        let changed: Bool = {
            switch (currentSourceDirectoryURL, newURL) {
            case (nil, nil):
                return false
            case let (a?, b?):
                return a.standardizedFileURL != b.standardizedFileURL
            default:
                return true
            }
        }()
        if changed {
            if let old = currentSourceDirectoryURL {
                SettingsSheet.stopAccessingSourceDirectory(old)
            }
            currentSourceDirectoryURL = newURL
            // Clear current in-memory state and reload per-source metadata/files
            appState.files = []
            appState.metadata = MetadataService.shared.load()
            appState.tagColors = MetadataService.shared.tagColors
            appState.selectedCategory = nil
            appState.selectedAuthors = []
            appState.searchText = ""
            if let src = newURL {
                needsOnboarding = false
                loadFilesFromDirectory(src)
            } else {
                needsOnboarding = true
            }
        }
    }

    private func handleSourceDirectoryChanged(_ notification: Notification) {
        let newURL = (notification.userInfo?[Notifications.Keys.newSourceURL] as? URL)
        let changed: Bool = {
            switch (currentSourceDirectoryURL, newURL) {
            case (nil, nil):
                return false
            case let (a?, b?):
                return a.standardizedFileURL != b.standardizedFileURL
            default:
                return true
            }
        }()
        if changed {
            if let old = currentSourceDirectoryURL {
                SettingsSheet.stopAccessingSourceDirectory(old)
            }
            currentSourceDirectoryURL = newURL
            // Clear current in-memory state and reload per-source metadata/files
            appState.files = []
            appState.metadata = MetadataService.shared.load()
            appState.tagColors = MetadataService.shared.tagColors
            appState.selectedCategory = nil
            appState.selectedAuthors = []
            appState.searchText = ""
            if let src = newURL {
                needsOnboarding = false
                loadFilesFromDirectory(src)
            } else {
                needsOnboarding = true
            }
        }
    }

    private func loadData() {
        // Load metadata
        appState.metadata = MetadataService.shared.load()
        appState.tagColors = MetadataService.shared.tagColors

        // Check if we have a source directory
        let sourceURL = SettingsSheet.getSourceDirectoryURL()
        needsOnboarding = sourceURL == nil
        currentSourceDirectoryURL = sourceURL

        // Get source directory from settings
        if let src = sourceURL {
            loadFilesFromDirectory(src)
        }
    }

    private func loadFilesFromDirectory(_ sourceURL: URL) {
        // Start accessing the security-scoped resource
        guard sourceURL.startAccessingSecurityScopedResource() else {
            print("Failed to access security-scoped resource")
            return
        }

        let pdfURLs = FileSystemService.shared.scanDirectory(at: sourceURL)
        var files: [FileItem] = []

        for url in pdfURLs {
            let id = FileSystemService.shared.ensureFileID(for: url)
            let file = FileItem(id: id, fileURL: url)
            files.append(file)

            // Create default metadata for files without existing metadata
            if appState.metadata[file.id] == nil {
                let pages = FileSystemService.shared.getPageCount(
                    for: file.fileURL
                )
                let defaultMetadata = MetadataService.shared.createMetadata(
                    fileID: file.id,
                    title: file.filename,
                    pages: pages
                )
                appState.updateMetadata(for: file.id, metadata: defaultMetadata)
            }
        }

        appState.setFiles(files)

        // Note: Keep security scope accessed while app is running
        // Will stop when app terminates
    }

    private func refreshDataIfNeeded() {
        // Refresh data when app becomes active (e.g., when returning from another app)
        if let sourceURL = SettingsSheet.getSourceDirectoryURL() {
            loadFilesFromDirectory(sourceURL)
        }
    }

    private func updateWindowBackground() {
        DispatchQueue.main.async {
            if let window = NSApp.windows.first {
                window.backgroundColor = NSColor(
                    AppTheme.backgroundSecondary
                )
                window.titlebarSeparatorStyle = .none
            }
        }
    }
}
