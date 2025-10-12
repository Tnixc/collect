import SwiftUI

extension ContentView {
    private func colorFromName(_ name: String) -> Color {
        switch name {
        case "blue": return Color.blue
        case "green": return Color.green
        case "orange": return Color.orange
        case "pink": return Color.pink
        case "purple": return Color.purple
        case "yellow": return Color.yellow
        case "gray": return Color.gray
        case "tan": return Color(red: 0.93, green: 0.88, blue: 0.82)
        default: return Color.blue
        }
    }
}

struct ContentView: View {
    @StateObject private var appState = AppState()
    @State private var isSidebarVisible: Bool = true
    @State private var showingSettings = false
    @State private var showingAddURL = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Custom Sidebar (fixed width, not user-resizable)
            SidebarView(showingSettings: $showingSettings)
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
        }
        .animation(.easeInOut(duration: 0.25), value: isSidebarVisible)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    toggleSidebar()
                }) {
                    Label("Toggle Sidebar", systemImage: "sidebar.left")
                        .labelStyle(.iconOnly)
                        .foregroundStyle(AppTheme.textSecondary)
                }
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
                    
                    if let category = appState.categories.first(where: { $0.name == appState.selectedCategory }) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(colorFromName(category.color))
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
                Button(action: { showingAddURL = true }) {
                    Label("Add items", systemImage: "plus")
                        .labelStyle(.iconOnly)
                }
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
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(6)
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: {}) {
                    Label("More options", systemImage: "ellipsis.circle")
                        .labelStyle(.iconOnly)
                }
                .help("More options")
            }
        }
        .toolbarBackground(AppTheme.backgroundSecondary, for: .windowToolbar)
        .toolbarBackgroundVisibility(.visible, for: .windowToolbar)
        .frame(minWidth: 900, minHeight: 600)
        .onAppear {
            // Set the background color for the window
            DispatchQueue.main.async {
                if let window = NSApp.windows.first {
                    window.backgroundColor = NSColor(AppTheme.backgroundSecondary)
                    window.titlebarSeparatorStyle = .none
                    window.toolbar?.showsBaselineSeparator = false
                }
            }
            loadData()
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

        // Get source directory from settings
        if let sourceURL = SettingsSheet.getSourceDirectoryURL() {
            let pdfURLs = FileSystemService.shared.scanDirectory(at: sourceURL)
            var files: [FileItem] = []
            for url in pdfURLs {
                let id = FileSystemService.shared.ensureFileID(for: url)
                let file = FileItem(id: id, fileURL: url)
                files.append(file)
            }
            appState.setFiles(files)

            // Create default metadata for files without existing metadata
            for file in files {
                if appState.metadata[file.id] == nil {
                    let pages = FileSystemService.shared.getPageCount(for: file.fileURL)
                    let defaultMetadata = MetadataService.shared.createMetadata(fileID: file.id, title: file.filename, pages: pages)
                    appState.updateMetadata(for: file.id, metadata: defaultMetadata)
                }
            }

            // Note: Keep security scope accessed while app is running
            // Will stop when app terminates
        }
    }
}
