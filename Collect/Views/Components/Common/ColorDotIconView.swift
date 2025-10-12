import AppKit

/// Reusable circular color dot with a centered SF Symbol.
/// - Provides a colored circular background and a system symbol tinted above it.
/// - Auto layout friendly: exposes intrinsicContentSize based on `size` (diameter).
/// - Dynamically updates when properties change.
public final class ColorDotIconView: NSView {
    // MARK: - Public API

    /// Background circle color.
    public var dotColor: NSColor = AppTheme.categoryNSColor(for: "blue") {
        didSet { updateBackground() }
    }

    /// SF Symbol name (e.g., "person.fill", "doc.text.fill").
    public var symbolName: String = "doc.text.fill" {
        didSet { updateSymbolImage() }
    }

    /// Symbol point size used to render the SF Symbol image.
    public var symbolPointSize: CGFloat = 12 {
        didSet {
            updateSymbolImage()
            updateImageSizeConstraints()
        }
    }

    /// Symbol weight for SF Symbol configuration.
    public var symbolWeight: NSFont.Weight = .semibold {
        didSet { updateSymbolImage() }
    }

    /// Color used to tint the SF Symbol.
    public var symbolTintColor: NSColor = .white {
        didSet { imageView.contentTintColor = symbolTintColor }
    }

    /// Diameter (in points) for the circular background.
    public var size: CGFloat = 20 {
        didSet {
            invalidateIntrinsicContentSize()
            needsLayout = true
        }
    }

    /// Optional border color for the dot. Set to nil to hide.
    public var borderColor: NSColor? {
        didSet { updateBorder() }
    }

    /// Border width (in points). Only applied when `borderColor` is non-nil.
    public var borderWidth: CGFloat = 1 {
        didSet { updateBorder() }
    }

    // MARK: - Private UI

    private let imageView = NSImageView()
    private var imageWidthConstraint: NSLayoutConstraint?
    private var imageHeightConstraint: NSLayoutConstraint?

    // MARK: - Init

    public convenience init(symbolName: String,
                            categoryColorName: String? = nil,
                            size: CGFloat = 20,
                            symbolPointSize: CGFloat = 12,
                            symbolWeight: NSFont.Weight = .semibold,
                            symbolTintColor: NSColor = .white)
    {
        self.init(frame: .zero)
        self.symbolName = symbolName
        if let categoryColorName {
            dotColor = AppTheme.categoryNSColor(for: categoryColorName)
        }
        self.size = size
        self.symbolPointSize = symbolPointSize
        self.symbolWeight = symbolWeight
        self.symbolTintColor = symbolTintColor
        applyInitial()
    }

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
        applyInitial()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        applyInitial()
    }

    // MARK: - Setup

    private func setupView() {
        wantsLayer = true
        layer = CALayer()
        layer?.masksToBounds = true

        imageView.imageScaling = .scaleProportionallyDown
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentTintColor = symbolTintColor

        addSubview(imageView)

        // Center the image
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        // Size constraints for image; will be updated to `symbolPointSize`
        let w = imageView.widthAnchor.constraint(equalToConstant: symbolPointSize)
        let h = imageView.heightAnchor.constraint(equalToConstant: symbolPointSize)
        w.isActive = true
        h.isActive = true
        imageWidthConstraint = w
        imageHeightConstraint = h
    }

    private func applyInitial() {
        updateBackground()
        updateBorder()
        updateSymbolImage()
        imageView.contentTintColor = symbolTintColor
    }

    // MARK: - Updates

    private func updateBackground() {
        layer?.backgroundColor = dotColor.cgColor
        needsDisplay = true
    }

    private func updateBorder() {
        if let borderColor {
            layer?.borderColor = borderColor.cgColor
            layer?.borderWidth = borderWidth
        } else {
            layer?.borderWidth = 0
            layer?.borderColor = nil
        }
    }

    private func updateImageSizeConstraints() {
        imageWidthConstraint?.constant = symbolPointSize
        imageHeightConstraint?.constant = symbolPointSize
        invalidateIntrinsicContentSize()
        needsLayout = true
    }

    private func updateSymbolImage() {
        let config = NSImage.SymbolConfiguration(pointSize: symbolPointSize, weight: symbolWeight)
        let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)?
            .withSymbolConfiguration(config)
        imageView.image = image ?? NSImage(systemSymbolName: "questionmark", accessibilityDescription: nil)
    }

    // MARK: - Convenience

    /// Sets the dot color using an AppTheme category color name (e.g., "blue", "green").
    public func setCategoryColorName(_ name: String) {
        dotColor = AppTheme.categoryNSColor(for: name)
    }

    // MARK: - Layout & Sizing

    override public func layout() {
        super.layout()
        layer?.cornerRadius = bounds.height / 2
    }

    override public var intrinsicContentSize: NSSize {
        NSSize(width: size, height: size)
    }
}
