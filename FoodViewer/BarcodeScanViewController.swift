//
//  BarcodeScanViewController.swift
//  FoodViewer
//
//  Created by arnaud on 14/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import AVFoundation

class BarcodeScanViewController: RSCodeReaderViewController, UITextFieldDelegate, KeyboardDelegate {
    
    private let preferences = Preferences.manager
    
    private var currentBarcode: String = ""
    
    private var timer = Timer()
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(scanBarcodes), userInfo: nil, repeats: false)
    }
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            setupProductType()
            searchTextField.delegate = self
        }
    }
    
    @IBOutlet weak var productView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var frontImageView: UIImageView!
    
    @IBOutlet weak var brandLabel: UILabel!
    
    @IBOutlet weak var quantityLabel: UILabel!
    
    @IBOutlet weak var nutriScoreView: NutriScoreView!
    
    @IBOutlet weak var NOVALabel: UILabel! {
        didSet {
            NOVALabel.text = "nova"
        }
    }
    
    @IBOutlet weak var NOVAValueLabel: UILabel!
    
    @IBOutlet weak var fatLabel: UILabel! {
        didSet {
            fatLabel.text = NutritionFactItem.init(nutrient: .fat, unit: .Gram).itemName
        }
    }
    
    @IBOutlet weak var saturatedFatLabel: UILabel! {
        didSet {
            saturatedFatLabel.text = NutritionFactItem.init(nutrient: .saturatedFat, unit: .Gram).itemName
        }
    }
    
    @IBOutlet weak var sugarLabel: UILabel! {
        didSet {
            sugarLabel.text = NutritionFactItem.init(nutrient: .sugars, unit: .Gram).itemName
        }
    }
    
    @IBOutlet weak var saltLabel: UILabel! {
        didSet {
            saltLabel.text = NutritionFactItem.init(nutrient: .salt, unit: .Gram).itemName
        }
    }
    
    @IBOutlet weak var viewProductButton: UIButton! {
        didSet {
            viewProductButton.setTitle(TranslatableStrings.Details, for: .normal)
        }
    }
    
    @IBAction func viewProductButtonTapped(_ sender: UIButton) {
        self.switchToHistoryTab()
    }
    
    @IBOutlet weak var instructionView: UIView!
    
    @IBOutlet weak var instructionTextView: UITextView! {
        didSet {
            instructionTextView.text = TranslatableStrings.ScanInstruction
        }
    }
    
    private var nova: String? = nil {
        didSet {
            if let validNova = nova {
                switch validNova {
                case "1":
                    NOVAValueLabel.text = nova
                    NOVAValueLabel.textColor = .white
                    NOVAValueLabel.backgroundColor = .green
               case "2":
                    NOVAValueLabel.text = nova
                    NOVAValueLabel.textColor = .white
                    NOVAValueLabel.backgroundColor = .yellow
                case "3":
                    NOVAValueLabel.text = nova
                    NOVAValueLabel.textColor = .white
                    NOVAValueLabel.backgroundColor = .orange
                case "4":
                    NOVAValueLabel.text = nova
                    NOVAValueLabel.textColor = .white
                    NOVAValueLabel.backgroundColor = .red
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
    
    
    func initializeCustomKeyboard() {
        // initialize custom keyboard
        let keyboardView = Keyboard(frame: CGRect(x: 0, y: 0, width: 0, height: 300))
        
        searchTextField.inputView = keyboardView
        
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
        if let validBarcode = activeTextField.text,
            !validBarcode.isEmpty,
            validBarcode.count == 8 ||
            validBarcode.count == 13 ||
            validBarcode.count == 10 {
            self.scannedProductPair = self.products.createProductPair(with:BarcodeType(barcodeString:validBarcode, type: preferences.showProductType))
            showProductData()
        }
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
        } else {
            assert(true, "BarcodeScanViewController:switchToTab:with: TabBar hierarchy error")
        }
    }
    
    @objc func scanBarcodes() {
        self.barcodesHandler = { barcodes in
            for barcode in barcodes {
                // Is this a new barcode?
                if let validBarcode = barcode.stringValue,
                    validBarcode != self.currentBarcode {
                    self.currentBarcode = validBarcode
                    self.scannedProductPair = self.products.createProductPair(with:BarcodeType(typeCode: barcode.type.rawValue, value:validBarcode, type: self.preferences.showProductType))
                    print("Barcode found: type= " +  barcode.type.rawValue + " value=" + self.currentBarcode)
                    // create this barcode in the history and launch te fetch
                    DispatchQueue.main.async(execute: {
                        if let continuousScanIsSet = ContinuousScanDefaults.manager.allowContinuousScan,
                            continuousScanIsSet {
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
            if let validFetchResult = scannedProductPair?.status  {
                switch validFetchResult {
                case .available, .updated:
                    self.nameLabel.text = scannedProductPair?.localProduct?.name ?? scannedProductPair?.remoteProduct?.name ?? TranslatableStrings.NoName
                    self.brandLabel.text = scannedProductPair?.brand ?? TranslatableStrings.NoBrandsIndicated
                    self.quantityLabel.text = scannedProductPair?.localProduct?.quantity ?? scannedProductPair?.remoteProduct?.quantity
                    self.nova = scannedProductPair?.localProduct?.novaGroup ?? scannedProductPair!.remoteProduct?.novaGroup
                    self.score = scannedProductPair?.remoteProduct?.nutritionGrade ?? scannedProductPair?.localProduct?.nutritionGrade
                    
                    if let nutritionLevels = scannedProductPair?.remoteProduct?.nutritionScore ?? scannedProductPair?.localProduct?.nutritionScore {
                        for level in nutritionLevels {
                            switch level.0 {
                            case .fat:
                                switch level.1 {
                                case .low:
                                    self.fatLabel.backgroundColor = .green
                                case .moderate:
                                    self.fatLabel.backgroundColor = .orange
                                case .high:
                                    self.fatLabel.backgroundColor = .red
                                default:
                                    break
                                }
                            case .saturatedFat:
                                switch level.1 {
                                case .low:
                                    self.saturatedFatLabel.backgroundColor = .green
                                case .moderate:
                                    self.saturatedFatLabel.backgroundColor = .orange
                                case .high:
                                    self.saturatedFatLabel.backgroundColor = .red
                                default:
                                    break
                                }
                            case .sugar:
                                switch level.1 {
                                case .low:
                                    self.sugarLabel.backgroundColor = .green
                                case .moderate:
                                    self.sugarLabel.backgroundColor = .orange
                                case .high:
                                    self.sugarLabel.backgroundColor = .red
                                default:
                                    break
                                }
                            case .salt:
                                switch level.1 {
                                case .low:
                                    self.saltLabel.backgroundColor = .green
                                case .moderate:
                                    self.saltLabel.backgroundColor = .orange
                                case .high:
                                    self.saltLabel.backgroundColor = .red
                                default:
                                    break
                                }
                            default:
                                break
                            }
                            productView.backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)

                            if let validProduct = scannedProductPair?.remoteProduct?.tracesInterpreted ?? scannedProductPair?.localProduct?.tracesInterpreted {
                                switch validProduct {
                                case .available(let validKeys):
                                    if (!validKeys.isEmpty) && (AllergenWarningDefaults.manager.hasValidWarning(validKeys)) {
                                        productView.backgroundColor = UIColor.init(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
                                    }
                                default:
                                    break
                                }
                            }
                            if let validProduct = scannedProductPair?.remoteProduct?.allergensInterpreted ?? scannedProductPair?.localProduct?.allergensInterpreted {
                                switch validProduct {
                                case .available(let validKeys):
                                    if (!validKeys.isEmpty) && (AllergenWarningDefaults.manager.hasValidWarning(validKeys)) {
                                        productView.backgroundColor = UIColor.init(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
                                    }
                                default:
                                    break
                                }
                            }
                        }
                    }
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

                case .productNotAvailable:
                    self.nameLabel.text = TranslatableStrings.ProductNotAvailable
                case .loadingFailed(let error):
                    self.nameLabel.text = error
                default:
                    break
                }
            }
    }
    
    private func setupScanning() {
        self.focusMarkLayer.strokeColor = UIColor.red.cgColor
        
        self.cornersLayer.strokeColor = UIColor.yellow.cgColor
        
        // MARK: NOTE: If you want to detect specific barcode types, you should update the types
        var types = self.output.availableMetadataObjectTypes
        // MARK: NOTE: Uncomment the following line to remove QRCode scanning capability
        types = types.filter({ $0 != AVMetadataObject.ObjectType.qr })
        types = types.filter({ $0 != AVMetadataObject.ObjectType.pdf417 })
        types = types.filter({ $0 != AVMetadataObject.ObjectType.aztec })
        types = types.filter({ $0 != AVMetadataObject.ObjectType.dataMatrix })
        self.output.metadataObjectTypes = types
    }

    private func setupProductType() {
        
        nameLabel.text = TranslatableStrings.PointCamera
        switch preferences.showProductType {
        case .food:
            searchTextField?.placeholder = TranslatableStrings.EnterFoodProductBarcode
        case .petFood:
            searchTextField?.placeholder = TranslatableStrings.EnterPetFoodProductBarcode
        case .beauty:
            searchTextField?.placeholder = TranslatableStrings.EnterBeautyProductBarcode
        case .product:
            searchTextField?.placeholder = TranslatableStrings.EnterProductBarcode
        }
        switch preferences.showProductType {
        case .food:
            nutriScoreView?.isHidden = false
            NOVALabel?.isHidden = false
            NOVAValueLabel?.isHidden = false
            fatLabel?.isHidden = false
            saturatedFatLabel?.isHidden = false
            sugarLabel?.isHidden = false
            saltLabel?.isHidden = false
        default:
            nutriScoreView?.isHidden = true
            NOVALabel?.isHidden = true
            NOVAValueLabel?.isHidden = true
            fatLabel?.isHidden = true
            saturatedFatLabel?.isHidden = true
            sugarLabel?.isHidden = true
            saltLabel?.isHidden = true
        }
        productView.backgroundColor = UIColor.black
    }
    
    // function is called if an product image has been retrieved via an asynchronous process
    @objc func imageSet(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo
        guard userInfo != nil else { return }
        
        // only update if the image barcode corresponds to the current product
        if let barcodeString = userInfo![ProductImageData.Notification.BarcodeKey] as? String,
            let validProductPair = scannedProductPair,
            validProductPair.barcodeType.asString == barcodeString {
            showProductData()
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
            // start out with the recents tab
            tabVC.selectedIndex = 0
            tabVC.delegate = self
        }
    }
    
    private func setupViews() {
        DispatchQueue.main.async(execute: {
            if self.scannedProductPair == nil {
                self.instructionView.isHidden = false
                self.productView.isHidden = !self.instructionView.isHidden
            } else {
                self.instructionView.isHidden = true
                self.productView.isHidden = !self.instructionView.isHidden
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScanning()
        scanBarcodes()
        setupProductType()
        setupViews()
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(BarcodeScanViewController.doubleTapOnProductView))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.numberOfTouchesRequired = 1
        doubleTapGestureRecognizer.cancelsTouchesInView = false
        doubleTapGestureRecognizer.delaysTouchesBegan = true      //Important to add
        productView.addGestureRecognizer(doubleTapGestureRecognizer)

        initializeCustomKeyboard()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector:#selector(BarcodeScanViewController.showProductData), name:.ProductPairRemoteStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(BarcodeScanViewController.showProductData), name:.ProductPairLocalStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BarcodeScanViewController.imageSet(_:)), name: .ImageSet, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
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
