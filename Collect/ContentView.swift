import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    @State private var isSidebarVisible: Bool = true
    
    var body: some View {
        HStack(spacing: 0) {
            // Custom Sidebar (fixed width, not user-resizable)
            SidebarView()
                .environmentObject(appState)
                .frame(width: isSidebarVisible ? 240 : 0)
                .clipped()
            
            // Main Detail View
            DetailView()
                .environmentObject(appState)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text("/")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textTertiary)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(red: 0.4, green: 0.6, blue: 0.9))
                            .frame(width: 8, height: 8)
                        Text("Computer Science")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: {}) {
                    Label("Add items", systemImage: "plus")
                        .labelStyle(.iconOnly)
                }
                .help("Add items")
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: {}) {
                    Label("Search", systemImage: "magnifyingglass")
                        .labelStyle(.iconOnly)
                }
                .help("Search")
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
            // loadData() // Temporarily disabled for sandboxing
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
        
        // TODO: Get source directory from settings
        if let sourceURL = getSourceDirectory() {
            let pdfURLs = FileSystemService.shared.scanDirectory(at: sourceURL)
            var files: [FileItem] = []
            for url in pdfURLs {
                let id = FileSystemService.shared.ensureFileID(for: url)
                let file = FileItem(id: id, fileURL: url)
                files.append(file)
            }
            appState.setFiles(files)
        }
    }
    
    private func getSourceDirectory() -> URL? {
        // Placeholder: Replace with actual source directory selection
        return URL(fileURLWithPath: "/Users/tnixc/Developer/testpdfs")
    }
}
