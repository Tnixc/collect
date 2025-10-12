import AppKit
import Foundation
import SwiftUI

struct AppKitCardsGrid: NSViewRepresentable {
    let files: [FileItem]
    let metadata: [UUID: FileMetadata]
    let categories: [Collect.Category]
    let cardColors: [NSColor]
    let onTap: (UUID) -> Void
    let editAction: (UUID) -> Void
    let addToCategoryAction: (UUID, String) -> Void
    let createCategoryAction: (UUID) -> Void

    func makeNSView(context: Context) -> NSView {
        let containerView = ResizingContainerView()
        let collectionView = NSCollectionView()
        let layout = LeftAlignedFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = NSEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        collectionView.backgroundColors = [.clear]
        collectionView.register(
            FileCardItem.self,
            forItemWithIdentifier: NSUserInterfaceItemIdentifier("FileCardItem")
        )

        containerView.collectionView = collectionView
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: containerView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        return containerView
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard let containerView = nsView as? ResizingContainerView,
              let collectionView = containerView.collectionView else { return }
        context.coordinator.files = files
        context.coordinator.metadata = metadata
        context.coordinator.categories = categories
        context.coordinator.cardColors = cardColors
        containerView.numberOfItems = files.count
        collectionView.reloadData()
        // Ensure the collection view resizes properly
        collectionView.collectionViewLayout?.invalidateLayout()
        // Recalculate total height
        containerView.recalculateTotalHeight()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onTap: onTap,
            editAction: editAction,
            addToCategoryAction: addToCategoryAction,
            createCategoryAction: createCategoryAction
        )
    }

    class Coordinator: NSObject, NSCollectionViewDataSource,
        NSCollectionViewDelegateFlowLayout
    {
        var files: [FileItem] = []
        var metadata: [UUID: FileMetadata] = [:]
        var categories: [Collect.Category] = []
        var cardColors: [NSColor] = []

        let onTap: (UUID) -> Void
        let editAction: (UUID) -> Void
        let addToCategoryAction: (UUID, String) -> Void
        let createCategoryAction: (UUID) -> Void

        init(
            onTap: @escaping (UUID) -> Void,
            editAction: @escaping (UUID) -> Void,
            addToCategoryAction: @escaping (UUID, String) -> Void,
            createCategoryAction: @escaping (UUID) -> Void
        ) {
            self.onTap = onTap
            self.editAction = editAction
            self.addToCategoryAction = addToCategoryAction
            self.createCategoryAction = createCategoryAction
        }

        func collectionView(
            _: NSCollectionView,
            numberOfItemsInSection _: Int
        ) -> Int {
            return files.count
        }

        func collectionView(
            _ collectionView: NSCollectionView,
            itemForRepresentedObjectAt indexPath: IndexPath
        ) -> NSCollectionViewItem {
            let item =
                collectionView.makeItem(
                    withIdentifier: NSUserInterfaceItemIdentifier(
                        "FileCardItem"
                    ),
                    for: indexPath
                ) as! FileCardItem
            let file = files[indexPath.item]
            if let meta = metadata[file.id] {
                item.configure(
                    with: file,
                    metadata: meta,
                    categories: categories,
                    backgroundColor: cardColors[
                        indexPath.item % cardColors.count
                    ],
                    onTap: { self.onTap(file.id) },
                    editAction: { self.editAction(file.id) },
                    addToCategoryAction: { category in
                        self.addToCategoryAction(file.id, category)
                    },
                    createCategoryAction: { self.createCategoryAction(file.id) }
                )
            }
            return item
        }

        func collectionView(
            _ collectionView: NSCollectionView,
            layout collectionViewLayout: NSCollectionViewLayout,
            sizeForItemAt _: IndexPath
        ) -> NSSize {
            let layout = collectionViewLayout as! NSCollectionViewFlowLayout
            let availableWidth =
                collectionView.bounds.width - layout.sectionInset.left
                    - layout.sectionInset.right
            let minWidth: CGFloat = 250
            let maxWidth: CGFloat = 330
            let spacing: CGFloat = layout.minimumInteritemSpacing

            // Calculate number of columns that best fits the width
            var columns = max(
                1,
                Int(floor((availableWidth + spacing) / (minWidth + spacing)))
            )
            var itemWidth =
                (availableWidth - (CGFloat(columns - 1) * spacing))
                    / CGFloat(columns)

            // If itemWidth > maxWidth, increase columns to reduce width
            while itemWidth > maxWidth && columns < 20 {
                columns += 1
                itemWidth =
                    (availableWidth - (CGFloat(columns - 1) * spacing))
                        / CGFloat(columns)
            }

            // If itemWidth < minWidth, decrease columns to increase width
            while itemWidth < minWidth && columns > 1 {
                columns -= 1
                itemWidth =
                    (availableWidth - (CGFloat(columns - 1) * spacing))
                        / CGFloat(columns)
            }

            // Clamp to min and max to maintain consistent card sizes
            itemWidth = max(minWidth, min(maxWidth, itemWidth))

            return NSSize(width: itemWidth, height: 280)
        }
    }
}

