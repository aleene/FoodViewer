//
//  BarcodeScanViewController.swift
//  FoodViewer
//
//  Created by arnaud on 14/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import AVFoundation

class BarcodeScanViewController: UIViewController, UITextFieldDelegate, KeyboardDelegate {
    
    private let preferences = Preferences.manager
    
    private var currentBarcode: String = ""
    
    private var timer = Timer()
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(scanBarcodes), userInfo: nil, repeats: false)
    }
    
    // This variable defined the languageCode that must be used to display the product data
    // This is either the languageCode selected by the user or the best match for the current product
    private var displayLanguageCode: String? {
        return scannedProductPair?.product?.matchedLanguageCode(codes: Locale.preferredLanguageCodes)
    }

    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            setupProductType()
            searchTextField.delegate = self
        }
    }
    
    @IBOutlet weak var ecoscoreImageView: UIImageView!
    
    @IBOutlet weak var takePhotoButton: UIButton! {
        didSet {
            takePhotoButton.setTitle(TranslatableStrings.TakePhotos, for: .normal)
            takePhotoButton.isHidden = true
        }
    }
    
    @IBAction func takePhotoButtonTapped(_ sender: UIButton) {
        // open the product in the History tab
        self.switchToHistoryTab()
    }
    
    @IBOutlet weak var productNameBarButtonItem: UIBarButtonItem! {
        didSet {
            productNameBarButtonItem.title = "No product detected"
        }
    }
    
    @IBAction func productNameBarButtonItemTapped(_ sender: UIBarButtonItem) {
        self.switchToHistoryTab()
    }
    
    @IBOutlet weak var productView: UIView!
    
    @IBOutlet weak var scanView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var frontImageView: UIImageView!
    
    @IBOutlet weak var brandLabel: UILabel!
    
    @IBOutlet weak var quantityLabel: UILabel!
    
    @IBOutlet weak var nutriScoreView: NutriScoreView!
    
    @IBOutlet weak var NOVALabel: UILabel! {
        didSet {
            NOVALabel.text = TranslatableStrings.Nova
        }
    }
    
    @IBOutlet weak var NOVAValueLabel: UILabel!
    
    @IBOutlet weak var fatLabel: UILabel! {
        didSet {
            fatLabel.text = NutritionFactItem.init(nutrient: .fat, unit: .gram).itemName
        }
    }
    
    @IBOutlet weak var saturatedFatLabel: UILabel! {
        didSet {
            saturatedFatLabel.text = NutritionFactItem.init(nutrient: .saturatedFat, unit: .gram).itemName
        }
    }
    
    @IBOutlet weak var sugarLabel: UILabel! {
        didSet {
            sugarLabel.text = NutritionFactItem.init(nutrient: .sugars, unit: .gram).itemName
        }
    }
    
    @IBOutlet weak var saltLabel: UILabel! {
        didSet {
            saltLabel.text = NutritionFactItem.init(nutrient: .salt, unit: .gram).itemName
        }
    }
    
    @IBOutlet weak var barcodeSearchBar: UISearchBar! {
        didSet {
            barcodeSearchBar.placeholder = "Enter barcode"
        }
    }
    
    
    @IBOutlet weak var instructionView: UIView!
    
    @IBOutlet weak var instructionTextView: UITextView! {
        didSet {
            instructionTextView.text = TranslatableStrings.ScanInstruction
        }
    }
    
    private var nova: String? = nil {
        didSet {
            if let novaExists = nova {
                let validNova = novaExists.components(separatedBy: ".").first
                switch validNova {
                case "1":
                    NOVAValueLabel.text = validNova
                    NOVAValueLabel.textColor = .white
                    NOVAValueLabel.backgroundColor = .systemGreen
               case "2":
                    NOVAValueLabel.text = validNova
                    NOVAValueLabel.textColor = .white
                    NOVAValueLabel.backgroundColor = .systemYellow
                case "3":
                    NOVAValueLabel.text = validNova
                    NOVAValueLabel.textColor = .white
                    NOVAValueLabel.backgroundColor = .systemOrange
                case "4":
                    NOVAValueLabel.text = validNova
                    NOVAValueLabel.textColor = .white
                    NOVAValueLabel.backgroundColor = .systemRed
                default:
                    NOVAValueLabel.text = "?"
                    NOVAValueLabel.textColor = .black
                    NOVAValueLabel.backgroundColor = .white
                }
            } else {
                NOVAValueLabel.text = "?"
                NOVAValueLabel.textColor = .black
                NOVAValueLabel.backgroundColor = .white
            }
        }
    }
    
    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
            tagListView?.alignment = .center
            tagListView?.backgroundColor = .clear
            //tagListView.normalColorScheme = scheme
            //tagListView.removableColorScheme = ColorSchemes.removable
            tagListView?.cornerRadius = 10
            //tagListView.frame.size.width = self.frame.size.width
            
            tagListView?.datasource = self
            // tagListView.delegate = self as? TagListViewDelegate
            tagListView?.tag = 0
            tagListView?.prefixLabelText = nil
        }
    }
    
    private var score: NutritionalScoreLevel? = nil {
        didSet {
            if let validScore = score {
                switch  validScore {
                case .a:
                    nutriScoreView.currentScore = NutriScoreView.Score.A
                case .b:
                    nutriScoreView.currentScore = NutriScoreView.Score.B
                case .c:
                    nutriScoreView.currentScore = NutriScoreView.Score.C
                case .d:
                    nutriScoreView.currentScore = NutriScoreView.Score.D
                case .e:
                    nutriScoreView.currentScore = NutriScoreView.Score.E
                default:
                    nutriScoreView.currentScore = nil
                }
            } else {
                nutriScoreView.currentScore = nil
            }
        }
    }
    
