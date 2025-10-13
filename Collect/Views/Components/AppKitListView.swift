import AppKit
import CoreText
import SwiftUI

/*
 AppKitListView - Two-line list layout for PDF items

 Visual Layout:
 ┌────────────────────────────────────────────────────────────────────────────┐
 │  [📄]  Document Title Here...                      [Tag1] [Tag2] [+2]      │
 │  [👤]  Author Name(s)                              1.2 MB • Opened 2h ago  │
 ├────────────────────────────────────────────────────────────────────────────┤
 │  [📄]  Another Document                            [Research] [Work]       │
 │  [👤]  John Doe, Jane Smith                        856 KB • Opened 1d ago  │
 └────────────────────────────────────────────────────────────────────────────┘

 Row height: 72px (8px spacing between rows)
 Layout structure:
 - Line 1: Icon (40x40) | Title (14pt medium) | Category pills (right-aligned)
 - Line 2: Person icon (12x12) | Author(s) (12pt) | Metadata (11pt, right-aligned)

 Features:
 - Click to open PDF
 - Right-click for context menu (same as grid view)
 - Background colored based on file metadata
 - All actions supported: edit, categorize, reading list, delete, etc.
 */

struct AppKitListView: NSViewRepresentable {
    let files: [FileItem]
    let metadata: [UUID: FileMetadata]
    let categories: [Collect.Category]
    let onTap: (UUID) -> Void
    let editAction: (UUID) -> Void
    let addToCategoryAction: (UUID, String) -> Void
    let createCategoryAction: (UUID) -> Void
    let deleteAction: (UUID) -> Void
    let showInFinderAction: (UUID) -> Void
    let addToReadingListAction: (UUID) -> Void
    let removeFromReadingListAction: (UUID) -> Void

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.backgroundColor = .clear
        scrollView.drawsBackground = false

        let tableView = NSTableView()
        tableView.style = .plain
        tableView.backgroundColor = .clear
        tableView.rowSizeStyle = .custom
        tableView.rowHeight = 64
        tableView.intercellSpacing = NSSize(width: 0, height: 8)
        tableView.headerView = nil
        tableView.usesAlternatingRowBackgroundColors = false
        tableView.selectionHighlightStyle = .none
        tableView.allowsEmptySelection = true
        tableView.allowsMultipleSelection = false

        // Add single column
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("FileColumn"))
        column.resizingMask = .autoresizingMask
        tableView.addTableColumn(column)

        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator

        scrollView.documentView = tableView

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let tableView = nsView.documentView as? NSTableView else { return }

        context.coordinator.files = files
        context.coordinator.metadata = metadata
        context.coordinator.categories = categories

        tableView.reloadData()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            files: files,
            metadata: metadata,
            categories: categories,
            onTap: onTap,
            editAction: editAction,
            addToCategoryAction: addToCategoryAction,
            createCategoryAction: createCategoryAction,
            deleteAction: deleteAction,
            showInFinderAction: showInFinderAction,
            addToReadingListAction: addToReadingListAction,
            removeFromReadingListAction: removeFromReadingListAction
        )
    }

    class Coordinator: NSObject, NSTableViewDataSource, NSTableViewDelegate {
        var files: [FileItem]
        var metadata: [UUID: FileMetadata]
        var categories: [Collect.Category]
        let onTap: (UUID) -> Void
        let editAction: (UUID) -> Void
        let addToCategoryAction: (UUID, String) -> Void
        let createCategoryAction: (UUID) -> Void
        let deleteAction: (UUID) -> Void
        let showInFinderAction: (UUID) -> Void
        let addToReadingListAction: (UUID) -> Void
        let removeFromReadingListAction: (UUID) -> Void

        init(
            files: [FileItem],
            metadata: [UUID: FileMetadata],
            categories: [Collect.Category],
            onTap: @escaping (UUID) -> Void,
            editAction: @escaping (UUID) -> Void,
            addToCategoryAction: @escaping (UUID, String) -> Void,
            createCategoryAction: @escaping (UUID) -> Void,
            deleteAction: @escaping (UUID) -> Void,
            showInFinderAction: @escaping (UUID) -> Void,
            addToReadingListAction: @escaping (UUID) -> Void,
            removeFromReadingListAction: @escaping (UUID) -> Void
        ) {
            self.files = files
            self.metadata = metadata
            self.categories = categories
            self.onTap = onTap
            self.editAction = editAction
            self.addToCategoryAction = addToCategoryAction
            self.createCategoryAction = createCategoryAction
            self.deleteAction = deleteAction
            self.showInFinderAction = showInFinderAction
            self.addToReadingListAction = addToReadingListAction
            self.removeFromReadingListAction = removeFromReadingListAction
        }

        func numberOfRows(in _: NSTableView) -> Int {
            return files.count
        }

        func tableView(_: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
            let file = files[row]
            let meta = metadata[file.id] ?? FileMetadata(id: file.id)

            let cellView = FileListRowView()
            cellView.configure(
                with: file,
                metadata: meta,
                categories: categories,
                onTap: { [weak self] in
                    self?.onTap(file.id)
                },
                editAction: { [weak self] in
                    self?.editAction(file.id)
                },
                addToCategoryAction: { [weak self] categoryName in
                    self?.addToCategoryAction(file.id, categoryName)
                },
                createCategoryAction: { [weak self] in
                    self?.createCategoryAction(file.id)
                },
                deleteAction: { [weak self] in
                    self?.deleteAction(file.id)
                },
                showInFinderAction: { [weak self] in
                    self?.showInFinderAction(file.id)
                },
                addToReadingListAction: { [weak self] in
                    self?.addToReadingListAction(file.id)
                },
                removeFromReadingListAction: { [weak self] in
                    self?.removeFromReadingListAction(file.id)
                }
            )

            return cellView
        }

        func tableView(_: NSTableView, shouldSelectRow _: Int) -> Bool {
            return false
        }
    }
}

