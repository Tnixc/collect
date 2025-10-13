import AppKit
import Foundation
import SwiftUI

struct AppKitCardsGrid: NSViewRepresentable {
    let files: [FileItem]
    let metadata: [UUID: FileMetadata]
    let categories: [Collect.Category]
    let cardColors: [NSColor]
    let disableHover: Bool
    let onTap: (UUID) -> Void
    let editAction: (UUID) -> Void
    let addToCategoryAction: (UUID, String) -> Void
    let createCategoryAction: (UUID) -> Void
    let deleteAction: (UUID) -> Void
    let showInFinderAction: (UUID) -> Void
    let addToReadingListAction: (UUID) -> Void
    let removeFromReadingListAction: (UUID) -> Void

    func makeNSView(context: Context) -> NSView {
        let containerView = ResizingContainerView()
        let collectionView = NSCollectionView()
        let layout = LeftAlignedFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = NSEdgeInsets(
            top: 0,
            left: 0,
            bottom: 16,
            right: 0
        )
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
            collectionView.topAnchor.constraint(
                equalTo: containerView.topAnchor
            ),
            collectionView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor
            ),
            collectionView.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor
            ),
        ])

        return containerView
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard let containerView = nsView as? ResizingContainerView,
              let collectionView = containerView.collectionView
        else { return }
        context.coordinator.files = files
        context.coordinator.metadata = metadata
        context.coordinator.categories = categories
        context.coordinator.cardColors = cardColors

        // Update disableHover state and propagate to visible cards
        if context.coordinator.disableHover != disableHover {
            context.coordinator.disableHover = disableHover
            // Update all visible items
            for item in collectionView.visibleItems() {
                if let cardItem = item as? FileCardItem {
                    cardItem.updateHoverState(disabled: disableHover)
                }
            }
        }

        containerView.numberOfItems = files.count
        collectionView.reloadData()
        // Ensure the collection view resizes properly
        collectionView.collectionViewLayout?.invalidateLayout()
        // Recalculate total height
        containerView.recalculateTotalHeight()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            disableHover: disableHover,
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

    class Coordinator: NSObject, NSCollectionViewDataSource,
        NSCollectionViewDelegateFlowLayout
    {
        var files: [FileItem] = []
        var metadata: [UUID: FileMetadata] = [:]
        var categories: [Collect.Category] = []
        var cardColors: [NSColor] = []
        var disableHover: Bool = false
        let onTap: (UUID) -> Void
        let editAction: (UUID) -> Void
        let addToCategoryAction: (UUID, String) -> Void
        let createCategoryAction: (UUID) -> Void
        var deleteAction: (UUID) -> Void
        var showInFinderAction: (UUID) -> Void
        var addToReadingListAction: (UUID) -> Void
        var removeFromReadingListAction: (UUID) -> Void

        init(
            disableHover: Bool,
            onTap: @escaping (UUID) -> Void,
            editAction: @escaping (UUID) -> Void,
            addToCategoryAction: @escaping (UUID, String) -> Void,
            createCategoryAction: @escaping (UUID) -> Void,
            deleteAction: @escaping (UUID) -> Void,
            showInFinderAction: @escaping (UUID) -> Void,
            addToReadingListAction: @escaping (UUID) -> Void,
            removeFromReadingListAction: @escaping (UUID) -> Void
        ) {
            files = []
            metadata = [:]
            categories = []
            cardColors = []
            self.disableHover = disableHover
            self.onTap = onTap
            self.editAction = editAction
            self.addToCategoryAction = addToCategoryAction
            self.createCategoryAction = createCategoryAction
            self.deleteAction = deleteAction
            self.showInFinderAction = showInFinderAction
            self.addToReadingListAction = addToReadingListAction
            self.removeFromReadingListAction = removeFromReadingListAction
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
                // Use metadata.cardColor to determine the background color
                let backgroundColor: NSColor
                if let colorName = AppTheme.cardColors[meta.cardColor] {
                    backgroundColor = NSColor(colorName)
                } else {
                    // Fallback to hash-based color if cardColor is not found
                    backgroundColor =
                        cardColors[
                            abs(file.id.hashValue) % cardColors.count
                        ]
                }

                item.configure(
                    with: file,
                    metadata: meta,
                    categories: categories,
                    backgroundColor: backgroundColor,
                    disableHover: disableHover,
                    onTap: { self.onTap(file.id) },
                    editAction: { self.editAction(file.id) },
                    addToCategoryAction: { category in
                        self.addToCategoryAction(file.id, category)
                    },
                    createCategoryAction: {
                        self.createCategoryAction(file.id)
                    },
                    deleteAction: { self.deleteAction(file.id) },
                    showInFinderAction: { self.showInFinderAction(file.id) },
                    addToReadingListAction: {
                        self.addToReadingListAction(file.id)
                    },
                    removeFromReadingListAction: {
                        self.removeFromReadingListAction(file.id)
                    }
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

extension NSBezierPath {
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)

        for i in 0 ..< elementCount {
            let type = element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(
                    to: points[2],
                    control1: points[0],
                    control2: points[1]
                )
            case .closePath:
                path.closeSubpath()
            @unknown default:
                break
            }
        }

        return path
    }
}

