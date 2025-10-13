import AppKit

/// Reusable AppKit pill for tags and metadata chips.
/// - Features:
///   - Optional color dot (for category/color accent).
///   - Rounded background with subtle translucency from AppTheme.
///   - Truncating label for long text.
///   - Supports dynamic updates to text and color.
///   - Attempts to use the New York serif font if available.
/// - Usage:
///   let pill = PillView(text: "Design", colorName: "purple")
///   let pill = PillView(text: "128 pages")
public final class PillView: NSView {
    // Public configuration
    public var text: String {
        didSet { label.stringValue = text }
    }

    /// Optional AppTheme category color name (e.g., "blue", "green").
    /// If nil, no color dot is shown.
    public var colorName: String? {
        didSet { updateColorDot() }
    }

    /// Controls whether the colored dot should be shown when `colorName` is set.
    public var showsColorDot: Bool = true {
        didSet { updateColorDot() }
    }

    /// Background color for the pill. Defaults to AppTheme.pillBackgroundNSColor.
    public var backgroundColor: NSColor = AppTheme.pillBackgroundNSColor {
        didSet {
            if let layer = layer {
                layer.backgroundColor = backgroundColor.cgColor
            }
        }
    }

    /// Content insets for the pill interior.
    public var contentInsets: NSEdgeInsets = .init(
        top: 4,
        left: 8,
        bottom: 4,
        right: 8
    ) {
        didSet { updateInsets() }
    }

    /// Corner radius of the pill background.
    public var cornerRadius: CGFloat = 8 {
        didSet { layer?.cornerRadius = cornerRadius }
    }

    // Private UI
    private let stack = NSStackView()
    private let dotView = NSView()
    private let label: NSTextField

    // MARK: - Init

    public convenience init(
        text: String,
        colorName: String? = nil,
        showsColorDot: Bool = true,
        backgroundColor: NSColor? = nil
    ) {
        self.init(frame: .zero)
        self.text = text
        self.colorName = colorName
        self.showsColorDot = showsColorDot
        label.stringValue = text
        if let backgroundColor = backgroundColor {
            self.backgroundColor = backgroundColor
            layer?.backgroundColor = backgroundColor.cgColor
        }
        updateColorDot()
    }

    override public init(frame frameRect: NSRect) {
        text = ""
        colorName = nil
        label = NSTextField(labelWithString: "")

        super.init(frame: frameRect)
        setupView()
    }

    public required init?(coder: NSCoder) {
        text = ""
        colorName = nil
        label = NSTextField(labelWithString: "")

        super.init(coder: coder)
        setupView()
    }

    // MARK: - View Setup

    private func setupView() {
        wantsLayer = true
        layer?.masksToBounds = true
        layer?.cornerRadius = cornerRadius
        layer?.backgroundColor = backgroundColor.cgColor

        // Stack
        stack.orientation = .horizontal
        stack.alignment = .centerY
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        // Dot
        dotView.wantsLayer = true
        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.layer?.cornerRadius = 3

        // Label
        label.isEditable = false
        label.isBordered = false
        label.backgroundColor = .clear
        label.lineBreakMode = .byTruncatingTail
        label.textColor = AppTheme.textSecondaryNSColor
        label.font = preferredPillFont()

        // Layout
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: contentInsets.left
            ),
            stack.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -contentInsets.right
            ),
            stack.topAnchor.constraint(
                equalTo: topAnchor,
                constant: contentInsets.top
            ),
            stack.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -contentInsets.bottom
            ),
        ])

        // Content Hugging & Compression
        setContentHuggingPriority(.defaultHigh, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(
            .required,
            for: .horizontal
        )
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)

        // Add arranged subviews
        stack.addArrangedSubview(dotView)
        stack.addArrangedSubview(label)

        NSLayoutConstraint.activate([
            dotView.widthAnchor.constraint(equalToConstant: 6),
            dotView.heightAnchor.constraint(equalToConstant: 6),
        ])

        updateColorDot()
    }

    // MARK: - Appearance

    private func preferredPillFont() -> NSFont {
        return NSFont.systemFont(ofSize: 13, weight: .medium)
    }

    private func updateColorDot() {
        if let name = colorName, showsColorDot {
            dotView.isHidden = false
            dotView.layer?.backgroundColor =
                AppTheme.categoryNSColor(for: name).cgColor
        } else {
            dotView.isHidden = true
        }
    }

    private func updateInsets() {
        // Update constraints to reflect new insets
        for c in constraints {
            if c.firstItem as? NSView === stack
                || c.secondItem as? NSView === stack
            {
                removeConstraint(c)
            }
        }
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: contentInsets.left
            ),
            stack.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -contentInsets.right
            ),
            stack.topAnchor.constraint(
                equalTo: topAnchor,
                constant: contentInsets.top
            ),
            stack.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -contentInsets.bottom
            ),
        ])
        invalidateIntrinsicContentSize()
    }

    // MARK: - Public updates

    /// Update the pill text.
    public func setText(_ text: String) {
        self.text = text
    }

    /// Update the pill color by AppTheme category color name (e.g., "blue").
    /// Pass nil to hide the dot.
    public func setColorName(_ name: String?) {
        colorName = name
    }

    /// Toggle the dot visibility (only applies when `colorName != nil`).
    public func setShowsColorDot(_ shows: Bool) {
        showsColorDot = shows
    }

    /// Update appearance for theme changes
    public func updateAppearance() {
        // Update background color
        layer?.backgroundColor = AppTheme.pillBackgroundNSColor.cgColor

        // Update text color
        label.textColor = AppTheme.textSecondaryNSColor

        // Update dot color if present
        if let name = colorName, showsColorDot {
            dotView.layer?.backgroundColor = AppTheme.categoryNSColor(for: name).cgColor
        }
    }

    // MARK: - Sizing

    override public var intrinsicContentSize: NSSize {
        // Size to fit content plus insets, with a minimum height that matches comfortable touch targets.
        let fitting = stack.fittingSize
        let width = fitting.width + contentInsets.left + contentInsets.right
        let height = max(
            fitting.height + contentInsets.top + contentInsets.bottom,
            18
        )
        return NSSize(width: ceil(width), height: ceil(height))
    }

    override public func layout() {
        super.layout()
        // Ensure background covers bounds after layout changes
        layer?.cornerRadius = cornerRadius
    }
}