class FileCardItem: NSCollectionViewItem {
    private let tagsContainer = WrappingFlowView()
    private let titleLabel = NSTextField()
    private let authorLabel = NSTextField()
    private let bottomContainer = WrappingFlowView()
    private var categories: [Collect.Category] = []
    private var onTapAction: (() -> Void)?
    private var editAction: (() -> Void)?
    private var addToCategoryAction: ((String) -> Void)?
    private var createCategoryAction: (() -> Void)?
    private var titleToTopConstraint: NSLayoutConstraint?
    private var titleToTagsConstraint: NSLayoutConstraint?

    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.layer?.masksToBounds = false
        view.layer?.cornerRadius = 8
        view.layer?.borderWidth = 2
        view.layer?.borderColor = AppTheme.dividerNSColor.cgColor

        // Add subtle shadow
        view.layer?.shadowColor = AppTheme.shadowNSColor.cgColor
        view.layer?.shadowOffset = NSSize(width: 0, height: 2)
        view.layer?.shadowRadius = 4
        view.layer?.shadowOpacity = 1.0

        setupViews()
        setupConstraints()
        setupGestures()
    }

    private func setupViews() {
        tagsContainer.spacing = 6
        view.addSubview(tagsContainer)

        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        titleLabel.font = NSFont(
            descriptor: (NSFont(name: "New York Medium", size: 18)
                ?? NSFont.systemFont(ofSize: 18, weight: .semibold))
                .fontDescriptor
                .addingAttributes([
                    .traits: [
                        NSFontDescriptor.TraitKey.weight: NSFont.Weight.semibold,
                    ],
                ]),
            size: 18
        )
        titleLabel.maximumNumberOfLines = 3
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.usesSingleLineMode = false
        titleLabel.cell?.wraps = true
        titleLabel.cell?.isScrollable = false
        view.addSubview(titleLabel)

        authorLabel.isEditable = false
        authorLabel.isBordered = false
        authorLabel.backgroundColor = .clear
        authorLabel.font = NSFont.systemFont(ofSize: 12)
        authorLabel.textColor = AppTheme.textSecondaryNSColor
        authorLabel.maximumNumberOfLines = 1
        authorLabel.lineBreakMode = .byTruncatingTail
        view.addSubview(authorLabel)

        bottomContainer.spacing = 6
        view.addSubview(bottomContainer)
    }

    private func setupConstraints() {
        tagsContainer.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tagsContainer.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 12
            ),
            tagsContainer.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor,
                constant: -12
            ),
            tagsContainer.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: 12
            ),

            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 12
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -12
            ),

            authorLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 12
            ),
            authorLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -12
            ),
            authorLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 4
            ),

            bottomContainer.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 12
            ),
            bottomContainer.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor,
                constant: -12
            ),
            bottomContainer.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -12
            ),
        ])

        titleToTagsConstraint = titleLabel.topAnchor.constraint(equalTo: tagsContainer.bottomAnchor, constant: 12)
        titleToTopConstraint = titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 12)
        titleToTagsConstraint?.isActive = true
    }

    private func setupGestures() {
        let clickGesture = NSClickGestureRecognizer(
            target: self,
            action: #selector(handleClick)
        )
        view.addGestureRecognizer(clickGesture)
    }

    @objc private func handleClick() {
        onTapAction?()
    }

    private func createMenu() -> NSMenu {
        let menu = NSMenu()
        let openItem = NSMenuItem(
            title: "Open",
            action: #selector(openItem),
            keyEquivalent: ""
        )
        openItem.target = self
        menu.addItem(openItem)
        let editItem = NSMenuItem(
            title: "Edit Metadata",
            action: #selector(editItem),
            keyEquivalent: ""
        )
        editItem.target = self
        menu.addItem(editItem)
        let categoryMenu = NSMenu()
        for category in categories {
            let item = NSMenuItem(
                title: category.name,
                action: #selector(addToCategory(_:)),
                keyEquivalent: ""
            )
            item.target = self
            categoryMenu.addItem(item)
        }
        let createItem = NSMenuItem(
            title: "Create New Category",
            action: #selector(createCategory),
            keyEquivalent: ""
        )
        createItem.target = self
        categoryMenu.addItem(createItem)
        let categoryItem = NSMenuItem(
            title: "Add to Category",
            action: nil,
            keyEquivalent: ""
        )
        categoryItem.submenu = categoryMenu
        menu.addItem(categoryItem)
        return menu
    }

    @objc private func openItem() {
        onTapAction?()
    }

    @objc private func editItem() {
        editAction?()
    }

    @objc private func addToCategory(_ sender: NSMenuItem) {
        addToCategoryAction?(sender.title)
    }

    @objc private func createCategory() {
        createCategoryAction?()
    }

    func configure(
        with file: FileItem,
        metadata: FileMetadata,
        categories: [Collect.Category],
        backgroundColor: NSColor,
        onTap: @escaping () -> Void,
        editAction: @escaping () -> Void,
        addToCategoryAction: @escaping (String) -> Void,
        createCategoryAction: @escaping () -> Void
    ) {
        self.categories = categories
        onTapAction = onTap
        self.editAction = editAction
        self.addToCategoryAction = addToCategoryAction
        self.createCategoryAction = createCategoryAction

        view.menu = createMenu()
        view.layer?.backgroundColor = backgroundColor.cgColor

        // Clear existing tags
        tagsContainer.subviews.forEach { $0.removeFromSuperview() }

        // Add tags and year
        for tag in metadata.tags {
            let color =
                categories.first(where: { $0.name == tag })?.color ?? "gray"
            let pill = createPill(text: tag, colorName: color)
            tagsContainer.addSubview(pill)
        }
        if let year = metadata.year {
            let pill = createPill(text: String(year), colorName: nil)
            tagsContainer.addSubview(pill)
        }

        tagsContainer.isHidden = tagsContainer.subviews.isEmpty
        if tagsContainer.subviews.isEmpty {
            titleToTagsConstraint?.isActive = false
            titleToTopConstraint?.isActive = true
        } else {
            titleToTopConstraint?.isActive = false
            titleToTagsConstraint?.isActive = true
        }

        titleLabel.stringValue = metadata.title ?? file.filename
        authorLabel.stringValue = metadata.authors.joined(separator: ", ")

        // Clear bottom
        bottomContainer.subviews.forEach { $0.removeFromSuperview() }

        // Add bottom pills
        let sizePill = createPill(
            text: formatFileSize(file.fileSize),
            colorName: nil
        )
        bottomContainer.addSubview(sizePill)

        if let pages = metadata.pages {
            let pagesPill = createPill(text: "\(pages) pages", colorName: nil)
            bottomContainer.addSubview(pagesPill)
        }

        let openedPill = createPill(
            text: metadata.lastOpened.map { formatLastOpened($0) }
                ?? "Never opened",
            colorName: nil
        )
        bottomContainer.addSubview(openedPill)

        tagsContainer.needsLayout = true
        bottomContainer.needsLayout = true
        view.needsLayout = true
    }

    private func createPill(text: String, colorName: String?) -> NSView {
        let container = NSView()
        container.wantsLayer = true
        container.layer?.backgroundColor = AppTheme.pillBackgroundNSColor.cgColor
        container.layer?.cornerRadius = 4
        container.translatesAutoresizingMaskIntoConstraints = false

        let stack = NSStackView()
        stack.orientation = .horizontal
        stack.spacing = 4
        stack.alignment = .centerY
        stack.distribution = .gravityAreas
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        if let colorName = colorName {
            let colorView = NSView()
            colorView.wantsLayer = true
            colorView.layer?.backgroundColor = colorFromName(colorName).cgColor
            colorView.layer?.cornerRadius = 3
            colorView.translatesAutoresizingMaskIntoConstraints = false
            stack.addArrangedSubview(colorView)
            colorView.widthAnchor.constraint(equalToConstant: 6).isActive = true
            colorView.heightAnchor.constraint(equalToConstant: 6).isActive =
                true
        }

        let label = NSTextField(labelWithString: text)
        label.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        label.textColor = AppTheme.textSecondaryNSColor
        label.lineBreakMode = .byTruncatingTail
        stack.addArrangedSubview(label)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: 8
            ),
            stack.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -8
            ),
            stack.topAnchor.constraint(
                equalTo: container.topAnchor,
                constant: 4
            ),
            stack.bottomAnchor.constraint(
                equalTo: container.bottomAnchor,
                constant: -4
            ),
            container.heightAnchor.constraint(
                equalTo: stack.heightAnchor,
                constant: 8
            ),
        ])

        return container
    }

    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    private func formatLastOpened(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return
            "Opened \(formatter.localizedString(for: date, relativeTo: Date()))"
    }

    private func colorFromName(_ name: String) -> NSColor {
        AppTheme.categoryNSColor(for: name)
    }
}

