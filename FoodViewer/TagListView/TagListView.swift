//
//  TagListView.swift
//
//  Originally Created by Dongyuan Liu on 2015-05-09.
//  Copyright (c) 2015 Ela. All rights reserved.
//
//  Adapted by Arnaud Leene 2016-2018

import UIKit

@IBDesignable
open class TagListView: UIView, TagViewDelegate, BackspaceTextFieldDelegate {
        
    open var delegate: TagListViewDelegate? = nil
    
    // The datasource indicates where TagListView can find the titles for the tags.
    // If the delegate uses multiple TagListViews, an additional TagListView identifier is required
    // This is set by the variable tag
    
    open var datasource: TagListViewDataSource? = nil
    
    //MARK: - Default values
    
    private struct Constants {
        /// Default maximum height = 150.0
        static let defaultMaxHeight: CGFloat = 150.0
        /// Default minimum input width = 80.0
        static let defaultMinInputWidth: CGFloat = 200.0
        /// Default tag height
        static let defaultTagHeight: CGFloat = 30.0
        
        
        static let defaultCornerRadius: CGFloat = 5.0
        /// Default border width
        static let defaultBorderWidth: CGFloat = 0.5
        /// Default color and selected textColor
        static let defaultTextColor: UIColor = UIColor.white
        /// Default color and selected textColor
        //static let defaultTextInputColor: UIColor = .
        /// Default text font
        static let defaultTextFont: UIFont = UIFont.preferredFont(forTextStyle: .body)
        /// Default color, highlighted and selected backgroundColor, shadowColor
        static let defaultBackgroundColor: UIColor = UIColor.systemBlue
        /// Default color and selected border Color
        static let defaultBorderColor: UIColor = UIColor.systemBlue
        /// Default padding add to top and bottom of tag wrt font height
        static let defaultVerticalPadding: CGFloat = 5.0
        /// Default padding between view objects
        static let defaultHorizontalPadding: CGFloat = 5.0
        /// margin between clear button and trailing edge
        static let defaultHorizontalClearPadding: CGFloat = 8.0
        /// Default margin between tag rows
        static let defaultVerticalMargin: CGFloat = 0.0
        /// Default margin outside a tag row
        static let defaultHorizontalMargin: CGFloat = 0.0
        /// Default offset for shadow
        static let defaultShadowOffset: CGSize = CGSize.init(width: -20.0, height: 0.0)
        /// Default opacity for shadow
        static let defaultshadowOpacity: Float = 0
        /// Default image used for the Clear and Remove button, similar to the one used in UITextField
        static let clearRemoveImage: UIImage? = UIImage.init(named: "Clear")
    }
    
    // MARK: - Inspectable Variables
    
    /// To label text color.
    @IBInspectable open dynamic var prefixLabelTextColor = Constants.defaultTextColor {
        didSet {
            if prefixLabel == nil {
                setupPrefixLabel()
            }
            prefixLabel?.textColor = prefixLabelTextColor
        }
    }
    
    /// To label text color.
    @IBInspectable open dynamic var prefixLabelBackgroundColor = Constants.defaultBackgroundColor {
        didSet {
            if prefixLabel == nil {
                setupPrefixLabel()
            }
            prefixLabel?.backgroundColor = prefixLabelBackgroundColor
        }
    }
    
