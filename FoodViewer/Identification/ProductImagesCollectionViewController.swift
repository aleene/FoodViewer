//
//  ProductImagesCollectionViewController.swift
//  FoodViewer
//
//  Created by arnaud on 11/08/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit
import MobileCoreServices

private let reuseIdentifier = "Cell"

class ProductImagesCollectionViewController: UICollectionViewController {

    fileprivate var tableStructure: [SectionType] = []

    fileprivate enum SectionType {
        case frontImages(String)
        case ingredientsImages(String)
        case nutritionImages(String)
        case originalImages(String)
        
        var header: String {
            switch self {
            case .frontImages(let headerTitle),
                 .ingredientsImages(let headerTitle),
                 .nutritionImages(let headerTitle),
                 .originalImages(let headerTitle):
                return headerTitle
            }
        }
    }
    
    fileprivate func setupSections() -> [SectionType] {
        // The returnValue is an array with sections
        // And each element is a  section type with the number of rows and the section title
        //
        var sectionsAndRows: [SectionType] = []
        
        sectionsAndRows.append(.frontImages(TranslatableStrings.SelectedFrontImages))
        sectionsAndRows.append(.ingredientsImages(TranslatableStrings.SelectedIngredientImages))

        switch Preferences.manager.showProductType {
        case .beauty:
            break
        default:
            sectionsAndRows.append(.nutritionImages(TranslatableStrings.SelectedNutritionImages))
        }
        sectionsAndRows.append(.originalImages(TranslatableStrings.OriginalImages))
        
        return sectionsAndRows
    }
    
    var originalImagesSection: Int? {
        for (index,section) in tableStructure.enumerated() {
            switch section {
            case .originalImages:
                return index
            default:
                break
            }
        }
        return nil
    }
    
    fileprivate enum ProductVersion {
        //case local
        case remote
        case new
    }
    
    // Determines which version of the product needs to be shown, the remote or local
    
    fileprivate var productVersion: ProductVersion = .new//

    // MARK: - public variables
    
    var productPair: ProductPair? {
        didSet {
            tableStructure = setupSections()
        }
    }

    // Needed to show or hide buttons
    var editMode: Bool = false {
        didSet {
            // vc changed from/to editMode, need to repaint
            if editMode != oldValue {
                collectionView?.reloadData()
            }
        }
    }
    
    var languageCode: String? = nil
    
    // Needed to add new images
    var delegate: ProductPageViewController? = nil
    
    // This variable returns an array with tuples.
    // A tuple consists of a languageCode and the corresponding language in the interface language.
    // The array is sorted on the corresponding language
    fileprivate func keyTuples(for keys: [String]) -> [(String, String)] {
        var tuples: [(String, String)] = []
        for key in keys {
            tuples.append((key,OFFplists.manager.languageName(for:key)))
        }
        return tuples.sorted(by: { $0.1 < $1.1 } )
    }
    
    fileprivate var originalImages: [String:ProductImageSize] {
        get {
            var newImages: [String:ProductImageSize] = [:]
            switch productVersion {
            //case .local:
            //    if let validImages = productPair?.localProduct?.images {
            //        newImages = validImages
            //    }
            case .remote:
                if let validImages = productPair?.remoteProduct?.images {
                    newImages = validImages
                }
            case .new:
                if let validImages = productPair?.localProduct?.images {
                    newImages = validImages
                }
                if let validImages = productPair?.remoteProduct?.images {
                    let images = validImages
                    newImages = newImages.merging(images, uniquingKeysWith: { (first, last) in last } )
                }
            }
            //images.count > 0 {
            //newImages = images.merging(images, uniquingKeysWith: { (first, last) in last } )
            return newImages
        }
    }
    
