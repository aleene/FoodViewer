//
//  TagView.swift
//  TagListViewDemo
//
//  Created by Dongyuan Liu on 2015-05-09.
//  Copyright (c) 2015 Ela. All rights reserved.
//
import UIKit

/// Delegate protocol for the TagView object.
public protocol TagViewDelegate: AnyObject {
    /// Returns when the tagView is tapped and the tagView that was tapped.
    func didTapTagView(_ tagView: TagView)
    /// Returns when the remove button of the tagView was tapped
    func didTapRemoveButton(_ tagView: TagView)
    // Returns when a tagView is long pressed
    func didLongPressTagView(_ tagView: TagView)
}

open class TagView: UIView {
    
    private struct Constants {
        static let RemoveButtonWidth: CGFloat = 13.0
        /// Default maximum height = 150.0
        static let defaultCornerRadius: CGFloat = 5.0
        /// Default border width
        static let defaultBorderWidth: CGFloat = 0.5
        /// Default color and selected textColor
        static let defaultTextColor: UIColor = UIColor.white
        /// Default text font
        static let defaultTextFont: UIFont = UIFont.preferredFont(forTextStyle: .body)
        /// Default color, highlighted and selected backgroundColor, shadowColor
        static let defaultBackgroundColor = UIColor.systemBlue
        /// Default color and selected border Color
        static let defaultBorderColor: UIColor = .systemBlue
        /// Default padding add to top and bottom of tag wrt font height
        static let defaultVerticalPadding: CGFloat = 5.0
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
    
    @IBInspectable open dynamic var shadowColor = Constants.defaultBackgroundColor {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable open dynamic var textFont: UIFont = Constants.defaultTextFont {
        didSet {
            label?.font = textFont
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
    
    open var normalColorScheme = ColorScheme() {
        didSet {
            reloadStyles()
        }
    }
    
    open var selectedColorScheme = ColorScheme() {
        didSet {
            reloadStyles()
        }
    }
    
    open var removableColorScheme = ColorScheme() {
        didSet {
            setRemoveImageViewColor()
            reloadStyles()
        }
    }
    
    var state: TagViewState = .normal {
        didSet {
            switch state {
            case .normal:
                isHighlighted = false
                isSelected = false
            case .selected:
                isHighlighted = false
                isSelected = true
            case .removable:
                isHighlighted = true
                isSelected = false
            }
            reloadStyles()
        }
    }
    
    private func reloadStyles() {
        if isHighlighted {
            shadow.backgroundColor = removableColorScheme.backgroundColor
            label.textColor = removableColorScheme.textColor
            shadow.layer.borderColor = removableColorScheme.borderColor.cgColor
        }
        else if isSelected {
            shadow.backgroundColor = selectedColorScheme.backgroundColor
            label.textColor = selectedColorScheme.textColor
            shadow.layer.borderColor = selectedColorScheme.borderColor.cgColor
        }
        else {
            shadow.backgroundColor = normalColorScheme.backgroundColor
            label.textColor = normalColorScheme.textColor
            shadow.layer.borderColor = normalColorScheme.borderColor.cgColor
        }
    }

    fileprivate var isHighlighted: Bool = false {
        didSet {
            if isHighlighted != oldValue {
                reloadStyles()
            }
        }
    }
    
    var isSelected: Bool = false {
        didSet {
            if isSelected != oldValue {
                reloadStyles()
            }
        }
    }
    
    /// TagView delegate gives access to the didTagView(_ tagView: TagView) method.
    public weak var delegate: TagViewDelegate?
    
    private var tapGestureRecognizer: UITapGestureRecognizer!

    private var longPressGestureRecognizer: UILongPressGestureRecognizer!

    /// TagView's title.
    public var title = "" {
        didSet {
            label?.text = title
            setupView()
        }
    }
    
    /// function that responds to the Token's tapGestureRecognizer.
    @objc func didTapTagView(_ sender: UITapGestureRecognizer) {
        delegate?.didTapTagView(self)
    }
    
    /// function that responds to the Token's longPressGestureRecognizer.
    @objc func didLongPressTagView(_ sender: UILongPressGestureRecognizer) {
        delegate?.didLongPressTagView(self)
    }

    // MARK: remove button
    
    open var removeButtonIsEnabled = false {
        didSet {
            if removeButtonIsEnabled {
                let image = UIImage(named: "Clear")!
                // this is needed to adapt the color of the image
                //image = image.withRenderingMode(.alwaysTemplate)

                removeImageView.contentMode = .scaleAspectFit
                removeImageView.image = image

                removeImageViewWidthConstraint.constant = Constants.RemoveButtonWidth
                //setRemoveImageViewColor()
                tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TagView.removeButtonTapped(_:)))
                removeImageView.addGestureRecognizer(tapGestureRecognizer)
            } else {
                // make imageView to small to see
                removeImageViewWidthConstraint.constant = 0
            }
            removeImageView?.isHidden = !removeButtonIsEnabled
            // updateRightInsets()
        }
    }
    
    private func setRemoveImageViewColor() {
        if #available(iOS 13.0, *) {
            removeImageView?.tintColor = ColorScheme(text: .white, background: .systemFill, border: .systemFill).borderColor
        } else {
            removeImageView?.tintColor = ColorScheme(text: .white, background: .darkGray, border: .black).borderColor
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
        longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(TagView.didLongPressTagView(_:)))
        addGestureRecognizer(longPressGestureRecognizer)

    }
    
    func willDisappear() {
        if let validGestureRecognizers = self.gestureRecognizers {
            for gesture in validGestureRecognizers {
                if gesture is UILongPressGestureRecognizer {
                    self.removeGestureRecognizer(gesture)
                } else if gesture is UITapGestureRecognizer {
                    self.removeGestureRecognizer(gesture)
                }
            }
        }
        if let validGestureRecognizers = removeImageView?.gestureRecognizers {
            for gesture in validGestureRecognizers {
                if gesture is UITapGestureRecognizer {
                    removeImageView?.removeGestureRecognizer(gesture)
                }
            }
        }
        
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
            label.textColor = normalColorScheme.textColor
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
            shadow.backgroundColor = normalColorScheme.backgroundColor
            shadow.layer.shadowColor = normalColorScheme.backgroundColor.cgColor
            shadow.layer.shadowRadius = shadowRadius
            shadow.layer.shadowOffset = shadowOffset
            shadow.layer.shadowOpacity = shadowOpacity
            shadow.layer.masksToBounds = false
            shadow.layer.shadowPath = UIBezierPath(roundedRect: shadow.bounds, cornerRadius: self.cornerRadius).cgPath
        }
    }
    @IBOutlet weak var removeImageViewWidthConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var removeImageView: UIImageView!
    
    @objc func removeButtonTapped(_ sender: UIButton) {
        delegate?.didTapRemoveButton(self)
    }
    
    private func loadView() {
        let type = Swift.type(of: self)
        let bundle = Bundle(for: type)
        let nib = UINib(nibName: String(describing: type), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first! as! UIView
        view.frame = bounds
        view.backgroundColor = .clear
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}

