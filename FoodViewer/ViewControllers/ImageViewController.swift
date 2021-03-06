//
//  ImageViewController.swift
//  FoodViewer
//
//  Created by arnaud on 11/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import CoreGraphics

protocol ImageCoordinatorProtocol {
    
    func imageViewController(_ sender:ImageViewController, tapped barButton:UIBarButtonItem)
}

final class ImageViewController: UIViewController {
    
// MARK: - Public variables
    
    /// The image set to display
    public var imageSet: ProductImageSize? {
        didSet {
            setUploaderElements()
        }
    }
    
    /// The title to use for the viewController
    public var imageTitle: String? = nil {
        didSet {
            setTitle()
        }
    }
    
    /// The handler of the protocol
    public var protocolCoordinator: ImageCoordinatorProtocol? = nil
    
    /// The coordinator that manages the flow and initiated this viewController
    weak public var coordinator: Coordinator? = nil
    
// MARK: - Storyboard elements
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            if #available(iOS 11.0, *) {
                imageView.addInteraction(UIDragInteraction(delegate: self))
                imageView.isUserInteractionEnabled = true
            }
            imageView?.contentMode = .topLeft
        }
    }
    @IBOutlet weak var navItem: UINavigationItem! {
        didSet {
            setTitle()
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        protocolCoordinator?.imageViewController(self, tapped:sender)
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var explanationLabel: UILabel! {
        didSet {
            explanationLabel?.text = TranslatableStrings.UploadDateAndTime
            setUploaderElements()
        }
    }
    
    @IBOutlet weak var dateTimeLabel: UILabel! {
        didSet {
            setUploaderElements()
        }
    }
    
    @IBOutlet weak var uploaderExplanationLabel: UILabel! {
        didSet {
            uploaderExplanationLabel?.text = TranslatableStrings.Uploader
            setUploaderElements()
        }
    }
    
    @IBOutlet weak var uploaderLabel: UILabel! {
        didSet {
            setUploaderElements()
        }
    }
    @IBOutlet weak var imageAgeView: UIView! {
        didSet {
            setUploaderElements()
        }
    }
    
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!

    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.isHidden = true
            tagListView.textFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
            tagListView.alignment = .center
            if #available(iOS 13.0, *) {
                tagListView.removableColorScheme = ColorScheme(text: .secondaryLabel, background: .secondarySystemFill, border: .systemBackground)
            } else {
                tagListView.removableColorScheme = ColorScheme(text: .white, background: .darkGray, border: .black)
            }
            tagListView.cornerRadius = 10
            tagListView.prefixLabelText = nil
            tagListView?.datasource = self
        }
    }

    private var delegate: TagListViewCellDelegate? = nil

    private var hasImage: Bool {
        if let result = imageSet?.largest?.fetch() {
            switch result {
            case .success:
                return true
            default:
                break
            }
        }
        return false
    }
    
    private func setUploaderElements() {
        explanationLabel?.isHidden = !hasImage
        dateTimeLabel?.isHidden = !hasImage
        uploaderExplanationLabel?.isHidden = !hasImage
        uploaderLabel?.isHidden = !hasImage
        imageAgeView?.isHidden = !hasImage
        
        setUploaderName()
        setDate()
        setImageAge()
    }
    
    private func setUploaderName() {
        uploaderLabel?.text = imageSet?.uploader ?? TranslatableStrings.UploaderUnknown
    }
    
    private func setTitle() {
        navItem?.title  = imageTitle != nil ? imageTitle! : TranslatableStrings.NoTitle
    }
    
    private func setImageAge() {
        guard let validTime = imageSet?.imageDate else { return }
        guard let validDate = Date(timeIntervalSince1970: validTime).ageInYears else { return }

        if validDate >= 4.0 {
            imageAgeView?.backgroundColor = .purple
        } else if validDate >= 3.0 {
            imageAgeView?.backgroundColor = .red
        } else if validDate >= 2.0 {
            imageAgeView?.backgroundColor = .orange
        } else if validDate >= 1.0 {
            imageAgeView?.backgroundColor = .yellow
        } else {
            imageAgeView?.backgroundColor = .green
        }
        imageAgeView?.isHidden = false
    }
    
    private func setDate() {
        guard let validTime = imageSet?.imageDate else { return }
        let validDate = Date(timeIntervalSince1970: validTime)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        dateTimeLabel?.text =  formatter.string(from: validDate)
    }
        
    private var tagListViewText: String? = nil
    
    private func setImage() {
        
        if let result = imageSet?.largestOrThumb {
            switch result {
            case .success(let image):
                                
                imageView?.image = image
                
                if let validSize = imageView?.image?.size {
                    scrollView?.contentSize = validSize
                }
                
                setUploaderElements()
                if let validSize = scrollView?.bounds.size {
                    updateMinZoomScale(for: validSize)
                }
                imageView?.isHidden = false
                tagListView?.isHidden = true
                return
                
            // in the other case I should show a status tag
            case .loadingFailed(let error):
                self.tagListViewText = error.localizedDescription
            case .loading:
                self.tagListViewText = TranslatableStrings.Loading
            case .noResponse:
                self.tagListViewText = "No response"
            case .noData:
                self.tagListViewText = "No data"
            case .noImageAvailable:
                self.tagListViewText = "No image available"
            case .response(let response):
                self.tagListViewText = "\(response.statusCode)"
            case .uploading:
                self.tagListViewText = "uploading"
            }
        } else {
            self.tagListViewText = TranslatableStrings.ImageWasEmpty
        }
        imageView?.isHidden = true
        tagListView?.isHidden = false
    }
    
    @objc func reloadImage() {
        setImage()
    }
    
    private func updateMinZoomScale(for scrollViewSize: CGSize) {
        guard imageView != nil else { return }
        //print("Zoom ", imageView!.frame, scrollViewSize)
        guard imageView!.bounds.width > .zero &&
            imageView!.bounds.height > .zero else { return }

        let widthScale = scrollViewSize.width / imageView!.bounds.width
        let heightScale = scrollViewSize.height / imageView!.bounds.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale * 0.5
        scrollView.maximumZoomScale = 10.0
        scrollView.zoomScale = minScale
        updateConstraints(for: scrollViewSize)
    }

    
    // https://www.raywenderlich.com/5758454-uiscrollview-tutorial-getting-started

    private func updateConstraints(for scrollViewSize: CGSize) {
        guard imageView != nil else { return }
        
        let yOffset = -max(0, (scrollViewSize.height - imageView!.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        
        //4
        let xOffset = -max(0, (scrollViewSize.width - imageView!.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        //print("Constraints ", imageView!.frame, scrollViewSize, xOffset, yOffset)

        view.layoutIfNeeded()
    }

//MARK: - ViewController lifecycle
    
    override func viewWillLayoutSubviews() {
      super.viewWillLayoutSubviews()
        updateMinZoomScale(for: scrollView.bounds.size)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector:#selector(ImageViewController.reloadImage), name:.ImageSet, object:nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setImage()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //setImage()
    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        coordinator?.viewControllerDidDisappear(self)
        super.viewDidDisappear(animated)
    }
    
}

// MARK: - UIScrollViewDelegate

extension ImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraints(for: view.bounds.size)
    }

}

// MARK: - UIDragInteractionDelegate

extension ImageViewController: UIDragInteractionDelegate {
    
    @available(iOS 11.0, *)
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        
        guard let image = imageView.image else { return [] }
        let provider = NSItemProvider(object: image)
        let item = UIDragItem(itemProvider: provider)
        item.localObject = image
        
        return [item]
    }
    
}

// MARK: - TagListView Datasource Functions

extension ImageViewController: TagListViewDataSource {
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        return 1
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        return tagListViewText ?? TranslatableStrings.None
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
    }
    
    public func tagListView(_ tagListView: TagListView, colorSchemeForTagAt index: Int) -> ColorScheme? {
        return ColorSchemes.error
    }
}