    /// To label text.
    @IBInspectable open dynamic var prefixLabelText: String? = nil {
        didSet {
            if prefixLabelText != nil {
                setupPrefixLabel()
            }
            prefixLabel?.text = prefixLabelText
            if prefixLabelText != oldValue {
                rearrangeViews(true)
            }
        }
    }
    /// Input textView text color.
    @IBInspectable open dynamic var inputTextViewTextColor = UIColor.black {
        didSet {
            if #available(iOS 13.0, *) {
                inputTextField.textColor = .label
            }
        }
    }
    
    @IBInspectable open dynamic var textColor = Constants.defaultTextColor {
        didSet {
            normalColorScheme.textColor = textColor
        }
    }
    
    @IBInspectable open dynamic var selectedTextColor = Constants.defaultTextColor {
        didSet {
            selectedColorScheme.textColor = selectedTextColor
        }
    }
    
    @IBInspectable open dynamic var highlightedTextColor = Constants.defaultTextColor {
        didSet {
            removableColorScheme.textColor = highlightedTextColor
        }
    }
    
    @IBInspectable open dynamic var tagBackgroundColor = Constants.defaultBackgroundColor {
        didSet {
            normalColorScheme.backgroundColor = tagBackgroundColor
        }
    }
    
    @IBInspectable open dynamic var tagHighlightedBackgroundColor = Constants.defaultBackgroundColor {
        didSet {
            removableColorScheme.backgroundColor = tagHighlightedBackgroundColor
        }
    }
    
    @IBInspectable open dynamic var tagSelectedBackgroundColor = Constants.defaultBackgroundColor {
        didSet {
            selectedColorScheme.backgroundColor = tagSelectedBackgroundColor
        }
    }
    
    @IBInspectable open dynamic var cornerRadius = Constants.defaultCornerRadius {
        didSet {
            // requires rearranging the tagViews.
            if cornerRadius != oldValue {
                rearrangeViews(true)
            }
        }
    }
    
    @IBInspectable open dynamic var borderWidth = Constants.defaultBorderWidth {
        didSet {
            tagViews.forEach { $0.borderWidth = borderWidth }
        }
    }
    
    @IBInspectable open dynamic var borderColor = Constants.defaultBorderColor {
        didSet {
            normalColorScheme.borderColor = borderColor
        }
    }
    
    @IBInspectable open dynamic var selectedBorderColor = Constants.defaultBorderColor {
        didSet {
            selectedColorScheme.borderColor = selectedBorderColor
        }
    }
    
    @IBInspectable open dynamic var highlightedBorderColor = Constants.defaultBorderColor {
        didSet {
            removableColorScheme.borderColor = highlightedBorderColor
        }
    }
    
    
    open var normalColorScheme = ColorScheme.init() {
        didSet {
            tagViews.forEach { $0.normalColorScheme = normalColorScheme }
        }
    }
    
    open var selectedColorScheme = ColorScheme.init() {
        didSet {
            tagViews.forEach { $0.selectedColorScheme = selectedColorScheme }
        }
    }
    
    open var removableColorScheme = ColorScheme.init() {
        didSet {
            setClearAllImageColor()
            tagViews.forEach { $0.removableColorScheme = removableColorScheme }
        }
    }
    
    @IBInspectable open dynamic var verticalPadding = Constants.defaultVerticalPadding {
        didSet {
            if verticalPadding != oldValue {
                rearrangeViews(true)
            }
        }
    }
    @IBInspectable open dynamic var horizontalPadding = Constants.defaultHorizontalPadding {
        didSet {
            if horizontalMargin != oldValue {
                rearrangeViews(true)
            }
        }
    }
    @IBInspectable open dynamic var verticalMargin = Constants.defaultVerticalMargin {
        didSet {
            if verticalMargin != oldValue {
                rearrangeViews(true)
            }
        }
    }
    @IBInspectable open dynamic var horizontalMargin = Constants.defaultHorizontalMargin {
        didSet {
            if horizontalMargin != oldValue {
                rearrangeViews(true)
            }
        }
    }
    
    @objc public enum Alignment: Int {
        case left
        case center
        case right
    }
    @IBInspectable open var alignment: Alignment = .center {
        didSet {
            if alignment != oldValue {
                rearrangeViews(true)
            }
        }
    }
    
    @IBInspectable open dynamic var shadowColor = Constants.defaultBackgroundColor {
        didSet {
            tagViews.forEach { $0.shadowColor = shadowColor }
        }
    }
    
    @IBInspectable open dynamic var shadowRadius = Constants.defaultCornerRadius {
        didSet {
            tagViews.forEach { $0.shadowRadius = shadowRadius }
        }
    }
    
    @IBInspectable open dynamic var shadowOffset = Constants.defaultShadowOffset {
        didSet {
            tagViews.forEach { $0.shadowOffset = shadowOffset }
        }
    }
    
    @IBInspectable open dynamic var shadowOpacity = Constants.defaultshadowOpacity {
        didSet {
            tagViews.forEach { $0.shadowOpacity = shadowOpacity }
        }
    }
    
    @IBInspectable open dynamic var textFont = Constants.defaultTextFont {
        didSet {
            if textFont != oldValue {
                rearrangeViews(true)
            }
        }
    }
    
    @IBInspectable open dynamic var clearRemoveImage: UIImage? = Constants.clearRemoveImage
    
    // MARK: - Public? variables
    
    /// Input textView accessibility label.
    public var inputTextViewAccessibilityLabel: String! {
        didSet {
            inputTextField.accessibilityLabel = inputTextViewAccessibilityLabel
        }
    }
    
    // MARK: - Private
    
    /// TagListView's maximum height value.
    private var maxHeight: CGFloat = Constants.defaultMaxHeight
    
    /// TagListView's minimum input text width.
    private var minInputWidth: CGFloat = Constants.defaultMinInputWidth
    
    /// Keyboard type inital value .default.
    public var inputTextViewKeyboardType: UIKeyboardType = .default
    
    /// Keyboard appearance initial value .default.
    public var keyboardAppearance: UIKeyboardAppearance = .default
    
    /// Autocorrection type for textView initial value .no
    public var autocorrectionType: UITextAutocorrectionType = .no {
        didSet {
            inputTextField.autocorrectionType = autocorrectionType
        }
    }
    /// Autocapitalization type for textView inital value .sentences
    public var autocapitalizationType: UITextAutocapitalizationType = .sentences {
        didSet {
            inputTextField.autocapitalizationType = autocapitalizationType
        }
    }
    /// Input accessory view for textView.
    public var inputTextViewAccessoryView: UIView? {
        didSet {
            inputTextField.inputAccessoryView = inputTextViewAccessoryView
        }
    }
    
    
    /// - Returns: `Bool` value which is true if the TagListView is the first responder.
    override open var isFirstResponder: Bool {
        return super.isFirstResponder
    }
    
    // MARK: - initializers
    
    /// Initializes a TagListView with a `CGRect` frame within it's superview.
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initSetup()
    }
    
    /// Initializer used by the storyboard to initialize a TagListView.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSetup()
    }
    
    /// TagListView override of UIView's awakeFromNib() function. Calls super.awakeFromNib() and then self.setup().
    override open func awakeFromNib() {
        super.awakeFromNib()
        initSetup()
    }
    
    private var originalHeight: CGFloat = 0.0
    
    private func initSetup() {
        originalHeight = frame.height
        // addSubview(scrollView)
        reloadData(clearAll:true)
    }
    
    /// If the the delegate contains multiple TagListViews, it needs to identify each one
    /// You can do this with the tag variable.
    /// Note that default is tag == 0
    override open var tag: Int {
        didSet {
            reloadData(clearAll:true)
        }
    }
    
    // MARK: - First Responder Functions
    
    /// Resigns first responder.
    override open func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        return inputTextField.resignFirstResponder()
    }
    
    /// TagListView calls self.layoutTagsAndInputWithFrameAdjustment(true) and self.inputTextViewBecomeFirstResponder()
    /// - Returns: Always returns `true`
    override open func becomeFirstResponder() -> Bool {
        rearrangeViews(true)
        inputTextViewBecomeFirstResponder()
        return true
    }
    
    fileprivate func setCursorVisibility() {
        let highlightedTagViews = tagViews.filter { $0.state == .removable }
        if highlightedTagViews.count == 0 {
            inputTextViewBecomeFirstResponder()
        } else {
            invisibleTextField.becomeFirstResponder()
        }
    }
    
    private func inputTextViewBecomeFirstResponder() {
        guard !inputTextField.isFirstResponder else { return }
        inputTextField.becomeFirstResponder()
        // delegate?.tagListViewDidBeginEditing(self)
    }
    
    // MARK: - The Views
    
    // Prefix label, is only created when needed
    // It is shown in front of all tags
    
    private var prefixLabel: UILabel? = nil
    
    private func setupPrefixLabel() {
        prefixLabel = UILabel(frame: CGRect.zero)
        prefixLabel?.textColor = prefixLabelTextColor
        prefixLabel?.backgroundColor = prefixLabelBackgroundColor
        prefixLabel?.font = textFont
        prefixLabel?.text = prefixLabelText
        prefixLabel?.isHidden = false
    }
    
    // This textView has no size and is only to intervene for deletion
    
    private lazy var invisibleTextField: BackspaceTextField = {
        let invisibleTextField = BackspaceTextField(frame: CGRect.zero)
        invisibleTextField.autocorrectionType = self.autocorrectionType
        invisibleTextField.autocapitalizationType = self.autocapitalizationType
        invisibleTextField.backspaceDelegate = self
        return invisibleTextField
    }()
    
    // The TextView that allows the user to enter a new tag
    
    fileprivate lazy var inputTextField: UITextField = {
        let inputTextField = BackspaceTextField()
        inputTextField.keyboardType = self.inputTextViewKeyboardType
        if #available(iOS 13.0, *) {
            inputTextField.textColor = .label
            inputTextField.backgroundColor = .secondarySystemBackground
        } else {
            inputTextField.textColor = .black
            inputTextField.backgroundColor = .lightGray
        } // self.removableColorScheme.textColor
        inputTextField.font = self.textFont
        inputTextField.autocorrectionType = self.autocorrectionType
        inputTextField.autocapitalizationType = self.autocapitalizationType
        inputTextField.tintColor = .systemGray
        // inputTextView.isScrollEnabled = false
        // inputTextView.textContainer.lineBreakMode = .byWordWrapping
        inputTextField.delegate = self
        inputTextField.backspaceDelegate = self
        // TODO: - Add placeholder to BackspaceTextView and set it here
        inputTextField.inputAccessoryView = self.inputTextViewAccessoryView
        inputTextField.accessibilityLabel = self.inputTextViewAccessibilityLabel
        inputTextField.textAlignment = .left
        //inputTextField.layer.backgroundColor = UIColor.groupTableViewBackground.cgColor
        inputTextField.layer.cornerRadius = 5
        inputTextField.layer.borderColor = UIColor.darkGray.cgColor
        inputTextField.layer.borderWidth = self.borderWidth
        inputTextField.clipsToBounds = true

        return inputTextField
    }()
    
    // The label shown when the TagLisView is in collapsed state
    
    private lazy var collapsedLabel: UILabel = {
        let collapsedLabel = UILabel()
        collapsedLabel.font = self.textFont
        collapsedLabel.text = self.datasource?.tagListViewCollapsedText(self) ?? "Not setup"
        collapsedLabel.textColor = .green //Constants.defaultTextInputColor
        collapsedLabel.backgroundColor = .clear
        collapsedLabel.minimumScaleFactor = 5.0 / collapsedLabel.font.pointSize
        collapsedLabel.adjustsFontSizeToFitWidth = true
        return collapsedLabel
    }()
    
    private lazy var tagView: TagView = {
        let tagView = TagView(title: "")
        tagView.delegate = self
        tagView.normalColorScheme = self.normalColorScheme
        tagView.selectedColorScheme = self.selectedColorScheme
        tagView.removableColorScheme = self.removableColorScheme
        tagView.cornerRadius = self.cornerRadius
        tagView.borderWidth = self.borderWidth
        tagView.horizontalPadding = self.horizontalPadding
        tagView.verticalPadding = self.verticalPadding
        tagView.textFont = self.textFont
        tagView.removeButtonIsEnabled = false
        tagView.shadowColor = self.shadowColor
        tagView.shadowOpacity = self.shadowOpacity
        tagView.shadowRadius = self.shadowRadius
        tagView.shadowOffset = self.shadowOffset

        return tagView
    }()
    
    private struct Clear {
        static let ImageSize: CGFloat = 14.0
        static let ViewSize: CGFloat = 22.0
    }
    
    private lazy var clearView: UIView = {
        
        var image = UIImage(named: "Clear")!
        // this is needed to adapt the color of the image to
       // image = image.withRenderingMode(.alwaysTemplate)
        
        var clearImageView = UIImageView()
        if Clear.ViewSize > Clear.ImageSize {
            clearImageView = UIImageView.init(frame: CGRect.init(x: (Clear.ViewSize - Clear.ImageSize) / 2.0,
                                                                 y: (Clear.ViewSize - Clear.ImageSize) / 2.0,
                                                                 width: Clear.ImageSize,
                                                                 height: Clear.ImageSize))
        } else {
            assert(true, "ImageView can not be larger than Image")
        }
        clearImageView.contentMode = .scaleAspectFit
        clearImageView.image = image
        //clearImageView.tintColor = self.removableColorScheme.borderColor
        
        // put the image in another view in order to have a margin around the image
        let clearView = UIView(frame: CGRect.init(x: 0, y: 0, width: Clear.ViewSize, height: Clear.ViewSize))
        
        clearView.addSubview(clearImageView)
        
        
        return clearView
    }()
    
    private func setClearAllImageColor() {
        clearView.subviews.forEach { $0.tintColor = self.removableColorScheme.borderColor }
    }
    
    fileprivate func unhighlightAllTags() {
        for tagView in tagViews {
            tagView.state = .normal
        }
        setCursorVisibility()
    }
    
    // MARK: - Private
    
    /*private lazy var scrollView: UIScrollView = {
     let scrollView = UIScrollView(
     frame: CGRect(
     x: 0.0,
     y: 0.0,
     width: self.frame.width,
     height: self.frame.height
     )
     )
     scrollView.scrollsToTop = false
     scrollView.contentSize = CGSize(
     width: self.frame.width - self.horizontalPadding * 2,
     height: self.frame.height - self.verticalPadding * 2
     )
     scrollView.contentInset = UIEdgeInsets(
     top: self.verticalPadding,
     left: self.horizontalPadding,
     bottom: self.verticalPadding,
     right: self.horizontalPadding
     )
     scrollView.autoresizingMask = [
     UIViewAutoresizing.flexibleHeight,
     UIViewAutoresizing.flexibleWidth
     ]
     return scrollView
     }()
     */
    
    
    private var tagViews: [TagView] = []
    
    open func tagView(_ tagView: TagView, at index: Int) {
        if index > 0 && index < tagViews.count - 1 {
            tagViews[index] = tagView
        }
    }