class HoverableCardView: NSView {
    var onMouseEntered: (() -> Void)?
    var onMouseExited: (() -> Void)?
    private var trackingArea: NSTrackingArea?
    private var isMouseInside = false

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        if let trackingArea = trackingArea {
            removeTrackingArea(trackingArea)
        }

        let options: NSTrackingArea.Options = [
            .mouseEnteredAndExited,
            .activeInKeyWindow,
            .inVisibleRect,
        ]
        trackingArea = NSTrackingArea(
            rect: bounds,
            options: options,
            owner: self,
            userInfo: nil
        )
        if let trackingArea = trackingArea {
            addTrackingArea(trackingArea)
        }
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        isMouseInside = true
        onMouseEntered?()
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        isMouseInside = false
        onMouseExited?()
    }

    override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        // Check if mouse is still inside after resize/scroll
        if isMouseInside {
            let mouseLocation =
                window?.mouseLocationOutsideOfEventStream ?? .zero
            let locationInView = convert(mouseLocation, from: nil)
            if !bounds.contains(locationInView) {
                isMouseInside = false
                onMouseExited?()
            }
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
    private var deleteAction: (() -> Void)?
    private var showInFinderAction: (() -> Void)?
    private var addToReadingListAction: (() -> Void)?
    private var removeFromReadingListAction: (() -> Void)?
    private var file: FileItem?
    private var metadata: FileMetadata?
    private var titleToTopConstraint: NSLayoutConstraint?
    private var titleToTagsConstraint: NSLayoutConstraint?
    private var isHovering = false
    private var disableHover = false

    private var backgroundLayer: CAShapeLayer?
    private var contentContainer: NSView?
    private var scrollObserver: NSObjectProtocol?

    deinit {
        if let observer = scrollObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    override func loadView() {
        view = HoverableCardView()
        view.wantsLayer = true
        view.layer?.masksToBounds = false

        // Add subtle shadow (will be animated on hover)
        view.layer?.shadowColor = NSColor.black.cgColor
        view.layer?.shadowOffset = NSSize(width: 0, height: 0)
        view.layer?.shadowRadius = 0
        view.layer?.shadowOpacity = 0.0

        // Create content container that will be scaled
        contentContainer = NSView()
        contentContainer?.wantsLayer = true
        contentContainer?.layer?.masksToBounds = false

        view.addSubview(contentContainer!)
        contentContainer?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentContainer!.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            contentContainer!.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            contentContainer!.topAnchor.constraint(equalTo: view.topAnchor),
            contentContainer!.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
        ])

        (view as? HoverableCardView)?.onMouseEntered = { [weak self] in
            self?.mouseEntered(with: NSEvent())
        }
        (view as? HoverableCardView)?.onMouseExited = { [weak self] in
            self?.mouseExited(with: NSEvent())
        }

        setupViews()
        setupConstraints()
        setupGestures()
        setupScrollObserver()
    }

    private func setupScrollObserver() {
        scrollObserver = NotificationCenter.default.addObserver(
            forName: NSView.boundsDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            if self.isHovering {
                // Check if mouse is still over the view
                if let window = self.view.window {
                    let mouseLocation = window.mouseLocationOutsideOfEventStream
                    let locationInView = self.view.convert(
                        mouseLocation,
                        from: nil
                    )
                    if !self.view.bounds.contains(locationInView) {
                        self.mouseExited(with: NSEvent())
                    }
                }
            }
        }
    }

    override func viewDidLayout() {
        super.viewDidLayout()

        // Set anchor point to top-left (default is center)
        if let layer = contentContainer?.layer {
            layer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
            layer.position = CGPoint(x: 0, y: 0)
        }

        applyAsymmetricCorners()
    }

    private func applyAsymmetricCorners() {
        let bounds = view.bounds
        let path = NSBezierPath()

        // Start from top-left, going clockwise
        // Top-left corner (8px radius)
        path.move(to: NSPoint(x: 8, y: 0))
        path.line(to: NSPoint(x: bounds.width - 20, y: 0))

        // Top-right corner (20px radius)
        path.appendArc(
            withCenter: NSPoint(x: bounds.width - 20, y: 20),
            radius: 20,
            startAngle: 270,
            endAngle: 0,
            clockwise: false
        )

        path.line(to: NSPoint(x: bounds.width, y: bounds.height - 20))

        // Bottom-right corner (20px radius)
        path.appendArc(
            withCenter: NSPoint(x: bounds.width - 20, y: bounds.height - 20),
            radius: 20,
            startAngle: 0,
            endAngle: 90,
            clockwise: false
        )

        path.line(to: NSPoint(x: 8, y: bounds.height))

        // Bottom-left corner (8px radius)
        path.appendArc(
            withCenter: NSPoint(x: 8, y: bounds.height - 8),
            radius: 8,
            startAngle: 90,
            endAngle: 180,
            clockwise: false
        )

        path.line(to: NSPoint(x: 0, y: 8))

        // Top-left corner continued (8px radius)
        path.appendArc(
            withCenter: NSPoint(x: 8, y: 8),
            radius: 8,
            startAngle: 180,
            endAngle: 270,
            clockwise: false
        )

        path.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath

        // Apply mask for clipping content container
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        contentContainer?.layer?.mask = maskLayer

        // Update shadow path for better performance
        view.layer?.shadowPath = path.cgPath
    }

    private func setupViews() {
        tagsContainer.spacing = 6
        contentContainer?.addSubview(tagsContainer)

        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        titleLabel.font =
            NewYork.nsFont(size: 18, weight: .semibold, opticalSize: .medium)
                ?? NSFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = AppTheme.textPrimaryNSColor
        titleLabel.maximumNumberOfLines = 3
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.usesSingleLineMode = false
        titleLabel.cell?.wraps = true
        titleLabel.cell?.isScrollable = false
        contentContainer?.addSubview(titleLabel)

        authorLabel.isEditable = false
        authorLabel.isBordered = false
        authorLabel.backgroundColor = .clear
        authorLabel.font =
            NewYork.nsFont(size: 12, weight: .regular, opticalSize: .small)
                ?? NSFont.systemFont(ofSize: 12)
        authorLabel.textColor = AppTheme.textSecondaryNSColor
        authorLabel.maximumNumberOfLines = 1
        authorLabel.lineBreakMode = .byTruncatingTail
        contentContainer?.addSubview(authorLabel)

        bottomContainer.spacing = 6
        contentContainer?.addSubview(bottomContainer)
    }

    private func setupConstraints() {
        tagsContainer.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false

        guard let container = contentContainer else { return }

        NSLayoutConstraint.activate([
            tagsContainer.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: 12
            ),
            tagsContainer.trailingAnchor.constraint(
                lessThanOrEqualTo: container.trailingAnchor,
                constant: -12
            ),
            tagsContainer.topAnchor.constraint(
                equalTo: container.topAnchor,
                constant: 12
            ),

            titleLabel.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: 12
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -12
            ),

            authorLabel.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: 12
            ),
            authorLabel.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -12
            ),
            authorLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 4
            ),

            bottomContainer.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: 12
            ),
            bottomContainer.trailingAnchor.constraint(
                lessThanOrEqualTo: container.trailingAnchor,
                constant: -12
            ),
            bottomContainer.bottomAnchor.constraint(
                equalTo: container.bottomAnchor,
                constant: -12
            ),
        ])

        titleToTagsConstraint = titleLabel.topAnchor.constraint(
            equalTo: tagsContainer.bottomAnchor,
            constant: 12
        )
        titleToTopConstraint = titleLabel.topAnchor.constraint(
            equalTo: view.topAnchor,
            constant: 12
        )
        titleToTagsConstraint?.isActive = true
    }

    private func setupGestures() {
        let clickGesture = NSClickGestureRecognizer(
            target: self,
            action: #selector(handleClick)
        )
        clickGesture.numberOfClicksRequired = 2
        view.addGestureRecognizer(clickGesture)
    }

    @objc private func handleClick() {
        onTapAction?()
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        isHovering = true
        if !disableHover {
            animateHover(isEntering: true)
            NSCursor.pointingHand.push()
        }
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        isHovering = false
        if !disableHover {
            animateHover(isEntering: false)
            NSCursor.pop()
        }
    }

    private func animateHover(isEntering: Bool) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(
                controlPoints: 0.34,
                1.16,
                0.64,
                1.0
            )
            context.allowsImplicitAnimation = true

            let scale: CGFloat = isEntering ? 0.98 : 1.0
            let height = contentContainer?.bounds.height ?? 0
            let width = contentContainer?.bounds.width ?? 0

            var transform = CATransform3DIdentity
            // Move down to top edge
            transform = CATransform3DTranslate(
                transform,
                width * 0.5 * (1 - scale),
                height * 0.5 * (1 - scale),
                0
            )
            // Scale
            transform = CATransform3DScale(transform, scale, scale, 1.0)

            contentContainer?.layer?.transform = transform

            view.layer?.shadowOpacity = isEntering ? 0.05 : 0.0
            view.layer?.shadowRadius = isEntering ? 22 : 0
            view.layer?.shadowOffset = NSSize(
                width: 0,
                height: 0
            )
        }
    }

    private func createMenu() -> NSMenu {
        let menu = NSMenu()
        let openItem = NSMenuItem(
            title: "Open",
            action: #selector(openItem),
            keyEquivalent: ""
        )
        openItem.image = NSImage(
            systemSymbolName: "doc",
            accessibilityDescription: nil
        )
        openItem.target = self
        menu.addItem(openItem)
        let editItem = NSMenuItem(
            title: "Edit Metadata",
            action: #selector(editItem),
            keyEquivalent: ""
        )
        editItem.image = NSImage(
            systemSymbolName: "pencil",
            accessibilityDescription: nil
        )
        editItem.target = self
        menu.addItem(editItem)

        // Reading list item
        let isInReadingList = metadata?.isInReadingList ?? false
        let readingListItem = NSMenuItem(
            title: isInReadingList
                ? "Remove from Reading List" : "Add to Reading List",
            action: isInReadingList
                ? #selector(removeFromReadingList)
                : #selector(addToReadingList),
            keyEquivalent: ""
        )
        readingListItem.image = NSImage(
            systemSymbolName: isInReadingList ? "book.fill" : "book",
            accessibilityDescription: nil
        )
        readingListItem.target = self
        menu.addItem(readingListItem)

        menu.addItem(NSMenuItem.separator())
        let deleteItem = NSMenuItem(
            title: "Delete",
            action: #selector(deleteItem),
            keyEquivalent: ""
        )
        deleteItem.image = NSImage(
            systemSymbolName: "trash",
            accessibilityDescription: nil
        )
        deleteItem.target = self
        menu.addItem(deleteItem)
        let showItem = NSMenuItem(
            title: "Show in Finder",
            action: #selector(showInFinder),
            keyEquivalent: ""
        )
        showItem.image = NSImage(
            systemSymbolName: "folder",
            accessibilityDescription: nil
        )
        showItem.target = self
        menu.addItem(showItem)
        let categoryMenu = NSMenu()
        for category in categories where category.name != "Uncategorized" {
            let item = NSMenuItem(
                title: category.name,
                action: #selector(addToCategory(_:)),
                keyEquivalent: ""
            )
            item.image = NSImage(
                systemSymbolName: "tag",
                accessibilityDescription: nil
            )
            item.target = self
            categoryMenu.addItem(item)
        }
        let createItem = NSMenuItem(
            title: "Create New Category",
            action: #selector(createCategory),
            keyEquivalent: ""
        )
        createItem.image = NSImage(
            systemSymbolName: "plus",
            accessibilityDescription: nil
        )
        createItem.target = self
        categoryMenu.addItem(createItem)
        let categoryItem = NSMenuItem(
            title: "Add to Category",
            action: nil,
            keyEquivalent: ""
        )
        categoryItem.image = NSImage(
            systemSymbolName: "tag",
            accessibilityDescription: nil
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

    @objc private func deleteItem() {
        let alert = NSAlert()
        alert.messageText = "Delete File"
        alert.informativeText =
            "Are you sure you want to delete this file? This action cannot be undone."
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            deleteAction?()
        }
    }

    @objc private func showInFinder() {
        showInFinderAction?()
    }

    @objc private func addToCategory(_ sender: NSMenuItem) {
        addToCategoryAction?(sender.title)
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
        backgroundColor: NSColor,
        disableHover: Bool,
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
        self.disableHover = disableHover

        view.menu = createMenu()
        contentContainer?.layer?.backgroundColor = backgroundColor.cgColor

        // Update background layer with saturated color from mapping
        let saturatedColor = AppTheme.saturatedColor(for: backgroundColor)
        backgroundLayer?.fillColor = saturatedColor.cgColor

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
        return PillView(text: text, colorName: colorName)
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

    func updateHoverState(disabled: Bool) {
        disableHover = disabled
        // If we're disabling hover and currently hovering, exit hover state
        if disabled, isHovering {
            mouseExited(with: NSEvent())
        }
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

        var columns = max(
            1,
            Int(floor((availableWidth + spacing) / (minWidth + spacing)))
        )
        var itemWidth =
            (availableWidth - CGFloat(columns - 1) * spacing) / CGFloat(columns)

        while itemWidth > maxWidth, columns < 20 {
            columns += 1
            itemWidth =
                (availableWidth - CGFloat(columns - 1) * spacing)
                    / CGFloat(columns)
        }

        while itemWidth < minWidth, columns > 1 {
            columns -= 1
            itemWidth =
                (availableWidth - CGFloat(columns - 1) * spacing)
                    / CGFloat(columns)
        }

        itemWidth = max(minWidth, min(maxWidth, itemWidth))

        let rows =
            numberOfItems == 0
                ? 0 : Int(ceil(Double(numberOfItems) / Double(columns)))
        let contentHeight =
            rows == 0 ? 0 : CGFloat(rows) * 280 + CGFloat(rows - 1) * 16 + 16
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
    override func layoutAttributesForElements(in rect: NSRect)
        -> [NSCollectionViewLayoutAttributes]
    {
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
