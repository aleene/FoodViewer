//
//  GameViewController.swift
//  FoodViewer
//
//  Created by arnaud on 31/10/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton! {
        didSet {
            startButton?.isHidden = showQuestion
            startButton?.isEnabled = false
            startButton?.setTitle(TranslatableStrings.GamePreparing, for: .normal)
        }
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
        showQuestion = true
    }
    
    @IBOutlet weak var explanationLabel: UILabel! {
        didSet {
            explanationLabel?.text = TranslatableStrings.GameExplanation
            explanationLabel?.isHidden = showQuestion
        }
    }
    
    @IBOutlet var containerView: UIView! {
        didSet {
            containerView?.isHidden = !showQuestion
        }
    }
    
    @IBOutlet weak var navigationBarTitle: UINavigationItem! {
        didSet {
            navigationBarTitle.title = "Game"
        }
    }
    
    @IBAction func actionBarButtonItemTapped(_ sender: UIBarButtonItem) {
        guard currentQuestion != nil else { return }
        
        var sharingItems = [AnyObject]()
            
        if let text = currentQuestion?.barcode {
            sharingItems.append(text as AnyObject)
        }
        // add the image
        if let validUrlString = currentQuestion?.url,
            let validUrl = URL(string: validUrlString) {
            let imageSet = ProductImageSize(selectedURL: validUrl)
            if let fetchResult = imageSet.largest?.fetch() {
                switch fetchResult {
                case .success(let image):
                    sharingItems.append(image)
                default: break
                }
            }
        }
        
        if let validBarcode = currentQuestion?.barcode {
            let url = OFF.webProductURLFor(BarcodeType(barcodeString: validBarcode, type: .food))
            sharingItems.append(url as AnyObject)
        }
            
        let activity = TUSafariActivity()
            
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: [activity])
            
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.print, UIActivity.ActivityType.openInIBooks, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.addToReadingList]
            
        // This is necessary for the iPad
        let presCon = activityViewController.popoverPresentationController
        presCon?.barButtonItem = sender
            
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var editBarButtonItem: UIBarButtonItem! {
        didSet {
            editBarButtonItem.isEnabled = showQuestion && currentQuestion != nil
        }
    }
    
    @IBAction func editBarButtonItemTapped(_ sender: UIBarButtonItem) {
        if let validBarcode = currentQuestion?.barcode {
            self.scannedProductPair = OFFProducts.manager.createProductPair(with:BarcodeType(barcodeString: validBarcode, type: .food))
            //print("Barcode found: type= " +  barcode.type.rawValue + " value=" + self.currentBarcode)
            // create this barcode in the history and launch te fetch
            DispatchQueue.main.async(execute: {
                // open the product in the History tab
                self.switchToHistoryTab()
            })
        }
    }
    
    @IBOutlet weak var actionBarButtonTime: UIBarButtonItem! {
        didSet {
            actionBarButtonTime.isEnabled = showQuestion && currentQuestion != nil
        }
    }
    
    private var containerViewController: RobotoffQuestionViewController?
    
    private var robotoff: OFFRobotoff? = nil
        
    private var currentQuestionIndex = 0
    
    private var questionSetSize = 10
        
    private func prepareNextQuestion() {
        if  currentQuestionIndex < questionSetSize - 1 {
            currentQuestionIndex += 1
            setQuestion()
        } else {
            startButton?.setTitle(TranslatableStrings.GameContinue, for: .normal)
            startNewQuestionSet()
        }
    }
    
    private func startNewQuestionSet() {
        robotoff = nil
        robotoff = OFFRobotoff(barcode: nil, count: 20)
        robotoff?.refresh()
        currentQuestionIndex = 0
        showQuestion = false
        startButton?.isEnabled = false
        startButton?.setTitle(TranslatableStrings.GamePreparing, for: .normal)
    }
    
    private func setQuestion() {
        if let fetchStatus = robotoff?.robotoffQuestionsFetchStatus {
            switch fetchStatus {
            case .success(let questions):
                startButton?.isEnabled = true
                startButton?.setTitle(TranslatableStrings.GameStart, for: .normal)
                if let validQuestion = validQuestion(questions: questions) {
                    currentQuestion = validQuestion
                    containerViewController?.configure(question: validQuestion, image: nil)
                } else {
                    currentQuestion = nil
                }
            case .loading:
                startButton?.setTitle(TranslatableStrings.SearchLoading, for: .normal)
            case .failed:
                startButton?.setTitle(TranslatableStrings.GameNotPrepared, for: .normal)
            case .initialized:
                startButton?.setTitle(TranslatableStrings.GamePreparing, for: .normal)
            default: break
            }
        }
    }
    
    private func validQuestion(questions: [RobotoffQuestion]) -> RobotoffQuestion? {
        if questions.isEmpty { return nil }
        
        while currentQuestionIndex < questions.count  {
            if questions[currentQuestionIndex].url != nil {
                return questions[currentQuestionIndex]
            }
            // try next question
            currentQuestionIndex += 1
        }
        return nil
    }
    
    private var currentQuestion: RobotoffQuestion? = nil {
        didSet {
            editBarButtonItem.isEnabled = currentQuestion != nil
            actionBarButtonTime.isEnabled = currentQuestion != nil
        }
    }
    
    private var showQuestion: Bool = false {
        didSet {
            containerView?.isHidden = !showQuestion
            startButton?.isHidden = showQuestion
            explanationLabel?.isHidden = showQuestion
        }
    }
    
    fileprivate var scannedProductPair: ProductPair? = nil

    private func switchToHistoryTab() {
        if let tabVC = self.parent as? UITabBarController {
            tabVC.selectedIndex = 1
            // prepare the controller before moving there
            if let controllers = tabVC.viewControllers,
                controllers.count > 1,
                let firstSplit = controllers[1] as? UISplitViewController,
                firstSplit.viewControllers.count > 0,
                let navController = firstSplit.viewControllers[0] as? UINavigationController,
                navController.children.count > 0,
                let controller = navController.children[0] as? AllProductsTableViewController {
                controller.start()
            }
        } else {
            assert(true, "BarcodeScanViewController:switchToTab:with: TabBar hierarchy error")
        }
    }

    @objc func updateQuestionStatus() {
        setQuestion()
    }