//
// MARK: - Layout functions
//
    private(set) var tagBackgroundViews: [UIView] = []
    // private(set) var rowViews: [UIView] = []
    private(set) var tagViewHeight: CGFloat = 0
    private(set) var rows = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    private var hasTags: Bool {
        guard datasource != nil else { return false }
        return datasource!.numberOfTagsIn(self) > 0
    }
        
    // Reload's the TagListView's data and layout it's views.
    public func reloadData(clearAll: Bool) {
        guard datasource?.numberOfTagsIn(self) != nil else { return }
        
        // TODO what should be cleared when?
        if clearAll {
            clearTagListView()
        } else {
            tagViews.forEach { $0.removeFromSuperview() }
            tagViews = []
        }
        
        // Setup the tagView array and load the data here
        for index in 0..<datasource!.numberOfTagsIn(self) {
            tagView = TagView(title: datasource?.tagListView(self, titleForTagAt: index) ?? "Default Title" )
            tagView.delegate = self
            tagView.tag = index
            tagView.removableColorScheme = removableColorScheme
            tagView.selectedColorScheme = selectedColorScheme
            
            if let scheme = datasource?.tagListView(self, colorSchemeForTagAt: index) { tagView.normalColorScheme = scheme
            } else {
                tagView.normalColorScheme = normalColorScheme

            }
            // If it is allowed to delete tags,
            // is it also allowed to delete this specific tag?
            if delegate != nil,
                delegate!.tagListViewCanDeleteTags(self) {
                tagView.state = .removable
            } else {
                tagView.state = .normal
            }

            tagView.borderWidth = self.borderWidth
            if delegate?.tagListView(self, willDisplay: tagView, at: index) != nil {
                if let adaptedTagView = delegate!.tagListView(self, willDisplay: tagView, at: index) {
                    tagViews.append(adaptedTagView)
                } else {
                    tagViews.append(tagView)
                }
            } else {
                tagViews.append(tagView)
            }
            
        }
        // Layout all the new TagViews
        rearrangeViews(true)
    }

    /// Remove all tags and reset clear button
    private func clearTagListView() {
        clearUncollapsedView()
        tagViews = []
    }
    
    /// Remove all Views which are part of the uncollapsed state except the prefix
    private func clearUncollapsedView() {
        // TODO: is this OK?
        tagViews.forEach { $0.removeFromSuperview() }
        inputTextField.removeFromSuperview()
        invisibleTextField.removeFromSuperview()
        // rowViews.removeAll(keepingCapacity: true)
        clearView.removeFromSuperview()
    }
    
    fileprivate func rearrangeViews(_ shouldAdjustFrame: Bool) {
        
        clearUncollapsedView()
        
        let inputViewShouldBecomeFirstResponder = inputTextField.isFirstResponder
        //scrollView.subviews.forEach { $0.removeFromSuperview() }
        //scrollView.isHidden = false
        
        if tapGestureRecognizer != nil {
            removeGestureRecognizer(tapGestureRecognizer!)
            tapGestureRecognizer = nil
        }
        
        // startpoint of layout taking in account the margins
        var currentX: CGFloat = Constants.defaultHorizontalMargin
        var currentY: CGFloat = Constants.defaultVerticalMargin
        
        // Add the possibility to intercept a backspace for last tag removal
        if delegate != nil,
            delegate!.tagListViewCanDeleteTags(self) {
            addSubview(invisibleTextField)
        }
        
        // Add the prefix Label
        
        if prefixLabelText != nil {
            layoutPrefixLabel(origin: CGPoint.zero, currentX: &currentX)
        }

        // print("after Prefix", currentY, frame.height)

        layoutTagViewsWith(currentX: &currentX, currentY: &currentY)
        
        // print("after tagViews", currentY, frame.height)

        if delegate != nil,
            delegate!.tagListViewCanAddTags(self) {
            layoutInputTextViewWith(currentX: &currentX, currentY: &currentY, clearInput: shouldAdjustFrame)
        }

        // print("after Input", currentY, frame.height)
        
        if shouldAdjustFrame {
            adjustHeightFor(currentY: currentY)
        }
        // print("after adjustHeight", currentY, frame.height)

        if delegate != nil,
            delegate!.tagListViewCanDeleteTags(self),
            hasTags {
            layoutClearView()
        }
        
        // print("after clearView", currentY, frame.height)

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TagListView.clearOnTap(_:)))
        if tapGestureRecognizer != nil {
            clearView.addGestureRecognizer(tapGestureRecognizer!)
        }
        
        if inputViewShouldBecomeFirstResponder {
            inputTextViewBecomeFirstResponder()
        } else {
            // focusInputTextFIeld(currentX: &currentX, currentY: &currentY)
        }
        invalidateIntrinsicContentSize()
        // print("frame used", currentY, frame.height)
    }
    
    
    private func layoutCollapsedLabel() {
        
        // remove all the views from TagListView
        clearUncollapsedView()
        
        /*
         // reset the height of the TagListView to the original height
         var collapsedFrame = self.frame
         collapsedFrame.size.height = textFont.pointSize + 2 * verticalMargin
         frame = collapsedFrame
         adjustHeightFor(currentY: 0.0)
         
         //
         */
        var currentX: CGFloat = 0.0
        
        if prefixLabelText != nil {
            layoutPrefixLabel(origin: CGPoint(x: Constants.defaultHorizontalMargin, y: Constants.defaultVerticalMargin), currentX: &currentX)
        }
        
        collapsedLabel.frame = CGRect(
            x: currentX,
            y: 0.0,
            // the label covers the whole view after any prefix label
            width: frame.size.width - currentX - Constants.defaultHorizontalMargin,
            height: frame.height
        )
        addSubview(collapsedLabel)
        
        // tapping on the collapsedLabel uncollapses it
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TagListView.uncollapseOnTap(_:)))
        addGestureRecognizer(tapGestureRecognizer!)
    }
    
    private func layoutPrefixLabel(origin: CGPoint, currentX: inout CGFloat) {
        guard prefixLabel != nil else { return }
        
        prefixLabel!.removeFromSuperview()
        
        // Define the prefix label frame
        prefixLabel!.frame.origin.x = currentX
        prefixLabel!.frame.origin.y = verticalPadding
        // the width will be determined by the text in the label
        prefixLabel!.frame.size.height = prefixLabel!.font.pointSize + Constants.defaultVerticalPadding * 2
        
        prefixLabel!.sizeToFit()
        
        addSubview(prefixLabel!)
        
        // if the label is visible add some padding
        // and define the horizontal point for the next view
        currentX += prefixLabel!.isHidden ? 0.0 : prefixLabel!.frame.width + Constants.defaultHorizontalPadding
    }
    
    /// - Returns: the input text from the textView.
    //public var inputText: String {
    //    return inputTextView.text ?? ""
    //}
    
    private func layoutTagViewsWith(currentX: inout CGFloat, currentY: inout CGFloat) {
        
        var currentRow = 0
        // var currentRowView: UIView!
        var currentRowTagCount = 0
        var rowWidth = CGFloat(0)
        // var startedNewRow = false
        // var currentRowWidth: CGFloat = 0
        // print("TagListView frame", frame.size, "super", superview?.frame.size)
        tagViewHeight = textFont.pointSize + verticalPadding * 2
        // are there any tags?
        guard tagViews.count > 0 else { return }
        
        // calculate the rowWidth available for tags
        if delegate != nil,
            delegate!.tagListViewCanAddTags(self)
            || delegate!.tagListViewCanDeleteTags(self)
            || delegate!.tagListViewCanMoveTags(self),
            hasTags {
            rowWidth = frame.size.width - clearView.frame.width - Constants.defaultHorizontalClearPadding
        } else {
            rowWidth = frame.size.width
        }

        //print(frame.size.width, rowWidth)
        for (index,tagView) in tagViews.enumerated() {
            tagView.cornerRadius = self.cornerRadius
            tagView.horizontalPadding = self.horizontalPadding
            tagView.verticalPadding = self.verticalPadding
            tagView.textFont = self.textFont
            if delegate != nil,
                delegate!.tagListViewCanDeleteTags(self) {
                    tagView.removeButtonIsEnabled = true
                    tagView.state = .removable
            } else {
                tagView.removeButtonIsEnabled = false
                tagView.state = .normal
            }
            tagView.frame.size = tagView.intrinsicContentSize
            tagViewHeight = tagView.frame.height
            // print("y", currentY, tagViewHeight, frame.height)
            // Is this the first tag of the row?
            if currentRowTagCount > 0 && currentX + tagView.frame.width > rowWidth {
                
                if !isEditable {
                    // Align the tags for center and right position
                    // of the previous row
                    switch alignment {
                    case .center:
                        let horizontalOffset = (rowWidth - currentX) / 2
                        // Loop over the tags in the row
                        for alignIndex in 0..<currentRowTagCount {
                            // print(index, alignIndex)
                            tagViews[index - alignIndex - 1].frame.origin.x += horizontalOffset
                        }
                    case .right:
                        let horizontalOffset = (rowWidth - currentX)
                        for alignIndex in 0...currentRowTagCount - 1 {
                            tagViews[index - alignIndex].frame.origin.x += horizontalOffset
                        }
                    default:
                        break
                    }
                }
                currentRowTagCount = 0
                currentRow += 1
                    
                // Create new row with TagViews
                currentY += tagView.frame.height + Constants.defaultVerticalPadding
                currentX = 0
                /*var tagWidth = tagView.frame.width
                 if (tagWidth > frame.size.width) { // token is wider than max width
                 tagWidth = frame.size.width
                 }*/
            }
            tagView.frame = CGRect(
                x: currentX,
                y: currentY,
                width: tagView.frame.width,
                height: tagView.frame.height )
            
            // print("currentXY", currentX, currentY)
            //let tagBackgroundView = self.tagBackgroundView
            //tagBackgroundView.frame.origin = CGPoint(x: currentX, y: currentY)
            //tagBackgroundView.frame.size = tagView.bounds.size
            //addSubview(tagBackgroundView)
            // print("currentRowView", currentRowView.frame.origin)
            // print("TagView", tagView.title, tagView.frame.origin, tagView.frame.size)
            // print("backgroundTagView", tagBackgroundView.frame.origin)
            //currentRowView.addSubview(tagView)
            // currentRowView.addSubview(tagBackgroundView)
            currentX += tagView.frame.width + horizontalPadding
            // print("NEWcurrentXY", currentX, currentY)
            
            //scrollView.addSubview(tagView)
            
            // currentRowWidth += tagView.frame.width + horizontalMargin
            
            // tagView.backgroundColor = backgroundColor
            
            // very last tag? OR started a new row
            if index == tagViews.count - 1 && !isEditable {
                // align the tags for center and right position
                switch alignment {
                case .center:
                    let horizontalOffset = (rowWidth - currentX) / 2
                    // Loop over the tags in the row
                    for alignIndex in 0...currentRowTagCount {
                        tagViews[index - alignIndex].frame.origin.x += horizontalOffset
                    }
                case .right:
                    let horizontalOffset = (rowWidth - currentX)
                    for alignIndex in 0...currentRowTagCount {
                        tagViews[index - alignIndex].frame.origin.x += horizontalOffset
                    }
                default:
                    break
                }
            }
            currentRowTagCount += 1
        }
        
        tagViews.forEach( { addSubview($0) } )
        
        rows = currentRow
    }
    
    private func layoutInputTextViewWith(currentX: inout CGFloat, currentY: inout CGFloat, clearInput: Bool) {
        
        var inputTextViewOrigin = CGPoint()
        var clearButtonWidth = CGFloat(0.0)
        //let inputHeight = inputTextField.intrinsicContentSize.height > Constants.defaultTagHeight
//            ? inputTextField.intrinsicContentSize.height
  //          : Constants.defaultTagHeight
        
        // let inputHeight = tagViewHeight
        if delegate != nil,
            delegate!.tagListViewCanDeleteTags(self),
            hasTags {
            clearButtonWidth = CGFloat(Clear.ViewSize)
        }
        // Is there enough space for a reasonable inputTextView
        if currentX + Constants.defaultMinInputWidth >= frame.width - clearButtonWidth {
            // start with a new row
            currentX = Constants.defaultHorizontalMargin
            currentY += tagViewHeight + Constants.defaultVerticalPadding
        }
        inputTextViewOrigin.x = currentX
        inputTextViewOrigin.y = currentY
        
        inputTextField.frame = CGRect(
            x: inputTextViewOrigin.x,
            y: inputTextViewOrigin.y,
            width: frame.width - inputTextViewOrigin.x - clearButtonWidth  - Constants.defaultHorizontalClearPadding,
            height: tagViewHeight //  + Constants.defaultVerticalPadding
        )
        //print("frame",frame)
        // print("input", inputTextField.frame)

        /*
         var exclusionPaths: [UIBezierPath] = []
         
         if hasPrefixLabel && inputTextView.frame.origin.y == prefixLabel.frame.origin.y {
         exclusionPaths.append(UIBezierPath(rect: prefixLabel.frame))
         }
         
         for tagView in tagViews {
         if inputTextView.frame.origin.y == tagView.frame.origin.y {
         
         var frame = tagView.frame
         frame.origin.y = 0.0
         
         exclusionPaths.append(UIBezierPath(rect: frame))
         }
         }
         inputTextView.textContainer.exclusionPaths = exclusionPaths
         */
        // inputTextField.backgroundColor = .white
        // inputTextField.layer.borderColor = UIColor.green.cgColor
        
        if clearInput {
            inputTextField.text = ""
        }
        // scrollView.addSubview(inputTextView)
        // scrollView.sendSubview(toBack: inputTextView)
        // print("inputTextView origin", frame.origin.x, frame.origin.y)
        addSubview(inputTextField)
        // sendSubview(toBack: inputTextView)
    }
    
    /*private func focusInputTextView(currentX: CGFloat, currentY: CGFloat) {
     let contentOffset = scrollView.contentOffset
     let targetY = inputTextView.frame.origin.y + Constants.defaultTagHeight - maxHeight
     if targetY > contentOffset.y {
     scrollView.setContentOffset(
     CGPoint(x: currentX, y: targetY),
     animated: false
     )
     }
     }
     */
    
    private func layoutClearView() {
        
        // The clearView should only be added in editMode, if deletion is allowed and if a clear button is wanted
        
        // The clearView appears on the trailing edge
        // And vertically centered in the TagListView
        // Note that if TagListView is in another view, you might not see it.
        
        clearView.frame.origin.x = frame.size.width - clearView.frame.size.width - Constants.defaultHorizontalClearPadding
        clearView.frame.origin.y = (frame.size.height - clearView.frame.size.height) / 2.0
        //print("clear",clearView.frame)
        addSubview(clearView)
    }
    
    private func adjustHeightFor(currentY: CGFloat) {
        
        // The height of the TagListView frame should be adjusted
        let oldHeight = frame.height
        // print("old", oldHeight)
        
        var newFrame = frame
        newFrame.size.height = currentY + tagViewHeight + Constants.defaultVerticalMargin

        /*
        // has the frame height increased?
        if currentY + tagViewHeight + Constants.defaultVerticalMargin > oldHeight {
            // still within height limit?
            if currentY + tagViewHeight + Constants.defaultVerticalMargin <= maxHeight {
                // YES - calculate new height
                newFrame.size.height = currentY
                    + tagViewHeight
                    + Constants.defaultVerticalMargin
            } else {
                // No use maxHeight
                newFrame.size.height = maxHeight
            }
        }
        else {
            newFrame.size.height = currentY + tagViewHeight + Constants.defaultVerticalMargin
            /*
            // has a first increase occured?
            if currentY + tagViewHeight > originalHeight {
                newFrame.size.height = currentY
                    + tagViewHeight
                    + Constants.defaultVerticalMargin * 2
            } else {
                newFrame.size.height = maxHeight
            }
             */
        }
 */
 
        if abs (oldHeight - newFrame.height) > 0.1 {
            frame = newFrame
            // print("new",frame.height)
            datasource?.tagListView(self, didChange: frame.height)
        }
    }
    
    // MARK: - Manage tags
    override open var intrinsicContentSize: CGSize {
        //var height = CGFloat(rows) * (tagViewHeight + verticalMargin)
        //if rows > 0 {
        //    height -= verticalMargin
        //}
        return CGSize(width: frame.width, height: frame.height)
    }