// Container view that observes size changes and invalidates layout
class ResizingContainerView: NSView {
    weak var collectionView: NSCollectionView?
    var numberOfItems: Int = 0
    var totalHeight: CGFloat = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: NSSize {
        return NSSize(width: NSView.noIntrinsicMetric, height: totalHeight)
    }

    private var resizeWorkItem: DispatchWorkItem?

    func recalculateTotalHeight() {
        let availableWidth = bounds.width
        let minWidth: CGFloat = 210
        let maxWidth: CGFloat = 290
        let spacing: CGFloat = 16

        var columns = max(1, Int(floor((availableWidth + spacing) / (minWidth + spacing))))
        var itemWidth = (availableWidth - CGFloat(columns - 1) * spacing) / CGFloat(columns)

        while itemWidth > maxWidth, columns < 20 {
            columns += 1
            itemWidth = (availableWidth - CGFloat(columns - 1) * spacing) / CGFloat(columns)
        }

        while itemWidth < minWidth, columns > 1 {
            columns -= 1
            itemWidth = (availableWidth - CGFloat(columns - 1) * spacing) / CGFloat(columns)
        }

        itemWidth = max(minWidth, min(maxWidth, itemWidth))

        let rows = numberOfItems == 0 ? 0 : Int(ceil(Double(numberOfItems) / Double(columns)))
        let contentHeight = rows == 0 ? 0 : CGFloat(rows) * 280 + CGFloat(rows - 1) * 16 + 16
        totalHeight = contentHeight
    }

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)

        // Cancel any pending layout invalidation
        resizeWorkItem?.cancel()

        // Invalidate immediately for better responsiveness
        collectionView?.collectionViewLayout?.invalidateLayout()

        // Recalculate total height
        recalculateTotalHeight()

        // Schedule a final invalidation after resize settles
        let workItem = DispatchWorkItem { [weak self] in
            self?.collectionView?.collectionViewLayout?.invalidateLayout()
        }
        resizeWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
    }

    override func layout() {
        super.layout()
        collectionView?.collectionViewLayout?.invalidateLayout()
    }
}

