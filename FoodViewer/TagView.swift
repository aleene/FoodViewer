//
//  TagView.swift
//  TagListViewDemo
//
//  Created by Dongyuan Liu on 2015-05-09.
//  Copyright (c) 2015 Ela. All rights reserved.
//
import UIKit

/// Delegate protocol for the TagView object.
public protocol TagViewDelegate: class {
    /// Returns when the tagView is tapped and the tagView that was tapped.
    func didTapTagView(_ tagView: TagView)
    /// Returns when the remove button of the tagView was tapped
    func didTapRemoveButton(_ tagView: TagView)
}

open class TagView: UIView {
    
    private struct Constants {
        static let RemoveButtonWidth: CGFloat = 13.0
        /// Default maximum height = 150.0
        static let defaultCornerRadius: CGFloat = 0.0
        /// Default border width
        static let defaultBorderWidth: CGFloat = 0.0
        /// Default color and selected textColor
        static let defaultTextColor: UIColor = UIColor.white
        /// Default text font
        static let defaultTextFont: UIFont = UIFont.systemFont(ofSize: 12)
        /// Default color, highlighted and selected backgroundColor, shadowColor
        static let defaultBackgroundColor = UIColor.blue
        /// Default color and selected border Color
        static let defaultBorderColor: UIColor = .blue
        /// Default padding add to top and bottom of tag wrt font height
        static let defaultVerticalPadding: CGFloat = 2.0
        /// Default padding between view objects
        static let defaultHorizontalPadding: CGFloat = 5.0
        
        /// Default offset for shadow
        static let defaultShadowOffset = CGSize.init(width: 1.0, height: 1.0)
        /// Default opacity for shadow
        static let defaultShadowOpacity: Float = 0.0
    }