//
// MARK: - TagView delegates
//
// These are the delegate functions required for individual tags
    
    public func didTapTagView(_ tagView: TagView) {
        if isEditable {
            if let currentIndex = self.tagViews.firstIndex(of: tagView) {
                removeTag(at: currentIndex)
            }
        } else {
            if let currentIndex = self.tagViews.firstIndex(of: tagView) {
                tagView.state == .selected ? filterDeselectionAt(currentIndex) : filterSelectionAt(currentIndex)
            }
        }
        if delegate?.tagListView(self, canTapTagAt: tagView.tag) ?? false {
        // inform the delegate, so that additional tap handling can be done
         delegate?.tagListView(self, didTapTagAt: tagView.tag)
        }
    }
    
    public func didLongPressTagView(_ tagView: TagView) {
        delegate?.tagListView(self, didLongPressTagAt: tagView.tag)
    }

    public func didTapRemoveButton(_ tagView: TagView) {
        removeTag(at: tagView.tag)
    }
//
// MARK: - State variables
//
    open var isCollapsed = false {
        didSet {
            if isCollapsed {
                layoutCollapsedLabel()
            } else {
                collapsedLabel.removeFromSuperview()
            }
        }
    }
    
    /// Does the delegate allow editing (add/delete/move) of the tags?
    private var isEditable: Bool {
        get {
            guard delegate != nil else { return false }
            
            return delegate!.tagListViewCanAddTags(self)
                || delegate!.tagListViewCanDeleteTags(self)
                || delegate!.tagListViewCanMoveTags(self)
        }
    }
    
    open var allowsMultipleSelection = false
    
    /*
 open var allowsCreation = false {
        didSet {
            if allowsCreation != oldValue {
                rearrangeViews(true)
                
            }
        }
    }
    
    open var allowsRemoval = false {
        didSet {
            if allowsRemoval != oldValue {
                reloadData(clearAll: true)
            }
        }
    }
    
    /// The clearButton allows the user to delete ALL tags. If clearButtonIsEnable this button is shown.
    open var clearButtonIsEnabled: Bool = false {
        didSet {
            if clearButtonIsEnabled != oldValue {
                rearrangeViews(true)
            }
        }
    }
 */

    // - parameter removeButtonIsEnabled:
    // Add a remove icon next to the tag. Tapping it allows the user to delete the tag.
    //open var removeButtonIsEnabled = false
    
    // MARK: - Tag handling
    
    private func removeTag(at index: Int) {
        if delegate != nil,
            delegate!.tagListViewCanDeleteTags(self) {
            delegate?.tagListView(self, willBeginEditingTagAt: index)
            delegate?.tagListView(self, didDeleteTagAt: index)
            reloadData(clearAll:false)
            delegate?.tagListView(self, didEndEditingTagAt: index)
        }
    }
    
    // MARK : Selection functions
    
    func deselectTag(at index: Int) {
        tagViews[index].state = .normal
    }
    
    func selectTag(at index: Int) {
        if !allowsMultipleSelection {
            deselectAllTags()
        }
        tagViews[index].state = .selected
    }
    
    open func deselectAllTags() {
        tagViews.forEach { $0.state = .normal }
    }
    
    open var selectedTags: [Int] {
        get {
            var indeces: [Int] = []
            for (index, tagView) in tagViews.enumerated() {
                if tagView.state == .selected {
                    indeces.append(index)
                }
            }
            return indeces
        }
    }
    
    private func filterDeselectionAt(_ index: Int) {
        // deselection only works when not in editMode
        if !isEditable {
            delegate?.tagListView(self, willDeselectTagAt: index)
            // then select the tag
            deselectTag(at: index)
            delegate?.tagListView(self, didDeselectTagAt: index)
        }
    }
    
    private func filterSelectionAt(_ index: Int) {
        if !isEditable {
            delegate?.tagListView(self, willSelectTagAt: index)
            // then select the tag
            selectTag(at: index)
            delegate?.tagListView(self, didSelectTagAt: index)
        }
    }
    
    private func indecesWithTag(_ title: String) -> [Int] {
        var indeces: [Int] = []
        for (index, tagView) in tagViews.enumerated() {
            if tagView.label.text == title {
                indeces.append(index)
            }
        }
        return indeces
    }
