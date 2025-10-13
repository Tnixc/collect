import AppKit

/// Reusable circular color dot with a centered SF Symbol.
/// - Provides a colored circular background and a system symbol tinted above it.
/// - Auto layout friendly: exposes intrinsicContentSize based on `size` (diameter).
/// - Dynamically updates when properties change.
public final class ColorDotIconView: NSView {
    /// SF Symbol name (e.g., "person.fill", "doc.text.fill").
    public var symbolName: String = "doc.text.fill" {
        didSet { updateSymbolImage() }
    }

    /// Symbol point size used to render the SF Symbol image.
    public var symbolPointSize: CGFloat = 18 {
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

    // MARK: - Private UI

    private let imageView = NSImageView()
    private var imageWidthConstraint: NSLayoutConstraint?
    private var imageHeightConstraint: NSLayoutConstraint?

    // MARK: - Init

    public convenience init(
        symbolName: String,
        categoryColorName _: String? = nil,
        size _: CGFloat = 20,
        symbolPointSize: CGFloat = 12,
        symbolWeight: NSFont.Weight = .semibold,
        symbolTintColor: NSColor = .white
    ) {
        self.init(frame: .zero)
        self.symbolName = symbolName
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
        let w = imageView.widthAnchor.constraint(
            equalToConstant: symbolPointSize
        )
        let h = imageView.heightAnchor.constraint(
            equalToConstant: symbolPointSize
        )
        w.isActive = true
        h.isActive = true
        imageWidthConstraint = w
        imageHeightConstraint = h
    }

    private func applyInitial() {
        updateSymbolImage()
        imageView.contentTintColor = symbolTintColor
    }

    // MARK: - Updates

    private func updateImageSizeConstraints() {
        imageWidthConstraint?.constant = symbolPointSize
        imageHeightConstraint?.constant = symbolPointSize
        invalidateIntrinsicContentSize()
        needsLayout = true
    }

    private func updateSymbolImage() {
        let config = NSImage.SymbolConfiguration(
            pointSize: symbolPointSize,
            weight: symbolWeight
        )
        let image = NSImage(
            systemSymbolName: symbolName,
            accessibilityDescription: nil
        )?
            .withSymbolConfiguration(config)
        imageView.image =
            image
                ?? NSImage(
                    systemSymbolName: "questionmark",
                    accessibilityDescription: nil
                )
    }

    // MARK: - Layout & Sizing

    override public func layout() {
        super.layout()
        layer?.cornerRadius = bounds.height / 2
    }
}
