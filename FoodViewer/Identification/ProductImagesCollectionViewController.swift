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

    private struct Section {
        static let FrontImages = 0
        static let IngredientsImages = 1
        static let NutrionImages = 2
        static let OriginalImages = 3
    }
    // MARK: - public variables
    
    var productPair: ProductPair? {
        didSet {

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
            if let product = productPair?.remoteProduct {
                newImages = product.images
            }
            if let images = productPair?.localProduct?.images,
                images.count > 0 {
                newImages = images.merging(images, uniquingKeysWith: { (first, last) in last } )
            }
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
            if let validProductPair = productPair {
                //TODO: OFFProducts.manager.reload(validProduct)
            }
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
        struct HeaderTitle {
            static let Front = TranslatableStrings.SelectedFrontImages
            static let Ingredients = TranslatableStrings.SelectedIngredientImages
            static let Nutrition = TranslatableStrings.SelectedNutritionImages
            static let Original = TranslatableStrings.OriginalImages
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
        return 4
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let remoteProduct = productPair?.remoteProduct else { return 0 }
        // If there are updated images, only show those
        switch section {
        case Section.FrontImages:
            return productPair?.localProduct?.frontImages != nil && productPair!.localProduct!.frontImages.count > 0 ? productPair!.localProduct!.frontImages.count : remoteProduct.frontImages.count
        case Section.IngredientsImages:
            return productPair?.localProduct?.ingredientsImages != nil && productPair!.localProduct!.ingredientsImages.count > 0 ? productPair!.localProduct!.ingredientsImages.count : remoteProduct.ingredientsImages.count
        case Section.NutrionImages:
            return productPair?.localProduct?.nutritionImages != nil && productPair!.localProduct!.nutritionImages.count > 0 ? productPair!.localProduct!.nutritionImages.count : remoteProduct.nutritionImages.count
        case Section.OriginalImages:
            // Allow the user to add an image when in editMode
            return editMode ? originalImages.count + 1 : originalImages.count
        default:
            assert(false, "ProductImagesCollectionViewController: unexpected number of sections")
        }
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case Section.FrontImages: // Front Images
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.GalleryImageCell, for: indexPath) as! GalleryCollectionViewCell
            if let images = productPair?.localProduct?.frontImages {
                if images.count > 0 && indexPath.row < images.count {
                    let key = keyTuples(for:Array(images.keys))[indexPath.row].0
                    if let validImage = images[key]?.original?.image {
                        cell.imageView.image = validImage
                    } else {
                        cell.imageView.image = UIImage.init(named:"NotOK")
                        
                    }
                    cell.label.text = keyTuples(for:Array(images.keys))[indexPath.row].1
                }
                
            } else {
                if indexPath.row < productPair!.remoteProduct!.frontImages.count {
                    let key = keyTuples(for:Array(productPair!.remoteProduct!.frontImages.keys))[indexPath.row].0
                    if let result = productPair!.remoteProduct!.frontImages[key]?.display?.fetch() {
                        switch result {
                        case .available:
                            if let validImage = productPair!.remoteProduct!.frontImages[key]?.display?.image {
                                cell.imageView.image = validImage
                            }
                        default:
                            cell.imageView.image = UIImage.init(named:"NotOK")
                        }
                        cell.label.text = keyTuples(for:Array(productPair!.remoteProduct!.frontImages.keys))[indexPath.row].1
                    } else {
                        assert(false, "ProductImagesCollectionViewController: indexPath.row frontImages to large")
                    }
                }
            }
            cell.indexPath = indexPath
            cell.editMode = editMode
            cell.delegate = self
            return cell
        
        case Section.IngredientsImages:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.GalleryImageCell, for: indexPath) as! GalleryCollectionViewCell
            if let images = productPair?.localProduct?.ingredientsImages  {
                if indexPath.row < images.count && images.count > 0 {
                    let key = keyTuples(for:Array(images.keys))[indexPath.row].0
                    if let validImage = images[key]?.original?.image {
                        cell.imageView.image = validImage
                    } else {
                        cell.imageView.image = UIImage.init(named:"NotOK")
                        
                    }

                    cell.label.text = keyTuples(for:Array(images.keys))[indexPath.row].1
                }
            } else {
                if indexPath.row < productPair!.remoteProduct!.ingredientsImages.count {
                    let key = keyTuples(for:Array(productPair!.remoteProduct!.ingredientsImages.keys))[indexPath.row].0
                    if let result = productPair!.remoteProduct!.ingredientsImages[key]?.display?.fetch() {
                        switch result {
                        case .available:
                            if let validImage = productPair!.remoteProduct!.ingredientsImages[key]?.display?.image {
                                cell.imageView.image = validImage
                            }
                        default:
                            cell.imageView.image = UIImage.init(named:"NotOK")
                        }
                        cell.label.text = keyTuples(for:Array(productPair!.remoteProduct!.ingredientsImages.keys))[indexPath.row].1
                    } else {
                        assert(true, "ProductImagesCollectionViewController: indexPath.row ingredientsImages to large")
                    }
                }
            }
            cell.indexPath = indexPath
            cell.editMode = editMode
            cell.delegate = self
            return cell
            
        case Section.NutrionImages:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.GalleryImageCell, for: indexPath) as! GalleryCollectionViewCell
            if let images = productPair?.localProduct?.nutritionImages {
                if indexPath.row < images.count && images.count > 0 {
                    let key = keyTuples(for:Array(images.keys))[indexPath.row].0
                    if let validImage = images[key]?.original?.image {
                        cell.imageView.image = validImage
                    } else {
                        cell.imageView.image = UIImage.init(named:"NotOK")
                    }
                    cell.label.text = keyTuples(for:Array(images.keys))[indexPath.row].1
                }
            } else {
                if indexPath.row < productPair!.remoteProduct!.nutritionImages.count {
                    let key = keyTuples(for:Array(productPair!.remoteProduct!.nutritionImages.keys))[indexPath.row].0
                    if let result = productPair!.remoteProduct!.nutritionImages[key]?.display?.fetch() {
                        switch result {
                        case .available:
                            if let validImage = productPair!.remoteProduct!.nutritionImages[key]?.display?.image {
                                cell.imageView.image = validImage
                            }
                        default:
                            cell.imageView.image = UIImage.init(named:"NotOK")
                        }
                        cell.label.text = keyTuples(for:Array(productPair!.remoteProduct!.nutritionImages.keys))[indexPath.row].1
                    }
                } else {
                    assert(true, "ProductImagesCollectionViewController: indexPath.row nutritionImages to large")
                }
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
            //3
            switch indexPath.section {
            case Section.FrontImages:
                headerView.label.text = productPair?.localProduct?.frontImages != nil && productPair!.localProduct!.frontImages.count > 0 ?
                    Storyboard.HeaderTitle.Front + " (" + TranslatableStrings.Edited + ")" : Storyboard.HeaderTitle.Front
            case Section.IngredientsImages:
                headerView.label.text =  productPair?.localProduct?.ingredientsImages != nil && productPair!.localProduct!.ingredientsImages.count > 0 ?
                    Storyboard.HeaderTitle.Ingredients + " (" + TranslatableStrings.Edited + ")" : Storyboard.HeaderTitle.Ingredients
            case Section.NutrionImages:
                headerView.label.text =  productPair?.localProduct?.nutritionImages != nil && productPair!.localProduct!.nutritionImages.count > 0 ?
                    Storyboard.HeaderTitle.Nutrition + " (" + TranslatableStrings.Edited + ")" : Storyboard.HeaderTitle.Nutrition
            case Section.OriginalImages:
                headerView.label.text = Storyboard.HeaderTitle.Original
            default:
                assert(true, "ProductImagesCollectionViewController: unexpected number of sections")
            }
            
        default:
            //4
            assert(false, "ProductImagesCollectionViewController: Unexpected element kind")
        }
        return headerView
    }

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    // Uncomment this method to specify if the specified item should be selected
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

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

    
    // MARK: - Segue stuff
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.SegueIdentifier.ShowImage:
                if let vc = segue.destination as? ImageViewController {
                    guard selectedImage != nil else { return }
                    switch selectedImage!.section {
                    case Section.FrontImages:
                        let languageCode = Array(productPair!.remoteProduct!.frontImages.keys.sorted(by: { $0 < $1 }))[selectedImage!.row]
                        vc.imageData = productPair!.remoteProduct!.image(for:languageCode, of:.front)
                        vc.imageTitle = OFFplists.manager.languageName(for:languageCode)
                        
                    case Section.IngredientsImages:
                        let languageCode = Array(productPair!.remoteProduct!.ingredientsImages.keys.sorted(by: { $0 < $1 }))[selectedImage!.row]
                        vc.imageData = productPair!.remoteProduct!.image(for:languageCode, of:.ingredients)
                        vc.imageTitle = OFFplists.manager.languageName(for:languageCode)
                        
                    case Section.NutrionImages:
                        let languageCode = Array(productPair!.remoteProduct!.nutritionImages.keys.sorted(by: { $0 < $1 }))[selectedImage!.row]
                        vc.imageData = productPair!.remoteProduct!.image(for:languageCode, of:.nutrition)
                        vc.imageTitle = OFFplists.manager.languageName(for:languageCode)
                        
                    case Section.OriginalImages:
                        let key = Array(productPair!.remoteProduct!.images.keys.sorted(by: { Int($0)! < Int($1)! }))[selectedImage!.row]
                        vc.imageData = productPair!.remoteProduct!.images[key]?.largest
                        vc.imageTitle = key
                        
                    default:
                        assert(false, "ProductImagesCollectionViewController: inexisting section")
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
                if let result = originalImages[validKey]?.display?.fetch() {
                    switch result {
                    case .available:
                        
                        if let validImage = originalImages[validKey]?.display?.image {
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
                //TODO: OFFProducts.manager.reload(self.product!)
                // THis will result in a new notification if successfull, which will load the new images in turn
            }
        }
    }

    @objc func imageDeleted(_ notification: Notification) {
        // Check if this image was relevant to this product
        if let barcode = notification.userInfo?[OFFUpdate.Notification.ImageDeleteSuccessBarcodeKey] as? String {
            if barcode == productPair!.barcodeType.asString {
                // reload product data
                //TODO: OFFProducts.manager.reload(self.product!)
                // This will result in a new notification if successfull, which will load the new images in turn
            }
        }
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector:#selector(ProductImagesCollectionViewController.reloadImages), name:.ImageSet, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductImagesCollectionViewController.reloadImages), name:.ProductUpdated, object:nil)
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
            switch validIndexPath.section {
            case Section.FrontImages:
                let languageCode = keyTuples(for:Array(productPair!.remoteProduct!.frontImages.keys))[validIndexPath.row].0
                let update = OFFUpdate()
                update.deselect([languageCode], of: .front, for: productPair!.remoteProduct!)
            case Section.IngredientsImages:
                let languageCode = keyTuples(for:Array(productPair!.remoteProduct!.ingredientsImages.keys))[validIndexPath.row].0
                let update = OFFUpdate()
                update.deselect([languageCode], of: .ingredients, for: productPair!.remoteProduct!)
            case Section.NutrionImages:
                let languageCode = keyTuples(for:Array(productPair!.remoteProduct!.nutritionImages.keys))[validIndexPath.row].0
                let update = OFFUpdate()
                update.deselect([languageCode], of: .nutrition, for: productPair!.remoteProduct!)
            default:
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
        
        switch indexPath.section {
        case Section.OriginalImages:
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
        
        switch indexPath.section {
        case Section.OriginalImages:
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
            if validIndexPathSection == Section.OriginalImages {
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
        let indexSet = IndexSet.init(integer: Section.OriginalImages)
        self.collectionView?.reloadSections(indexSet)
    }
}