    fileprivate var frontImages: [String:ProductImageSize] {
        get {
            var newImages: [String:ProductImageSize] = [:]
            switch productVersion {
            //case .local:
            //    if let validImages = productPair?.localProduct?.frontImages {
            //        newImages = validImages
            //    }
            case .remote:
                if let validImages = productPair?.remoteProduct?.frontImages {
                    newImages = validImages
                }
            case .new:
                if let validImages = productPair?.localProduct?.frontImages {
                    newImages = validImages
                }
                if let validImages = productPair?.remoteProduct?.frontImages {
                    let images = validImages
                    newImages = newImages.merging(images, uniquingKeysWith: { (first, last) in last } )
                }
            }
            //images.count > 0 {
            //newImages = images.merging(images, uniquingKeysWith: { (first, last) in last } )
            return newImages
        }
    }

    fileprivate var ingredientsImages: [String:ProductImageSize] {
        get {
            var newImages: [String:ProductImageSize] = [:]
            switch productVersion {
            //case .local:
            //    if let validImages = productPair?.localProduct?.ingredientsImages {
             //       newImages = validImages
            //    }
            case .remote:
                if let validImages = productPair?.remoteProduct?.ingredientsImages {
                    newImages = validImages
                }
            case .new:
                if let validImages = productPair?.localProduct?.ingredientsImages {
                    newImages = validImages
                }
                if let validImages = productPair?.remoteProduct?.ingredientsImages {
                    let images = validImages
                    newImages = newImages.merging(images, uniquingKeysWith: { (first, last) in last } )
                }
            }
            //images.count > 0 {
            //newImages = images.merging(images, uniquingKeysWith: { (first, last) in last } )
            return newImages
        }
    }

    fileprivate var nutritionImages: [String:ProductImageSize] {
        get {
            var newImages: [String:ProductImageSize] = [:]
            switch productVersion {
            //case .local:
            //    if let validImages = productPair?.localProduct?.nutritionImages {
            //        newImages = validImages
            //    }
            case .remote:
                if let validImages = productPair?.remoteProduct?.nutritionImages {
                    newImages = validImages
                }
            case .new:
                if let validImages = productPair?.localProduct?.nutritionImages {
                    newImages = validImages
                }
                if let validImages = productPair?.remoteProduct?.nutritionImages {
                    let images = validImages
                    newImages = newImages.merging(images, uniquingKeysWith: { (first, last) in last } )
                }

            }
            //images.count > 0 {
            //newImages = images.merging(images, uniquingKeysWith: { (first, last) in last } )
            return newImages
        }
    }