/// returns an UIImage for a product, which can be displayed
    private func setup(ecoscore: Ecoscore?) -> UIImage? {
        if let validEcoscore = ecoscore {
            return validEcoscore.image
        } else {
            return Ecoscore.unknown.image
        }
    }
    
    func initializeCustomKeyboard() {
        // initialize custom keyboard
        let keyboardView = Keyboard(frame: CGRect(x: 0, y: 0, width: 0, height: 300))
        
        searchTextField?.inputView = keyboardView
        
        // the view controller will be notified by the keyboard whenever a key is tapped
        keyboardView.delegate = self
    }
    
    var activeTextField = UITextField()

    func keyWasTapped(_ character: String) {
        // check if we have a valid character (number)
        if character.isNumeric() {
            activeTextField.insertText(character)
            searchTextField.text = activeTextField.text
        }
    }
    
    func backspace() {
        activeTextField.deleteBackward()
        searchTextField.text = activeTextField.text
    }
    
    func enter() {
        view.endEditing(true)
        if var validBarcode = activeTextField.text,
            !validBarcode.isEmpty {
            // needed to go from UPC-12 to EAN-12
            if validBarcode.count == 12 {
                validBarcode = "0" + validBarcode
            }
            self.scannedProductPair = self.products.createProductPair(with: BarcodeType(barcodeString:validBarcode, type: preferences.showProductType))
            showProductData()
        }
    }
    
    func resetSearch() {
        self.searchTextField?.text = ""
        self.activeTextField.text = ""
    }
    
    fileprivate var products = OFFProducts.manager
    
    fileprivate var scannedProductPair: ProductPair? = nil {
        didSet {
            setupViews()
        }
    }
    
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
    
    @objc func scanBarcodes() {
        self.scanner?.barcodesHandler = { barcodes in
            for barcode in barcodes {
                // Is this a new barcode?
                if let validBarcode = barcode.stringValue,
                    validBarcode != self.currentBarcode {
                    self.currentBarcode = validBarcode
                    self.scannedProductPair = self.products.createProductPair(with:BarcodeType(typeCode: barcode.type.rawValue, value:validBarcode, type: self.preferences.showProductType))
                    //print("Barcode found: type= " +  barcode.type.rawValue + " value=" + self.currentBarcode)
                    // create this barcode in the history and launch te fetch
                    DispatchQueue.main.async(execute: {
                        if let continuousScanIsSet = ContinuousScanDefaults.manager.allowContinuousScan,
                            !continuousScanIsSet {
                            // start a timer to delay the next scan
                            self.startTimer()
                            // show the product data
                            self.showProductData()
                        } else {
                            // open the product in the History tab
                            self.switchToHistoryTab()
                        }
                    })
                }
            }
        }
    }
    
    @objc func showProductData() {
            if let validFetchResult = scannedProductPair?.remoteStatus  {
                switch validFetchResult {
                case .available, .updated:
                    resetSearch()
                    setupViews()
                    self.productNameBarButtonItem.title = scannedProductPair?.localProduct?.name ?? scannedProductPair?.remoteProduct?.name ?? TranslatableStrings.NoName
                    self.nova = scannedProductPair?.localProduct?.novaGroup ?? scannedProductPair!.remoteProduct?.novaGroup
                    self.score = scannedProductPair?.remoteProduct?.nutritionGrade ?? scannedProductPair?.localProduct?.nutritionGrade
                    tagListView?.reloadData(clearAll: true)
                    self.ecoscoreImageView?.image = setup(ecoscore: scannedProductPair?.remoteProduct?.ecoscore ?? scannedProductPair?.localProduct?.ecoscore)
                    if let nutritionLevels = scannedProductPair?.remoteProduct?.nutritionScore ?? scannedProductPair?.localProduct?.nutritionScore {
                        for level in nutritionLevels {
                            switch level.0 {
                            case .fat:
                                switch level.1 {
                                case .low:
                                    self.fatLabel.backgroundColor = .systemGreen
                                case .moderate:
                                    self.fatLabel.backgroundColor = .systemOrange
                                case .high:
                                    self.fatLabel.backgroundColor = .systemRed
                                default:
                                    break
                                }
                            case .saturatedFat:
                                switch level.1 {
                                case .low:
                                    self.saturatedFatLabel.backgroundColor = .systemGreen
                                case .moderate:
                                    self.saturatedFatLabel.backgroundColor = .systemOrange
                                case .high:
                                    self.saturatedFatLabel.backgroundColor = .systemRed
                                default:
                                    break
                                }
                            case .sugar:
                                switch level.1 {
                                case .low:
                                    self.sugarLabel.backgroundColor = .systemGreen
                                case .moderate:
                                    self.sugarLabel.backgroundColor = .systemOrange
                                case .high:
                                    self.sugarLabel.backgroundColor = .systemRed
                                default:
                                    break
                                }
                            case .salt:
                                switch level.1 {
                                case .low:
                                    self.saltLabel.backgroundColor = .systemGreen
                                case .moderate:
                                    self.saltLabel.backgroundColor = .systemOrange
                                case .high:
                                    self.saltLabel.backgroundColor = .systemRed
                                default:
                                    break
                                }
                            default:
                                break
                            }
                            productView.backgroundColor = UIColor.black.withAlphaComponent(0.6)

                            if let validProduct = scannedProductPair?.remoteProduct?.tracesInterpreted ?? scannedProductPair?.localProduct?.tracesInterpreted {
                                switch validProduct {
                                case .available(let validKeys):
                                    if (!validKeys.isEmpty) && (AllergenWarningDefaults.manager.hasValidWarning(validKeys)) {
                                        productView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.5)
                                    }
                                default:
                                    break
                                }
                            }
                            if let validProduct = scannedProductPair?.remoteProduct?.allergensInterpreted ?? scannedProductPair?.localProduct?.allergensInterpreted {
                                switch validProduct {
                                case .available(let validKeys):
                                    if (!validKeys.isEmpty) && (AllergenWarningDefaults.manager.hasValidWarning(validKeys)) {
                                        productView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.5)
                                    }
                                default:
                                    break
                                }
                            }
                        }
                    }
                    // showImage()
                    
            // in case of a new product THIS DOES NOT SEEM TO WORK
            case .productNotAvailable:
                setupViews()
                self.instructionTextView?.text = TranslatableStrings.TakePhotosInstruction
                self.takePhotoButton?.isHidden = false
                    if let validBarcode = scannedProductPair?.localProduct?.barcode.asString ?? scannedProductPair?.remoteProduct?.barcode.asString {
                        self.productNameBarButtonItem.title = "NEW: " +  validBarcode
                    }
            case .loadingFailed(let error):

                    
                    setupViews()
                    if let validBarcode = scannedProductPair?.localProduct?.barcode.asString ?? scannedProductPair?.remoteProduct?.barcode.asString {
                        self.productNameBarButtonItem.title = "NEW: " +  validBarcode
                    }
                self.instructionTextView?.text = error
            default:
                break
            }
        } else {
            // There is no valid productPair
            setupViews()
            self.instructionTextView?.text = TranslatableStrings.ScanInstruction
        }
    }
    
    private func showImage() {
        self.frontImageView.image = nil
        if let language = scannedProductPair?.remoteProduct?.primaryLanguageCode,
            let frontImages = scannedProductPair?.remoteProduct?.frontImages ?? scannedProductPair?.localProduct?.frontImages,
            !frontImages.isEmpty,
            let result = frontImages[language]?.small?.fetch() {
            switch result {
            case .success(let image):
                self.frontImageView.image = image
            default:
                break
            }
        }

    }
    
    // is the current device in compact orientation?
    private var deviceHasCompactOrientation: Bool {
        get {
            return self.traitCollection.horizontalSizeClass == .compact
        }
    }

    private func setupProductType() {
        
        nameLabel?.text = TranslatableStrings.PointCamera
        

        switch preferences.showProductType {
        case .food:
            searchTextField?.placeholder = deviceHasCompactOrientation ? TranslatableStrings.EnterFoodProductBarcodeShort : TranslatableStrings.EnterFoodProductBarcode
        case .petFood:
            searchTextField?.placeholder = deviceHasCompactOrientation ? TranslatableStrings.EnterPetFoodProductBarcodeShort : TranslatableStrings.EnterPetFoodProductBarcode
        case .beauty:
            searchTextField?.placeholder = deviceHasCompactOrientation ? TranslatableStrings.EnterBeautyProductBarcodeShort : TranslatableStrings.EnterBeautyProductBarcode
        case .product:
            searchTextField?.placeholder = deviceHasCompactOrientation ? TranslatableStrings.EnterProductBarcodeShort : TranslatableStrings.EnterProductBarcode
        }
        switch preferences.showProductType {
        case .food:
            productElementsAreHidden(false)
        default:
            productElementsAreHidden(true)
        }
        productView?.backgroundColor = UIColor.black
    }
    
    private func productElementsAreHidden(_ hide: Bool) {
        nutriScoreView?.isHidden = hide
        NOVALabel?.isHidden = hide
        NOVAValueLabel?.isHidden = hide
        fatLabel?.isHidden = hide
        saturatedFatLabel?.isHidden = hide
        sugarLabel?.isHidden = hide
        saltLabel?.isHidden = hide
    }
    
    // function is called if an product image has been retrieved via an asynchronous process
    @objc func imageSet(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo
        guard userInfo != nil else { return }
        
        // only update if the image barcode corresponds to the current product
        if let barcodeString = userInfo![ProductImageData.Notification.BarcodeKey] as? String,
            let validProductPair = scannedProductPair,
            validProductPair.barcodeType.asString == barcodeString {
            // showImage()
        }
    }

    @IBOutlet var downTwoFingerSwipe: UISwipeGestureRecognizer!
    
    @IBAction func nextProductType(_ sender: UISwipeGestureRecognizer) {
        if let tabVC = self.parent as? UITabBarController {
            if tabVC.selectedIndex == 0 {
                preferences.cycleProductType()
                setupProductType()
                products.reloadAll()
            }
        }
    }
    
    @objc func doubleTapOnProductView() {
        if let allowContinuousScan = ContinuousScanDefaults.manager.allowContinuousScan {
            ContinuousScanDefaults.manager.set(!allowContinuousScan)
        } else {
            ContinuousScanDefaults.manager.set(true)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let tabVC = self.parent as? UITabBarController {
            // start out with the scanner tab
            tabVC.selectedIndex = 0
            tabVC.delegate = self
            if let controllers = tabVC.viewControllers,
                controllers.count > 4 {
                controllers[0].tabBarItem?.title = TranslatableStrings.Scanner
                controllers[1].tabBarItem?.title = TranslatableStrings.History
                controllers[2].tabBarItem?.title = TranslatableStrings.Search
                controllers[3].tabBarItem?.title = TranslatableStrings.Game
                controllers[4].tabBarItem?.title = TranslatableStrings.User
                controllers[5].tabBarItem?.title = TranslatableStrings.Preferences
            }
        }
    }
    
    private func setupViews() {
        DispatchQueue.main.async(execute: {
            if self.scannedProductPair == nil {
                self.hideProductInterfaceElements = true
                self.takePhotoButton?.isHidden = true
            } else {
                switch self.scannedProductPair!.remoteStatus {
                case .available, .updated:
                    self.hideProductInterfaceElements = false
                    self.takePhotoButton?.isHidden = true
                case .productNotAvailable:
                    self.hideProductInterfaceElements = true
                    self.takePhotoButton?.isHidden = false
                default:
                    self.hideProductInterfaceElements = true
                    self.takePhotoButton?.isHidden = true
                }
            }
        })
    }
    
    private var hideProductInterfaceElements: Bool = true {
        didSet {
            self.productView?.isHidden = hideProductInterfaceElements
            self.instructionView?.isHidden = !hideProductInterfaceElements
        }
    }
    
    var scanner: RSCodeReaderViewController? = nil
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RSCodeReaderViewControllerSegue" {
            if let vc = segue.destination as? RSCodeReaderViewController {
                scanner = vc
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //is already done by the system
        //performSegue(withIdentifier: "RSCodeReaderViewControllerSegue", sender: self)
        scanBarcodes()
        setupProductType()
        setupViews()
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(BarcodeScanViewController.doubleTapOnProductView))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.numberOfTouchesRequired = 1
        doubleTapGestureRecognizer.cancelsTouchesInView = false
        doubleTapGestureRecognizer.delaysTouchesBegan = true      //Important to add
        productView?.addGestureRecognizer(doubleTapGestureRecognizer)

        initializeCustomKeyboard()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector:#selector(BarcodeScanViewController.showProductData), name:.ProductPairRemoteStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(BarcodeScanViewController.showProductData), name:.ProductPairLocalStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BarcodeScanViewController.imageSet(_:)), name: .ImageSet, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let validGestureRecognizers = productView?.gestureRecognizers {
            for gesture in validGestureRecognizers {
                if let doubleTapGesture = gesture as? UITapGestureRecognizer,
                    doubleTapGesture.numberOfTapsRequired == 2,
                    doubleTapGesture.numberOfTouchesRequired == 1 {
                    productView?.removeGestureRecognizer(gesture)
                }
            }
        }
        
        NotificationCenter.default.removeObserver(self)

        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }

}