// MARK: - Tap handling
//
    // TODO: Do I still want to support this
    
    private var tapGestureRecognizer: UITapGestureRecognizer?
    
    @objc internal func uncollapseOnTap(_ sender: UITapGestureRecognizer) {
        isCollapsed = false
    }
    
    @objc internal func clearOnTap(_ sender: UITapGestureRecognizer) {
        delegate?.didDeleteAllTags(self)
        // reload in case the user changed the data
        reloadData(clearAll: false)
    }
    
    func willDisappear() {
        if let validGestureRecognizers = self.gestureRecognizers {
            for gesture in validGestureRecognizers {
                if gesture is UITapGestureRecognizer {
                    self.removeGestureRecognizer(gesture)
                }
            }
        }
        if let validGestureRecognizers = clearView.gestureRecognizers {
            for gesture in validGestureRecognizers {
                if gesture is UITapGestureRecognizer {
                    self.removeGestureRecognizer(gesture)
                }
            }
        }
        for tagView in tagViews {
            tagView.willDisappear()
        }
    }
//
// MARK: - Drag & Drop support
//
    // TODO: this interferes with long press interactions I am using in FoodViewer
    
    open var allowsReordering = false {
        didSet {
            if allowsReordering {
                // if reordering is allowed setup the longPress gesture
                let longpress = UILongPressGestureRecognizer(target: self, action: #selector(TagListView.longPressGestureRecognized))
                self.addGestureRecognizer(longpress)
            }
        }
    }
    private var longPressViewSnapshot : UIView? = nil
    
    private var longPressInitialIndex : Int? = nil
    
    @objc private func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        
        func snapshotOfView(_ inputView: UIView) -> UIView {
            UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
            inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
            UIGraphicsEndImageContext()
            let cellSnapshot : UIView = UIImageView(image: image)
            cellSnapshot.layer.masksToBounds = false
            cellSnapshot.layer.cornerRadius = 0.0
            cellSnapshot.layer.shadowOffset = CGSize.init(width: -5.0, height: 0.0)
            cellSnapshot.layer.shadowRadius = 5.0
            cellSnapshot.layer.shadowOpacity = 0.4
            return cellSnapshot
        }
        
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        
        let locationInView = longPress.location(in: self)
        // get the index of the tag where the longPress took place
        let index = indexForTagViewAt(longPress.location(in: self))
        
        func startReOrderingTagAt(_ sourceIndex: Int?) {
            
            let state = longPress.state
            switch state {
            case UIGestureRecognizer.State.began:
                self.longPressInitialIndex = index
                if let sourceIndex = self.longPressInitialIndex {
                    if let canMoveTag = delegate?.tagListView(self, canMoveTagAt: sourceIndex) {
                        // check if the user gives permission to move this tag
                        if canMoveTag {
                            // make only a snapshot if the tag is allowed to move
                            longPressViewSnapshot = snapshotOfView(tagViews[sourceIndex])
                            if longPressViewSnapshot != nil {
                                
                                longPressViewSnapshot!.isHidden = true
                                longPressViewSnapshot!.alpha = 0.0
                                addSubview(longPressViewSnapshot!)
                                
                                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                    self.longPressViewSnapshot!.center = locationInView
                                    self.longPressViewSnapshot!.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                                    self.longPressViewSnapshot!.alpha = 0.9
                                    self.tagViews[sourceIndex].alpha = 0.3
                                }, completion: { (finished) -> Void in
                                    if finished {
                                        self.tagViews[sourceIndex].isHidden = true
                                        self.longPressViewSnapshot!.isHidden = false
                                    }
                                })
                            }
                        }
                    }
                }
            case UIGestureRecognizer.State.changed:
                if longPressViewSnapshot != nil {
                    // move the snapshot to current press location
                    var newLocation = locationInView
                    if newLocation.x < frame.origin.x {
                        newLocation.x = frame.origin.x
                    } else if newLocation.x > frame.origin.x + frame.size.width {
                        newLocation.x = frame.origin.x + frame.size.width
                    }
                    if newLocation.y < frame.origin.y {
                        newLocation.y = frame.origin.y
                    } else if newLocation.y > frame.origin.y + frame.size.height {
                        newLocation.y = frame.origin.y + frame.size.height
                    }
                    longPressViewSnapshot!.center = newLocation
                    if let validDestinationIndex = index,
                        let validSourceIndex = self.longPressInitialIndex {
                        if validDestinationIndex != validSourceIndex {
                            // ask the user if the destinationIndex is allowed
                            if let userDefinedDestinationIndex = delegate?.tagListView(self, targetForMoveFromTagAt: validSourceIndex, toProposed: validDestinationIndex) {
                                // use the destinationIndex value proposed by the user
                                moveTagAt(validSourceIndex, to: userDefinedDestinationIndex)
                                self.longPressInitialIndex = userDefinedDestinationIndex
                            } else {
                                // the user does not want to interfere, so default is to use the initial proposed target index
                                moveTagAt(self.longPressInitialIndex!, to: validDestinationIndex)
                                self.longPressInitialIndex = validDestinationIndex
                            }
                        }
                    }
                }
            default:
                if longPressViewSnapshot != nil {
                    if let validIndex = self.longPressInitialIndex {
                        tagViews[validIndex].isHidden = false
                        tagViews[validIndex].alpha = 0.0
                        UIView.animate(withDuration: 0.25, animations: { () -> Void in
                            self.longPressViewSnapshot!.center = self.tagViews[validIndex].center
                            self.longPressViewSnapshot!.transform = CGAffineTransform.identity
                            self.longPressViewSnapshot!.alpha = 0.0
                            self.tagViews[validIndex].alpha = 1.0
                        }, completion: { (finished) -> Void in
                            if finished {
                                self.longPressInitialIndex = nil
                                self.longPressViewSnapshot!.removeFromSuperview()
                                self.longPressViewSnapshot = nil
                            }
                        })
                    } else {
                        UIView.animate(withDuration: 0.25, animations: { () -> Void in
                            // My.viewSnapshot!.center = self.tagViews[validIndex].center
                            self.longPressViewSnapshot!.transform = CGAffineTransform.identity
                            self.longPressViewSnapshot!.alpha = 0.0
                            // self.tagViews[validIndex].alpha = 1.0
                        }, completion: { (finished) -> Void in
                            if finished {
                                self.longPressInitialIndex = nil
                                self.longPressViewSnapshot!.removeFromSuperview()
                                self.longPressViewSnapshot = nil
                            }
                        })
                    }
                }
            }
        }
        
        func moveTagAt(_ fromIndex: Int, to toIndex: Int) {
            if fromIndex != toIndex {
                // give the user the chance to move the data
                delegate?.tagListView(self, moveTagAt: fromIndex, to: toIndex)
                self.reloadData(clearAll:false)
            }
        }
        
        startReOrderingTagAt(index)
        
    }
    
    private func indexForTagViewAt(_ point: CGPoint) -> Int? {
        for (index, tagView) in tagViews.enumerated() {
            if tagView.frame.contains(self.convert(point, to: tagView)) {
                return index
            }
        }
        return nil
    }

    // TBD This should only work in editMode?
    // TBD Is there a mixup between highlighted and selected?
    // The user can delete tags with a backspace
    func textFieldDidEnterBackspace(_ textField: BackspaceTextField) {
        //var tagViewDeleted = false
        
        // Are there any tags?
        if let tagCount = datasource?.numberOfTagsIn(self), tagCount > 0 {
            // remove the last one
            removeTag(at: tagCount - 1 )
        }
        /*
        if !tagViewDeleted {
            if let last = tagViews.last {
                last.state = .removable
            }
        }
         */
        setCursorVisibility()
    }
    
}
//
// MARK: - UITextViewDelegates
//
extension TagListView: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // If the user enters a return, a new tag will be created
        
        if string == "\n" {
            if let newTag = textField.text {
                if !newTag.isEmpty {
                    delegate?.tagListView(self, didAddTagWith: newTag)
                    reloadData(clearAll:true)
                    textField.resignFirstResponder()
                }
            }
            return false
        } else if string == "," {
            if let newTag = textField.text {
                if !newTag.isEmpty {
                    delegate?.tagListView(self, didAddTagWith: newTag)
                    reloadData(clearAll:false)
                }
            }
            return false
        }
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
}
