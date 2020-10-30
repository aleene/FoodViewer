//
//  RobotoffQuestionViewController.swift
//  FoodViewer
//
//  Created by arnaud on 22/10/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

protocol RobotoffQuestionCoordinatorProtocol {
/**
Inform the protocol delegate that the robotoff question has been answered.
- Parameters:
     - sender : the `RobotoffQuestionViewController` that called the function.
     - shop : the name and address of the selected shop
*/
    func robotoffQuestionTableViewController(_ sender:RobotoffQuestionViewController, answered question:RobotoffQuestion?)
}

/// An UIViewController that allows to answer a robotoff question.
class RobotoffQuestionViewController: UIViewController {

    var protocolCoordinator: RobotoffQuestionCoordinatorProtocol? = nil
    /// The coordinator that manages the flow.
    weak var coordinator: Coordinator? = nil

// MARK: - External Input properties

/**
Configure the class SelectPairViewController in one go. All possible input parameters are set in this function.
- Warning: If this function is not used the class will NOT work.

- parameter question: The robotoff question that needs to be answered.
*/
    func configure(question: RobotoffQuestion?,
                   image: ProductImageSize?) {
        self.question = question
        self.image = image
    }

// MARK: - Storyboard elements
    
    @IBOutlet weak var questionLabel: UILabel! {
        didSet {
            questionLabel?.text = question?.question
        }
    }
    
    @IBOutlet weak var typeLabel: UILabel! {
        didSet {
            typeLabel?.text = question?.value
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!

    @IBOutlet weak var robotoffImageView: UIImageView! {
        didSet {
            setImage()
        }
    }
    
    @IBOutlet weak var denyButton: UIBarButtonItem! {
        didSet {
            denyButton?.title = TranslatableStrings.No
        }
    }
    
    @IBAction func denyButtonTapped(_ sender: UIBarButtonItem) {
        // Inform robotoff that it is wrong
        question?.response = RobotoffQuestionResponse.refuse
        protocolCoordinator?.robotoffQuestionTableViewController(self, answered: question)
    }
    
    @IBOutlet weak var unknownButton: UIBarButtonItem! {
        didSet {
            unknownButton?.title = TranslatableStrings.Unknown
        }
    }
    
    @IBAction func unknownButtonTapped(_ sender: UIBarButtonItem) {
        question?.response = RobotoffQuestionResponse.unknown
        protocolCoordinator?.robotoffQuestionTableViewController(self, answered: question)
    }
    
    @IBOutlet weak var confirmButton: UIBarButtonItem! {
        didSet {
            confirmButton?.title = TranslatableStrings.Yes
        }
    }
    
    @IBAction func confirmButtonTapped(_ sender: UIBarButtonItem) {
        // Inform robotoff that it is correct
        question?.response = RobotoffQuestionResponse.accept
        protocolCoordinator?.robotoffQuestionTableViewController(self, answered: question)
    }
    
// MARK: - Private variables
    
    private var question: RobotoffQuestion? {
        didSet {
            questionLabel?.text = question?.question
        }
    }
    
    private var image: ProductImageSize? {
        didSet {
            setImage()
        }
    }

    private func setImage() {
        var imageToDisplay: UIImage? = nil
        if let result = image?.largest?.fetch() {
            switch result {
            case .success(let image):
                imageToDisplay = image
                case .loading:
                    imageToDisplay = UIImage.init(named:"Loading")
                default:
                    break
                }
            } else {
                 imageToDisplay = UIImage.init(named:"NotOK")
            }
            robotoffImageView?.image = imageToDisplay
        if let validSize = imageToDisplay? .size {
            robotoffImageView?.frame.size = validSize
        }
        if let validSize = scrollView?.frame.size {
            updateConstraints(for: validSize)
        }
    }
    
    func updateMinZoomScaleForSize(_ size: CGSize) {
      let widthScale = size.width / robotoffImageView.bounds.width
      let heightScale = size.height / robotoffImageView.bounds.height
      let minScale = min(widthScale, heightScale)
        
      scrollView.minimumZoomScale = minScale
      scrollView.zoomScale = minScale
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraints(for: view.bounds.size)
    }
    
    // https://www.raywenderlich.com/5758454-uiscrollview-tutorial-getting-started
    //2
    func updateConstraints(for size: CGSize) {
      //3
      let yOffset = max(0, (size.height - robotoffImageView.frame.height) / 2)
      imageViewTopConstraint.constant = yOffset
      imageViewBottomConstraint.constant = yOffset
      
      //4
      let xOffset = max(0, (size.width - robotoffImageView.frame.width) / 2)
      imageViewLeadingConstraint.constant = xOffset
      imageViewTrailingConstraint.constant = xOffset
        
      view.layoutIfNeeded()
    }

    override func viewWillLayoutSubviews() {
      super.viewWillLayoutSubviews()
      updateMinZoomScaleForSize(view.bounds.size)
    }
// MARK: - Notification handler
//
    @objc func imageUpdated(_ notification: Notification) {
        //let userInfo = (notification as NSNotification).userInfo
        setImage()
    }

// MARK: - ViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector:#selector(RobotoffQuestionViewController.imageUpdated(_:)), name:.ImageSet, object:nil)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        coordinator?.viewControllerDidDisappear(self)
        super.viewDidDisappear(animated)
    }

}

extension RobotoffQuestionViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return robotoffImageView
    }
}