// MARK: - UITabBarControllerDelegate Functions

extension BarcodeScanViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // The user tapped on one of the tabs, so the selected/scanned product will be reset.
        scannedProductPair = nil
        products.currentScannedProduct = nil
    }
    
}

// MARK: - TagListView DataSource Functions

extension BarcodeScanViewController: TagListViewDataSource {
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        return scannedProductPair != nil ? SelectedDietsDefaults.manager.selected.count : 0
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        if scannedProductPair != nil {
            let dietKey = SelectedDietsDefaults.manager.selected[index]
                //let conclusion = Diets.manager.conclusion(validProduct, forDietWith:dietKey)
            return Diets.manager.name(forDietWith: dietKey, in: Locale.interfaceLanguageCode) ?? "No diet name found "
                // return (name ?? "No diet name found ") + "\(conclusion ?? 0)"
        }
        
        return ProductFetchStatus.description(for: tagListView.tag)
    }
    
    public func tagListView(_ tagListView: TagListView, colorSchemeForTagAt index: Int) -> ColorScheme? {
            if let validProduct = scannedProductPair?.remoteProduct {
                let dietKey = SelectedDietsDefaults.manager.selected[index]
                guard let validConclusion = Diets.manager.conclusion(validProduct, forDietWith:dietKey) else { return nil }
                switch validConclusion {
                case -13:
                    return ColorScheme(text: .white, background: .systemPurple, border: .systemPurple)
                case -2:
                    return ColorScheme(text: .white, background: .systemRed, border: .systemRed)
                case -1:
                    return ColorScheme(text: .white, background: .systemOrange, border: .systemOrange)
                case 0:
                    return ColorScheme(text: .black, background: .systemYellow, border: .lightGray)
                case 1:
                    return ColorScheme(text: .white, background: .systemGreen, border: .systemGreen)
                case 2:
                    return ColorScheme(text: .white, background: .darkGray, border: .darkGray)
                case 3:
                    return ColorScheme(text: .white, background: .black, border: .black)
                default:
                    return ColorScheme(text: .black, background: .white, border: .white)
                }
            }
        return nil
    }
    
    /// Which text should be displayed when the TagListView is collapsed?
    public func tagListViewCollapsedText(_ tagListView: TagListView) -> String {
        return "Collapsed"
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        
    }
    
}