// MARK: - Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up the container viewController
        containerViewController = RobotoffQuestionViewController.instantiate()
        if containerViewController != nil {
            addChild(containerViewController!)
            containerViewController?.view.translatesAutoresizingMaskIntoConstraints = false
            containerView?.addSubview(containerViewController!.view)
            NSLayoutConstraint.activate([
                containerViewController!.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
                containerViewController!.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
                containerViewController!.view.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
                containerViewController!.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0)
        ])
        }
        containerViewController?.didMove(toParent: self)
        containerViewController?.protocolCoordinator = self
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        // start loading the questions
        startNewQuestionSet()

        NotificationCenter.default.addObserver(self,
                                               selector:#selector(GameViewController.updateQuestionStatus),
                                               name: .RobotoffQuestionsFetchStatusChanged,
                                               object:nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }

}

// MARK: - RobotoffQuestionCoordinatorProtocol

extension GameViewController: RobotoffQuestionCoordinatorProtocol {
    func robotoffQuestionTableViewController(_ sender: RobotoffQuestionViewController, answered question: RobotoffQuestion?) {
        guard let validQuestion = question else { return }
        robotoff?.uploadAnswer(for: validQuestion)
        // Show next question
        prepareNextQuestion()
    }
}

// MARK: - UITabBarControllerDelegate Functions

extension GameViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // The user tapped on one of the tabs, so the selected/scanned product will be reset.
        scannedProductPair = nil
    }
    
}