class FileListRowView: NSView {
    private let backgroundLayer = CAShapeLayer()
    private let iconImageView = ColorDotIconView()
    private let titleLabel = NSTextField(labelWithString: "")
    private let authorPillContainer = NSStackView()
    private let tagsContainer = NSView()
    private let rightPillsContainer = NSStackView()

    private var file: FileItem?
    private var metadata: FileMetadata?
    private var categories: [Collect.Category] = []
    private var onTapAction: (() -> Void)?
    private var editAction: (() -> Void)?
    private var addToCategoryAction: ((String) -> Void)?
    private var createCategoryAction: (() -> Void)?
    private var deleteAction: (() -> Void)?
    private var showInFinderAction: (() -> Void)?
    private var addToReadingListAction: (() -> Void)?
    private var removeFromReadingListAction: (() -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupViews()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupGestures()
    }

    private func setupViews() {
        wantsLayer = true

        // Background layer
        layer?.addSublayer(backgroundLayer)

        // Icon (PDF thumbnail or generic icon)
        // ColorDotIconView configured in configure()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconImageView)

        // Title label
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        titleLabel.font = NewYork.nsFont(size: 18, weight: .semibold, opticalSize: .medium) ?? NSFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = AppTheme.textPrimaryNSColor
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        // Tags container
        tagsContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tagsContainer)

        // Author pill container
        authorPillContainer.orientation = .horizontal
        authorPillContainer.alignment = .centerY
        authorPillContainer.spacing = 4
        authorPillContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(authorPillContainer)

