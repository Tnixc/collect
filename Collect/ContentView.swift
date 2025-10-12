import AppKit
import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    @State private var isSidebarVisible: Bool = true
    @State private var showingSettings = false
    @State private var showingAddURL = false
    @State private var showingCreateCategory = false
    @State private var needsOnboarding: Bool = true

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
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: isSidebarVisible)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        UIButton(
                            action: {
                                toggleSidebar()
                            },
                            style: .ghost,
                            icon: "sidebar.left"
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
                                        .fill(AppTheme.categoryColor(for: category.color))
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

                    ToolbarItem(placement: .automatic) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(AppTheme.textSecondary)
                            TextField("Search", text: $appState.searchText)
                                .textFieldStyle(.plain)
                                .frame(width: 200)
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(.vertical, 4)
                                .smartFocusRing()
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.backgroundTertiary)
                        .cornerRadius(6)
                    }
                }
                .toolbarBackground(Color.clear, for: .windowToolbar)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .onAppear {
            // Set the background color for the window
            DispatchQueue.main.async {
                if let window = NSApp.windows.first {
                    window.backgroundColor = NSColor(
                        AppTheme.backgroundSecondary
                    )
                    window.titlebarSeparatorStyle = .none
                }
            }
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
        }
        .onDisappear {
            // Remove observer when view disappears
            NotificationCenter.default.removeObserver(
                self,
                name: NSApplication.didBecomeActiveNotification,
                object: nil
            )
        }
    }

    private func toggleSidebar() {
        withAnimation(.easeInOut(duration: 0.25)) {
            isSidebarVisible.toggle()
        }
    }

    private func loadData() {
        // Load metadata
        appState.metadata = MetadataService.shared.load()
        appState.tagColors = MetadataService.shared.tagColors

        // Check if we have a source directory
        needsOnboarding = SettingsSheet.getSourceDirectoryURL() == nil

        // Get source directory from settings
        if let sourceURL = SettingsSheet.getSourceDirectoryURL() {
            loadFilesFromDirectory(sourceURL)
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
                let pages = FileSystemService.shared.getPageCount(for: file.fileURL)
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
}