    fileprivate let itemsPerRow: CGFloat = 5
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)

    private var selectedImage: IndexPath? = nil
    
    // MARK: - Action methods
    
    @IBOutlet weak var addImageFromCameraButton: UIButton!
    
    @IBAction func addImageFromCameraButtonTapped(_ sender: UIButton) {
    }
    
    @IBOutlet weak var addImageFromCameraRollButton: UIButton!
    
    @IBAction func addImageFromCameraRollButtonTapped(_ sender: UIButton) {
    }
    
    var refresher: UIRefreshControl!
    
    // should redownload the current product and reload it in this scene
    @objc private func refresh(sender: Any) {
        if refresher!.isRefreshing {
            OFFProducts.manager.reload(productPair: productPair)
            refresher?.endRefreshing()
        }
    }
    
    // MARK: UICollectionViewDataSource

    fileprivate struct Storyboard {
        struct CellIdentifier {
            static let GalleryImageCell = "Gallery Image Cell"
            static let AddImageCell = "Add Image Cell"
            static let SectionHeader =  "SectionHeaderView"
        }
        struct NibIdentifier {
            static let AddImageCollectionCell = "AddImageCollectionViewCell"
        }
        struct SegueIdentifier {
            static let ShowImage = "Show Image"
            //static let ShowImageSourceSelector = "Show Select Image Source Segue"
            static let ShowLanguageAndImageType = "Show Language And ImageType Segue Identifier"
        }

    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return tableStructure.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        // If there are updated images, only show those
        switch tableStructure[section] {
        case .frontImages:
            return frontImages.count
        case .ingredientsImages:
            return ingredientsImages.count
        case .nutritionImages:
            return nutritionImages.count
        case .originalImages:
            // Allow the user to add an image when in editMode
            return editMode ? originalImages.count + 1 : originalImages.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch tableStructure[indexPath.section] {
        case .frontImages: // Front Images
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.GalleryImageCell, for: indexPath) as! GalleryCollectionViewCell
            if frontImages.count > 0 && indexPath.row < frontImages.count {
                let key = keyTuples(for:Array(frontImages.keys))[indexPath.row].0
                if let result = frontImages[key]?.largest?.fetch() {
                    switch result {
                    case .available:
                        if let validImage = frontImages[key]?.largest?.image {
                            cell.imageView.image = validImage
                        }
                    default:
                        cell.imageView.image = UIImage.init(named:"NotOK")
                    }
                }
                cell.label.text = keyTuples(for:Array(frontImages.keys))[indexPath.row].1
            }
            cell.indexPath = indexPath
            cell.editMode = editMode
            cell.delegate = self
            return cell
        
        case .ingredientsImages:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.GalleryImageCell, for: indexPath) as! GalleryCollectionViewCell
            if indexPath.row < ingredientsImages.count && ingredientsImages.count > 0 {
                let key = keyTuples(for:Array(ingredientsImages.keys))[indexPath.row].0
                if let result = ingredientsImages[key]?.largest?.fetch() {
                    switch result {
                    case .available:
                        if let validImage = ingredientsImages[key]?.largest?.image {
                            cell.imageView.image = validImage
                        }
                    default:
                        cell.imageView.image = UIImage.init(named:"NotOK")
                    }
                }
                cell.label.text = keyTuples(for:Array(ingredientsImages.keys))[indexPath.row].1
            }
            cell.indexPath = indexPath
            cell.editMode = editMode
            cell.delegate = self
            return cell
            
        case .nutritionImages:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.GalleryImageCell, for: indexPath) as! GalleryCollectionViewCell
            if indexPath.row < nutritionImages.count && nutritionImages.count > 0 {
                let key = keyTuples(for:Array(nutritionImages.keys))[indexPath.row].0
                if let result = nutritionImages[key]?.largest?.fetch() {
                    switch result {
                    case .available:
                        if let validImage = nutritionImages[key]?.largest?.image {
                            cell.imageView.image = validImage
                        }
                    default:
                        cell.imageView.image = UIImage.init(named:"NotOK")
                    }
                }
                cell.label.text = keyTuples(for:Array(nutritionImages.keys))[indexPath.row].1
            }
            cell.indexPath = indexPath
            cell.editMode = editMode
            cell.delegate = self
            return cell
            
        default:
            // in editMode the last element of a row is an add button
            if editMode && indexPath.row == originalImages.count {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.AddImageCell, for: indexPath) as! AddImageCollectionViewCell
                cell.addImageFromCameraButton?.addTarget(self, action: #selector(ProductImagesCollectionViewController.takePhotoButtonTapped), for: .touchUpInside)
                cell.addImageFromCameraRoll?.addTarget(self, action: #selector(ProductImagesCollectionViewController.useCameraRollButtonTapped), for: .touchUpInside)

                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.GalleryImageCell, for: indexPath) as! GalleryCollectionViewCell
                let key = Array(originalImages.keys.sorted(by: { Int($0)! < Int($1)! }))[indexPath.row]
            
                if let result = originalImages[key]?.largest?.fetch() {
                 
                    switch result {
                    case .available:
                        if let validImage = originalImages[key]?.largest?.image {
                            cell.imageView.image = validImage
                        }
                    default:
                        cell.imageView.image = UIImage.init(named:"NotOK")
                    }
                    cell.label.text = key
                }
                cell.indexPath = indexPath
                cell.editMode = editMode
                cell.delegate = self
                cell.imageKey = key
                return cell
            }
        }
    }

// MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: Storyboard.CellIdentifier.SectionHeader,
                                                                         for: indexPath) as! GalleryCollectionReusableView
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            var newTitle = tableStructure[indexPath.section].header
            switch productVersion {
            case .new:
                switch tableStructure[indexPath.section] {
                case .frontImages:
                    if productPair?.localProduct?.frontImages != nil && !productPair!.localProduct!.frontImages.isEmpty {
                        newTitle += " (New)"
                    }
                case .ingredientsImages:
                    if productPair?.localProduct?.ingredientsImages != nil && !productPair!.localProduct!.ingredientsImages.isEmpty {
                        newTitle += " (New)"
                    }
                case .nutritionImages:
                    if productPair?.localProduct?.nutritionImages != nil && !productPair!.localProduct!.nutritionImages.isEmpty {
                        newTitle += " (New)"
                    }
                case .originalImages:
                    if productPair?.localProduct?.images != nil && !productPair!.localProduct!.images.isEmpty {
                        newTitle += " (New)"
                    }
                }
            default:
                break
            }
            //3
            headerView.label.text = newTitle

        default:
            //4
            assert(false, "ProductImagesCollectionViewController: Unexpected element kind")
        }
        return headerView
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if editMode && indexPath.row == originalImages.count {
        } else {
            selectedImage = indexPath
            performSegue(withIdentifier: Storyboard.SegueIdentifier.ShowImage, sender: self)
        }
    }
    
    // MARK: - Segue stuff
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.SegueIdentifier.ShowImage:
                if let vc = segue.destination as? ImageViewController {
                    guard selectedImage != nil else { return }
                    switch tableStructure[selectedImage!.section] {
                    case .frontImages:
                        let languageCode = Array(productPair!.remoteProduct!.frontImages.keys.sorted(by: { $0 < $1 }))[selectedImage!.row]
                        vc.imageData = productPair!.remoteProduct!.image(for:languageCode, of:.front)
                        vc.imageTitle = OFFplists.manager.languageName(for:languageCode)
                        
                    case .ingredientsImages:
                        let languageCode = Array(productPair!.remoteProduct!.ingredientsImages.keys.sorted(by: { $0 < $1 }))[selectedImage!.row]
                        vc.imageData = productPair!.remoteProduct!.image(for:languageCode, of:.ingredients)
                        vc.imageTitle = OFFplists.manager.languageName(for:languageCode)
                        
                    case .nutritionImages:
                        let languageCode = Array(productPair!.remoteProduct!.nutritionImages.keys.sorted(by: { $0 < $1 }))[selectedImage!.row]
                        vc.imageData = productPair!.remoteProduct!.image(for:languageCode, of:.nutrition)
                        vc.imageTitle = OFFplists.manager.languageName(for:languageCode)
                        
                    case .originalImages:
                        let key = Array(productPair!.remoteProduct!.images.keys.sorted(by: { Int($0)! < Int($1)! }))[selectedImage!.row]
                        vc.imageData = productPair!.remoteProduct!.images[key]?.largest
                        vc.imageTitle = key
                    }
                }
            case Storyboard.SegueIdentifier.ShowLanguageAndImageType:
                if let vc = segue.destination as? SelectLanguageAndImageTypeViewController,
                    let button = sender as? UIButton {
                    if let cell = button.superview?.superview as? GalleryCollectionViewCell {
                        if let ppc = vc.popoverPresentationController {
                            // set the main language button as the anchor of the popOver
                            ppc.permittedArrowDirections = .any
                            // I need the button coordinates in the coordinates of the current controller view
                            let anchorFrame = button.convert(button.bounds, to: self.collectionView)
                            ppc.sourceRect = anchorFrame // bottomCenter(anchorFrame)
                            ppc.delegate = self
                            
                            vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                            vc.languageCodes = productPair!.remoteProduct!.languageCodes
                            vc.key = cell.imageKey
                        }
                    }
                }
            default: break
            }
        }
    }

    @IBAction func unwindSetImageTypeAndLanguageForDone(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? SelectLanguageAndImageTypeViewController {
            if let selectedLanguageCode = vc.selectedLanguageCode,
                let selectedImageTypeCategory = vc.selectedImageCategory,
                let validKey = vc.key {
                
                // let key = Array(originalImages.keys.sorted(by: { Int($0)! < Int($1)! }))[validKey]
                if let result = originalImages[validKey]?.largest?.fetch() {
                    switch result {
                    case .available:
                        
                        if let validImage = originalImages[validKey]?.largest?.image {
                            switch selectedImageTypeCategory {
                            case .front:
                                productPair?.update(frontImage: validImage, for: selectedLanguageCode)
                            case .ingredients:
                                productPair?.update(ingredientsImage: validImage, for: selectedLanguageCode)
                            case .nutrition:
                                productPair?.update(nutritionImage: validImage, for: selectedLanguageCode)
                            default:
                                return
                            }
                        }
                    default:
                        return
                    }
                    reloadImages()
                }
            }
        }
    }

    
    @objc func takePhotoButtonTapped() {
        // opens the camera and allows the user to take an image and crop
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.cropSize = CGSize.init(width: 300, height: 300)
            imagePicker.hasResizeableCropArea = true
            imagePicker.delegate = self
            imagePicker.imagePickerController?.modalPresentationStyle = .fullScreen
            imagePicker.sourceType = .camera
            
            present(imagePicker.imagePickerController!, animated: true, completion: nil)
            if let popoverPresentationController = imagePicker.imagePickerController!.popoverPresentationController {
                if let frame = collectionView?.frame {
                    popoverPresentationController.sourceRect = frame
                }
                popoverPresentationController.permittedArrowDirections = .any
            }
        }
    }
    
    
    fileprivate lazy var imagePicker: GKImagePicker = {
        let picker = GKImagePicker.init()
        picker.imagePickerController = UIImagePickerController.init()
        // picker.mediaTypes = [kUTTypeImage as String]
        return picker
    }()

    @objc func useCameraRollButtonTapped() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.cropSize = CGSize.init(width: 300, height: 300)
            imagePicker.hasResizeableCropArea = true
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.imagePickerController!.modalPresentationStyle = .fullScreen
            
            present(imagePicker.imagePickerController!, animated: true, completion: nil)
            if let popoverPresentationController = imagePicker.imagePickerController!.popoverPresentationController {
                if let frame = collectionView?.frame {
                    popoverPresentationController.sourceRect = frame
                }
                popoverPresentationController.sourceView = self.view
                popoverPresentationController.permittedArrowDirections = .any
            }
        }
    }
    
    
    fileprivate func newImageSelected(info: [String : Any]) {
        var image: UIImage? = nil
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
    }

    @objc func reloadImages() {
        collectionView?.reloadData()
    }

    @objc func reloadProduct(_ notification: Notification) {
        // Check if this image was relevant to this product
        if let barcode = notification.userInfo?[OFFUpdate.Notification.ImageUploadSuccessBarcodeKey] as? String {
            if barcode == productPair!.barcodeType.asString {
                // reload product data
                OFFProducts.manager.reload(productPair: productPair)
                // This will result in a new notification if successfull, which will load the new images in turn
            }
        }
    }

    @objc func imageDeleted(_ notification: Notification) {
        // Check if this image was relevant to this product
        if let barcode = notification.userInfo?[OFFUpdate.Notification.ImageDeleteSuccessBarcodeKey] as? String {
            if barcode == productPair!.barcodeType.asString {
                // reload product data
                OFFProducts.manager.reload(productPair: productPair)
                // This will result in a new notification if successfull, which will load the new images in turn
            }
        }
    }
    
    @objc func doubleTapOnTableView() {
        switch productVersion {
        case .remote:
            //productVersion = .local
            //delegate?.title = TranslatableStrings.Gallery + " (Local)"
        //case .local:
            productVersion = .new
            delegate?.title = TranslatableStrings.Gallery + " (New)"
        case .new:
            productVersion = .remote
            delegate?.title = TranslatableStrings.Gallery + " (OFF)"
        }
        collectionView?.reloadData()
    }

    func registerCollectionViewCell() {
        guard let collectionView = self.collectionView else
        {
            print("We don't have a reference to the collection view.")
            return
        }
        
        let nib = UINib(nibName: Storyboard.NibIdentifier.AddImageCollectionCell, bundle: Bundle.main)
        
        collectionView.register(nib, forCellWithReuseIdentifier: Storyboard.CellIdentifier.AddImageCell)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.red
        self.refresher.addTarget(self, action: #selector(ProductImagesCollectionViewController.refresh(sender:)), for: .valueChanged)
        self.collectionView?.addSubview(refresher)
        self.collectionView?.delegate = self
        if #available(iOS 11.0, *) {
            self.collectionView?.dragDelegate = self
            self.collectionView?.dropDelegate = self
        }
        
        registerCollectionViewCell()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Add doubletapping to the TableView. Any double tap on headers is now received,
        // and used for changing the productVersion (local and remote)
        let doubleTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(ProductImagesCollectionViewController.doubleTapOnTableView))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.numberOfTouchesRequired = 1
        doubleTapGestureRecognizer.cancelsTouchesInView = false
        doubleTapGestureRecognizer.delaysTouchesBegan = true      //Important to add
        collectionView?.addGestureRecognizer(doubleTapGestureRecognizer)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        delegate?.title = TranslatableStrings.Gallery

        NotificationCenter.default.addObserver(self, selector:#selector(ProductImagesCollectionViewController.reloadImages), name:.ImageSet, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductImagesCollectionViewController.reloadImages), name:.ProductUpdateSucceeded, object:nil)

        NotificationCenter.default.addObserver(self, selector:#selector(ProductImagesCollectionViewController.reloadImages), name:.RemoteStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductImagesCollectionViewController.reloadProduct), name:.OFFUpdateImageUploadSuccess, object:nil)
        //NotificationCenter.default.addObserver(self, selector:#selector(ProductImagesCollectionViewController.reloadProduct(_:)), name:.OFFUpdateImageDeleteSuccess, object:nil)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: - UICollectionViewDelegateFlowLayout Functions

extension ProductImagesCollectionViewController : GalleryCollectionViewCellDelegate {
    
    // function to let the delegate know that the deselect button has been tapped
    func galleryCollectionViewCell(_ sender: GalleryCollectionViewCell, receivedTapOn button:UIButton) {
        if let validIndexPath = sender.indexPath {
            switch tableStructure[validIndexPath.section] {
            case .frontImages:
                let languageCode = keyTuples(for:Array(productPair!.remoteProduct!.frontImages.keys))[validIndexPath.row].0
                let update = OFFUpdate()
                update.deselect([languageCode], of: .front, for: productPair!)
            case .ingredientsImages:
                let languageCode = keyTuples(for:Array(productPair!.remoteProduct!.ingredientsImages.keys))[validIndexPath.row].0
                let update = OFFUpdate()
                update.deselect([languageCode], of: .ingredients, for: productPair!)
            case .nutritionImages:
                let languageCode = keyTuples(for:Array(productPair!.remoteProduct!.nutritionImages.keys))[validIndexPath.row].0
                let update = OFFUpdate()
                update.deselect([languageCode], of: .nutrition, for: productPair!)
            case .originalImages:
                performSegue(withIdentifier: Storyboard.SegueIdentifier.ShowLanguageAndImageType, sender: button)
            }
        }
    }
}


// MARK: - UICollectionViewDelegateFlowLayout Functions

extension ProductImagesCollectionViewController : UICollectionViewDelegateFlowLayout {
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

// MARK: - UIPopoverPresentationControllerDelegate Functions

extension ProductImagesCollectionViewController: UIPopoverPresentationControllerDelegate {
    
    // MARK: - Popover delegation functions
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navcon = UINavigationController(rootViewController: controller.presentedViewController)
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        visualEffectView.frame = navcon.view.bounds
        navcon.view.insertSubview(visualEffectView, at: 0)
        return navcon
    }
    
}

extension ProductImagesCollectionViewController: GKImagePickerDelegate {
    
    func imagePicker(_ imagePicker: GKImagePicker, cropped image: UIImage) {
        
        // print("front image", image.size)
        let newImageID = "\(originalImages.count + 1)"
        productPair?.update(image: image, id: newImageID)
        
        collectionView?.reloadData()
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIDragInteractionDelegate Functions

extension ProductImagesCollectionViewController: UICollectionViewDragDelegate {
    
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {

        // Do not allow dragging in editMode
        if editMode {
            return []
        }
        
        switch tableStructure[indexPath.section] {
        case .originalImages:
            let key = Array(originalImages.keys.sorted(by: { Int($0)! < Int($1)! }))[indexPath.row]
                
            if let validImageData = originalImages[key]?.largest {
                let provider = NSItemProvider(object: validImageData)
                let item = UIDragItem(itemProvider: provider)
                return [item]
            }
        default:
            break
        }
        return []
    }
    
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        
        // do not allow flocking in editMode
        if editMode { return [] }
        
        // only allow flocking of another image
        for item in session.items {
            // Note kUTTypeImage needs an import of MobileCoreServices
            guard item.itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) else { return [] }
        }
        
        switch tableStructure[indexPath.section] {
        case .originalImages:
            let key = Array(originalImages.keys.sorted(by: { Int($0)! < Int($1)! }))[indexPath.row]
            
            if let validProductImageData = originalImages[key]?.largest {
                let provider = NSItemProvider(object: validProductImageData)
                // check if the selected image has not been added yet
                for item in session.items {
                    guard item.localObject as! ProductImageData != validProductImageData else { return [] }
                }
                let item = UIDragItem(itemProvider: provider)
                return [item]
            }
        default:
            break
        }
        return []
    }
    
    // Use the image in the GalleryCollectionViewCell as lift preview
    // Out of the box targeting is taken care of and animations as well
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        if let cell = collectionView.cellForItem(at: indexPath) as? GalleryCollectionViewCell,
            let rect = cell.imageView.imageRect {
            let parameters = UIDragPreviewParameters.init()
            parameters.visiblePath = UIBezierPath(roundedRect: rect, cornerRadius: 15)
            return parameters
        }
        return nil
    }
}

// MARK: - UITableViewDropDelegate Functions

@available(iOS 11.0, *)
extension ProductImagesCollectionViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        coordinator.session.loadObjects(ofClass: UIImage.self) { (images) in
            
            func setImage(image: UIImage, id: String) {
                let cropController = GKImageCropViewController.init()
                cropController.sourceImage = image
                cropController.view.frame = collectionView.frame
                //cropController.preferredContentSize = picker.preferredContentSize
                cropController.hasResizableCropArea = true
                cropController.cropSize = CGSize.init(width: 300, height: 300)
                cropController.delegate = self
                cropController.identifier = id
                cropController.modalPresentationStyle = .fullScreen
                
                self.present(cropController, animated: true, completion: nil)
                if let popoverPresentationController = cropController.popoverPresentationController {
                    popoverPresentationController.sourceRect = collectionView.frame
                    popoverPresentationController.sourceView = self.view
                }
            }
            
            // Only one image is accepted as ingredients image for the current language
            for image in images {
                let newImageID = "\(self.originalImages.count + 1)"
                setImage(image: image as! UIImage, id: newImageID)
                //self.delegate?.updated(image: image as! UIImage, id: newImageID)
                //let indexSet = IndexSet.init(integer: Section.OriginalImages)
                //self.collectionView?.reloadSections(indexSet)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        
        // Only accept if an image is hovered above the original images section
        if let validIndexPathSection = destinationIndexPath?.section {
            if validIndexPathSection == originalImagesSection {
                return editMode ? UICollectionViewDropProposal(operation: .copy, intent: .unspecified) : UICollectionViewDropProposal(operation: .forbidden, intent: .unspecified)
            }
        }
        return UICollectionViewDropProposal(operation: .cancel, intent: .unspecified)
    }
    
}


// MARK: - GKImageCropController Delegate Methods

extension ProductImagesCollectionViewController: GKImageCropControllerDelegate {
    
    public func imageCropController(_ imageCropController: GKImageCropViewController, didFinishWith croppedImage: UIImage?) {
        guard let validImage = croppedImage,
        let validId = imageCropController.identifier else { return }
        imageCropController.dismiss(animated: true, completion: nil)
        productPair?.update(image: validImage, id: validId)
        if let validIndex = originalImagesSection {
            let indexSet = IndexSet.init(integer: validIndex)
            self.collectionView?.reloadSections(indexSet)
        }
    }
}