        // Right metadata pills container
        rightPillsContainer.orientation = .horizontal
        rightPillsContainer.alignment = .centerY
        rightPillsContainer.spacing = 4
        rightPillsContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rightPillsContainer)

        NSLayoutConstraint.activate([
            // Icon constraints
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),

            // Title constraints - Line 1
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),

            // Tags container - Line 1, right side
            tagsContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            tagsContainer.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            tagsContainer.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
            tagsContainer.heightAnchor.constraint(equalToConstant: 22),

            // Author pill container - Line 2
            authorPillContainer.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 4),
            authorPillContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),

            // Metadata pills - Line 2, right side
            rightPillsContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            rightPillsContainer.centerYAnchor.constraint(equalTo: authorPillContainer.centerYAnchor),
            rightPillsContainer.leadingAnchor.constraint(greaterThanOrEqualTo: authorPillContainer.trailingAnchor, constant: 8),
        ])
    }

    private func setupGestures() {
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick))
        clickGesture.numberOfClicksRequired = 2
        addGestureRecognizer(clickGesture)

        let rightClickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleRightClick(_:)))
        rightClickGesture.buttonMask = 0x2 // Right mouse button
        addGestureRecognizer(rightClickGesture)
    }

    @objc private func handleClick() {
        onTapAction?()
    }

    @objc private func handleRightClick(_ sender: NSClickGestureRecognizer) {
        let menu = createMenu()
        let location = sender.location(in: self)
        menu.popUp(positioning: nil, at: location, in: self)
    }

    private func createMenu() -> NSMenu {
        let menu = NSMenu()

        // Open
        let openItem = NSMenuItem(title: "Open", action: #selector(openItem), keyEquivalent: "")
        openItem.target = self
        openItem.image = NSImage(systemSymbolName: "arrow.up.forward.app", accessibilityDescription: nil)
        menu.addItem(openItem)

        // Edit Metadata
        let editItem = NSMenuItem(title: "Edit Metadata", action: #selector(editItem), keyEquivalent: "")
        editItem.target = self
        editItem.image = NSImage(systemSymbolName: "pencil", accessibilityDescription: nil)
        menu.addItem(editItem)

        menu.addItem(NSMenuItem.separator())

        // Reading List
        if let meta = metadata, meta.isInReadingList {
            let removeFromReadingListItem = NSMenuItem(
                title: "Remove from Reading List",
                action: #selector(removeFromReadingList),
                keyEquivalent: ""
            )
            removeFromReadingListItem.target = self
            removeFromReadingListItem.image = NSImage(
                systemSymbolName: "book.closed",
                accessibilityDescription: nil
            )
            menu.addItem(removeFromReadingListItem)
        } else {
            let addToReadingListItem = NSMenuItem(
                title: "Add to Reading List",
                action: #selector(addToReadingList),
                keyEquivalent: ""
            )
            addToReadingListItem.target = self
            addToReadingListItem.image = NSImage(
                systemSymbolName: "book",
                accessibilityDescription: nil
            )
            menu.addItem(addToReadingListItem)
        }

        menu.addItem(NSMenuItem.separator())

        // Add to Category submenu
        let addToCategoryItem = NSMenuItem(title: "Add to Category", action: nil, keyEquivalent: "")
        addToCategoryItem.image = NSImage(systemSymbolName: "tag", accessibilityDescription: nil)
        let categorySubmenu = NSMenu()

        let availableCategories = categories.filter { $0.name != "Uncategorized" }

        if availableCategories.isEmpty {
            let noCategories = NSMenuItem(title: "No categories", action: nil, keyEquivalent: "")
            noCategories.isEnabled = false
            categorySubmenu.addItem(noCategories)
        } else {
            for category in availableCategories {
                let categoryItem = NSMenuItem(
                    title: category.name,
                    action: #selector(addToCategory(_:)),
                    keyEquivalent: ""
                )
                categoryItem.target = self
                categoryItem.representedObject = category.name
                categorySubmenu.addItem(categoryItem)
            }
        }

        categorySubmenu.addItem(NSMenuItem.separator())
        let createCategoryItem = NSMenuItem(
            title: "Create New Category...",
            action: #selector(createCategory),
            keyEquivalent: ""
        )
        createCategoryItem.target = self
        categorySubmenu.addItem(createCategoryItem)

        addToCategoryItem.submenu = categorySubmenu
        menu.addItem(addToCategoryItem)

        menu.addItem(NSMenuItem.separator())

        // Show in Finder
        let showInFinderItem = NSMenuItem(
            title: "Show in Finder",
            action: #selector(showInFinder),
            keyEquivalent: ""
        )
        showInFinderItem.target = self
        showInFinderItem.image = NSImage(systemSymbolName: "folder", accessibilityDescription: nil)
        menu.addItem(showInFinderItem)

        // Delete
        let deleteItem = NSMenuItem(title: "Delete", action: #selector(deleteItem), keyEquivalent: "")
        deleteItem.target = self
        deleteItem.image = NSImage(systemSymbolName: "trash", accessibilityDescription: nil)
        menu.addItem(deleteItem)

        return menu
    }

    @objc private func openItem() {
        onTapAction?()
    }

    @objc private func editItem() {
        editAction?()
    }

    @objc private func deleteItem() {
        deleteAction?()
    }

    @objc private func showInFinder() {
        showInFinderAction?()
    }

    @objc private func addToCategory(_ sender: NSMenuItem) {
        if let categoryName = sender.representedObject as? String {
            addToCategoryAction?(categoryName)
        }
    }

    @objc private func createCategory() {
        createCategoryAction?()
    }

    @objc private func addToReadingList() {
        addToReadingListAction?()
    }

    @objc private func removeFromReadingList() {
        removeFromReadingListAction?()
    }

    func configure(
        with file: FileItem,
        metadata: FileMetadata,
        categories: [Collect.Category],
        onTap: @escaping () -> Void,
        editAction: @escaping () -> Void,
        addToCategoryAction: @escaping (String) -> Void,
        createCategoryAction: @escaping () -> Void,
        deleteAction: @escaping () -> Void,
        showInFinderAction: @escaping () -> Void,
        addToReadingListAction: @escaping () -> Void,
        removeFromReadingListAction: @escaping () -> Void
    ) {
        self.file = file
        self.metadata = metadata
        self.categories = categories
        onTapAction = onTap
        self.editAction = editAction
        self.addToCategoryAction = addToCategoryAction
        self.createCategoryAction = createCategoryAction
        self.deleteAction = deleteAction
        self.showInFinderAction = showInFinderAction
        self.addToReadingListAction = addToReadingListAction
        self.removeFromReadingListAction = removeFromReadingListAction

        // Get background color from metadata
        let backgroundColor: NSColor
        if let colorName = AppTheme.cardColors[metadata.cardColor] {
            backgroundColor = NSColor(colorName).withAlphaComponent(0.5)
        } else {
            backgroundColor = AppTheme.cardNSColors[abs(file.id.hashValue) % AppTheme.cardNSColors.count]
        }
        let saturatedColor = AppTheme.saturatedColor(for: backgroundColor)
        backgroundLayer.fillColor = backgroundColor.cgColor

        // Set icon
        iconImageView.symbolTintColor = saturatedColor
        iconImageView.symbolName = "doc.text.fill"

        // Set title
        if let title = metadata.title, !title.isEmpty {
            titleLabel.stringValue = title
        } else {
            titleLabel.stringValue = file.filename
        }

        // Set author pill with faint background
        authorPillContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let authorText = metadata.authors.isEmpty ? "Unknown Author" : metadata.authors.joined(separator: ", ")
        let authorPill = PillView(text: authorText, backgroundColor: AppTheme.pillBackgroundFaintNSColor)
        authorPill.showsColorDot = false
        authorPillContainer.addArrangedSubview(authorPill)

        // Set metadata pills with faint background (file size, pages, last opened)
        rightPillsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let sizePill = PillView(text: formatFileSize(file.fileSize), backgroundColor: AppTheme.pillBackgroundFaintNSColor)
        sizePill.showsColorDot = false
        rightPillsContainer.addArrangedSubview(sizePill)

        if let pages = metadata.pages {
            let pagesPill = PillView(text: "\(pages) pages", backgroundColor: AppTheme.pillBackgroundFaintNSColor)
            pagesPill.showsColorDot = false
            rightPillsContainer.addArrangedSubview(pagesPill)
        }

        if let lastOpened = metadata.lastOpened {
            let openedPill = PillView(text: "Opened " + formatLastOpened(lastOpened), backgroundColor: AppTheme.pillBackgroundFaintNSColor)
            openedPill.showsColorDot = false
            rightPillsContainer.addArrangedSubview(openedPill)
        }

        // Update tags
        updateTags(metadata.tags)
    }

    private func updateTags(_ tags: [String]) {
        // Clear existing tags
        tagsContainer.subviews.forEach { $0.removeFromSuperview() }

        guard !tags.isEmpty else { return }

        let stackView = NSStackView()
        stackView.orientation = .horizontal
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        tagsContainer.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.trailingAnchor.constraint(equalTo: tagsContainer.trailingAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: tagsContainer.leadingAnchor),
            stackView.centerYAnchor.constraint(equalTo: tagsContainer.centerYAnchor),
        ])

        for tag in tags.prefix(3) {
            let color = categories.first { $0.name == tag }?.color
            let pill = PillView(text: tag, colorName: color)
            stackView.addArrangedSubview(pill)
        }

        if tags.count > 3 {
            let morePill = PillView(text: "+\(tags.count - 3)")
            stackView.addArrangedSubview(morePill)
        }
    }

    private func createPill(text: String, colorName: String?) -> NSView {
        let container = NSView()
        container.wantsLayer = true
        container.layer?.backgroundColor = AppTheme.pillBackgroundNSColor.cgColor
        container.layer?.cornerRadius = 4

        let stack = NSStackView()
        stack.orientation = .horizontal
        stack.spacing = 4
        stack.edgeInsets = NSEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])

        if let colorName = colorName {
            let dot = NSView()
            dot.wantsLayer = true
            dot.layer?.backgroundColor = colorFromName(colorName).cgColor
            dot.layer?.cornerRadius = 3
            dot.translatesAutoresizingMaskIntoConstraints = false
            stack.addArrangedSubview(dot)

            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 6),
                dot.heightAnchor.constraint(equalToConstant: 6),
            ])
        }

        let label = NSTextField(labelWithString: text)
        label.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        label.textColor = AppTheme.textSecondaryNSColor
        label.lineBreakMode = .byTruncatingTail
        stack.addArrangedSubview(label)

        return container
    }

    private func colorFromName(_ name: String) -> NSColor {
        AppTheme.categoryNSColor(for: name)
    }

    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    private func formatLastOpened(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    override func layout() {
        super.layout()
        backgroundLayer.frame = bounds
        backgroundLayer.path = NSBezierPath(roundedRect: bounds, xRadius: 12, yRadius: 12).cgPath
    }
}