    @IBInspectable open var cornerRadius = Constants.defaultCornerRadius {
        didSet {
            shadow?.layer.cornerRadius = cornerRadius
            shadow?.layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable open var borderWidth = Constants.defaultBorderWidth {
        didSet {
            shadow?.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable open var borderColor = Constants.defaultBorderColor {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable open var textColor = Constants.defaultTextColor {
        didSet {
            reloadStyles()
        }
    }
    @IBInspectable open var selectedTextColor = Constants.defaultTextColor {
        didSet {
            reloadStyles()
        }
    }
    @IBInspectable open var highlightedTextColor = Constants.defaultTextColor {
        didSet {
            reloadStyles()
        }
    }

    @IBInspectable open var verticalPadding = Constants.defaultVerticalPadding {
        didSet {
            topLayoutConstraint?.constant = verticalPadding
            bottomLayOutConstraint?.constant = verticalPadding
            // titleEdgeInsets.top = paddingY
            // titleEdgeInsets.bottom = paddingY
        }
    }
    @IBInspectable open var horizontalPadding = Constants.defaultHorizontalPadding {
        didSet {
            leadingLayOutConstraint?.constant = horizontalPadding
            // titleEdgeInsets.left = paddingX
            updateRightInsets()
        }
    }
    // beware that this UIView also has an attribute backgroundColor
    @IBInspectable open var tagBackgroundColor = Constants.defaultBackgroundColor {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable open var tagHighlightedBackgroundColor = Constants.defaultBackgroundColor {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable open var highlightedBorderColor = Constants.defaultBackgroundColor {
        didSet {
            reloadStyles()
        }
    }

    
    @IBInspectable open var selectedBorderColor = Constants.defaultBackgroundColor {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable open var tagSelectedBackgroundColor = Constants.defaultBackgroundColor {
        didSet {
            reloadStyles()
        }
    }
    
    var textFont: UIFont = Constants.defaultTextFont {
        didSet {
            label?.font = textFont
        }
    }
    
    
    @IBInspectable open dynamic var shadowColor = Constants.defaultBackgroundColor {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable open dynamic var shadowRadius = Constants.defaultCornerRadius {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable open dynamic var shadowOffset = Constants.defaultShadowOffset {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable open dynamic var shadowOpacity = Constants.defaultShadowOpacity {
        didSet {
            reloadStyles()
        }
    }

    private func reloadStyles() {
        if isHighlighted {
            shadow.backgroundColor = tagHighlightedBackgroundColor
            label.textColor = highlightedTextColor
            shadow.layer.borderColor = highlightedBorderColor.cgColor
                    }
        else if isSelected {
            shadow.backgroundColor = tagSelectedBackgroundColor
            label.textColor = selectedTextColor
            shadow.layer.borderColor = selectedBorderColor.cgColor
        }
        else {
            shadow.backgroundColor = tagBackgroundColor
            label.textColor = textColor
            shadow.layer.borderColor = borderColor.cgColor
        }
    }
    
    open var isHighlighted: Bool = false {
        didSet {
            if isHighlighted != oldValue {
                reloadStyles()
            }
        }
    }
    
    open var isSelected: Bool = false {
        didSet {
            if isSelected != oldValue {
                reloadStyles()
            }
        }
    }
    
    
    /// TagView delegate gives access to the didTagView(_ tagView: TagView) method.
    public weak var delegate: TagViewDelegate?
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    /// TagView's title.
    public var title = "" {
        didSet {
            label?.text = title
            setupView()
        }
    }

    /// function that responds to the Token's tapGestureRecognizer.
    func didTapTagView(_ sender: UITapGestureRecognizer) {
        delegate?.didTapTagView(self)
    }

    // MARK: remove button
    
    open var removeButtonIsEnabled = false {
        didSet {
            if removeButtonIsEnabled {
                removeButtonWidthConstraint.constant = Constants.RemoveButtonWidth
                var currentImage = removeButton.currentImage
                currentImage = currentImage!.withRenderingMode(.alwaysTemplate)
                removeButton.setImage(currentImage, for: .normal)
                removeButton.tintColor = textColor
                tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TagView.removeButtonTapped(_:)))
                removeButton.addGestureRecognizer(tapGestureRecognizer)

            } else {
                removeButtonWidthConstraint.constant = 0
            }
            removeButton.isEnabled = removeButtonIsEnabled
            // updateRightInsets()
        }
    }
    
    /// Handles Tap (TouchUpInside)
    // open var onTap: ((TagView) -> Void)?
    // open var onLongPress: ((TagView) -> Void)?
    
    // MARK: - init
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    public init(title: String) {
        self.title = title
        super.init(frame: CGRect.zero)
        loadView()
        setupView()
    }
    
    private func setupView() {
        frame.size = intrinsicContentSize

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TagView.didTapTagView(_:)))
        addGestureRecognizer(tapGestureRecognizer)

    }
    
    // MARK: - layout
    
    override open var intrinsicContentSize: CGSize {
        /// Returns the intrinsicContentSize. The preferred size of the view.
        var size = label?.intrinsicContentSize
        size?.height = textFont.pointSize + verticalPadding * 2
        size?.width += horizontalPadding * 2
        if removeButtonIsEnabled {
            size?.width += Constants.RemoveButtonWidth // + paddingX
        }

        return size != nil ? size! : CGSize.init(width: 20, height: 5)
    }
    
    private func updateRightInsets() {
        if removeButtonIsEnabled {
            trailingLayOutConstraint?.constant = horizontalPadding  + Constants.RemoveButtonWidth // + paddingX
            // titleEdgeInsets.right = paddingX  + removeButtonIconSize + paddingX
        }
        else {
            //titleEdgeInsets.right = paddingX
            trailingLayOutConstraint?.constant = horizontalPadding
        }
    }
    
    @IBOutlet weak var label: UILabel! {
        didSet {
            label.text = title
            label.textAlignment = .left
            label.textColor = textColor
            label.font = textFont
        }
    }
    
    @IBOutlet weak var bottomLayOutConstraint: NSLayoutConstraint! {
        didSet {
            bottomLayOutConstraint.constant = verticalPadding
        }
    }
    @IBOutlet weak var leadingLayOutConstraint: NSLayoutConstraint! {
        didSet {
            leadingLayOutConstraint.constant = horizontalPadding
        }
    }
    @IBOutlet weak var trailingLayOutConstraint: NSLayoutConstraint! {
        didSet {
            updateRightInsets()
        }
    }
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint! {
        didSet {
            topLayoutConstraint.constant = verticalPadding
        }
    }
    
    @IBOutlet weak var shadow: UIView! {
        didSet {
            shadow.backgroundColor = tagBackgroundColor
            shadow.layer.shadowColor = shadowColor.cgColor
            shadow.layer.shadowRadius = shadowRadius
            shadow.layer.shadowOffset = shadowOffset
            shadow.layer.shadowOpacity = shadowOpacity
            shadow.layer.masksToBounds = false
            shadow.layer.shadowPath = UIBezierPath(roundedRect: shadow.bounds, cornerRadius: self.cornerRadius).cgPath
        }
    }
    @IBOutlet weak var removeButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var removeButton: UIButton!
    
    @IBAction func removeButtonTapped(_ sender: UIButton) {
        delegate?.didTapRemoveButton(self)
    }
    
    private func loadView() {
        let type = type(of: self)
        let bundle = Bundle(for: type)
        let nib = UINib(nibName: String(describing: type), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first! as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

    }
}