// Left-aligned collection view flow layout
class LeftAlignedFlowLayout: NSCollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0

        for layoutAttribute in attributes {
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }

            layoutAttribute.frame.origin.x = leftMargin

            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }

        return attributes
    }
}

// Custom wrapping flow view for pills
class WrappingFlowView: NSView {
    var spacing: CGFloat = 6

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        translatesAutoresizingMaskIntoConstraints = false
    }

    override func layout() {
        super.layout()
        layoutSubviews()
    }

    private func layoutSubviews() {
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.fittingSize

            // Check if we need to wrap to next line
            if currentX + size.width > bounds.width, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            subview.frame = NSRect(
                x: currentX,
                y: currentY,
                width: size.width,
                height: size.height
            )
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }

    override var intrinsicContentSize: NSSize {
        guard bounds.width > 0 else {
            return NSSize(width: NSView.noIntrinsicMetric, height: 24)
        }

        var totalHeight: CGFloat = 0
        var currentX: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.fittingSize

            if currentX + size.width > bounds.width && currentX > 0 {
                currentX = 0
                totalHeight += lineHeight + spacing
                lineHeight = 0
            }

            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }

        totalHeight += lineHeight
        return NSSize(
            width: NSView.noIntrinsicMetric,
            height: max(24, totalHeight)
        )
    }
}
