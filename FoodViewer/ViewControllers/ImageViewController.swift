//
//  ImageViewController.swift
//  FoodViewer
//
//  Created by arnaud on 11/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

protocol ImageCoordinatorProtocol {
    
    func imageViewController(_ sender:ImageViewController, tapped barButton:UIBarButtonItem)
}

final class ImageViewController: UIViewController {
    
// MARK: - Public variables
    
    public var imageSize: ProductImageSize? {
        didSet {
            setUploaderName()
            setDate()
            setImageAge()
        }
    }
    
    public var imageTitle: String? = nil {
        didSet {
            setTitle()
        }
    }
    
    public var protocolCoordinator: ImageCoordinatorProtocol? = nil
    
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
        }
    }
    
    @IBOutlet weak var dateTimeLabel: UILabel! {
        didSet {
            setDate()
        }
    }
    
    @IBOutlet weak var uploaderExplanationLabel: UILabel! {
        didSet {
            uploaderExplanationLabel?.text = TranslatableStrings.Uploader
        }
    }
    
    @IBOutlet weak var uploaderLabel: UILabel! {
        didSet {
            setUploaderName()
        }
    }
    @IBOutlet weak var imageAgeView: UIView! {
        didSet {
            setImageAge()
        }
    }
    
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!

    private func setUploaderName() {
        uploaderLabel?.text = imageSize?.uploader ?? TranslatableStrings.UploaderUnknown
    }
    
    private func setTitle() {
        navItem?.title  = imageTitle != nil ? imageTitle! : TranslatableStrings.NoTitle
    }
    
    private func setImageAge() {
        imageAgeView?.isHidden = true
        guard let validTime = imageSize?.imageDate else { return }
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
        guard let validTime = imageSize?.imageDate else { return }
        let validDate = Date(timeIntervalSince1970: validTime)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        dateTimeLabel?.text =  formatter.string(from: validDate)
    }
        
    private func setImage() {
        var imageToDisplay: UIImage? = nil
        if let result = imageSize?.largest?.fetch() {
            switch result {
            case .success(let image):
                imageToDisplay = image
            // in the other case I should show a loading or impossible image
            case .loading:
                imageToDisplay = UIImage.init(named:"Loading")
            default:
                break
            }
        } else {
             imageToDisplay = UIImage.init(named:"NotOK")
        }
        imageView?.image = imageToDisplay
        if let validSize = imageToDisplay? .size {
            imageView?.frame.size = validSize
        }
        if let validSize = scrollView?.frame.size {
            updateConstraints(for: validSize)
        }
    }
    
    @objc func reloadImage() {
        setImage()
        setUploaderName()
        setDate()
        setImageAge()
    }
    
    private func updateMinZoomScale(for size: CGSize) {
      let widthScale = size.width / imageView.bounds.width
      let heightScale = size.height / imageView.bounds.height
      let minScale = min(widthScale, heightScale)
        
      scrollView.minimumZoomScale = minScale
      scrollView.zoomScale = minScale
    }

    
    // https://www.raywenderlich.com/5758454-uiscrollview-tutorial-getting-started
    //2
    private func updateConstraints(for size: CGSize) {
      let yOffset = max(0, (size.height - imageView.frame.height) / 2)
      imageViewTopConstraint.constant = yOffset
      imageViewBottomConstraint.constant = yOffset
      
      //4
      let xOffset = max(0, (size.width - imageView.frame.width) / 2)
      imageViewLeadingConstraint.constant = xOffset
      imageViewTrailingConstraint.constant = xOffset
        
      view.layoutIfNeeded()
    }

    override func viewWillLayoutSubviews() {
      super.viewWillLayoutSubviews()
        updateMinZoomScale(for: scrollView.bounds.size)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector:#selector(ImageViewController.reloadImage), name:.ImageSet, object:nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setImage()
    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        coordinator?.viewControllerDidDisappear(self)
        super.viewDidDisappear(animated)
    }
    
}

extension ImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraints(for: view.bounds.size)
    }

}

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
