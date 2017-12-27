//
//  ProductImagesCollectionViewController.swift
//  FoodViewer
//
//  Created by arnaud on 11/08/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ProductImagesCollectionViewController: UICollectionViewController {

    private struct Section {
        static let FrontImages = 0
        static let IngredientsImages = 1
        static let NutrionImages = 2
        static let OriginalImages = 3
    }
    // MARK: - public variables
    
    var product: FoodProduct? {
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
            guard product != nil else { return [:] }
            return product!.images
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
            if let validProduct = product {
                OFFProducts.manager.reload(validProduct)
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
            static let Front = NSLocalizedString("Selected Front Images", comment: "Gallery header text presenting the selected front images")
            static let Ingredients = NSLocalizedString("Selected Ingredients Images", comment: "Gallery header text presenting the selected ingredients images")
            static let Nutrition = NSLocalizedString("Selected Nutrition Images", comment: "Gallery header text presenting the selected nutrition images")
            static let Original = NSLocalizedString("Original Images", comment: "Gallery header text presenting the original images")
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
        guard product != nil else { return 0 }
        // If there are updated images, only show those
        switch section {
        case Section.FrontImages:
            return delegate?.updatedProduct?.frontImages != nil && delegate!.updatedProduct!.frontImages.count > 0 ? delegate!.updatedProduct!.frontImages.count : product!.frontImages.count
        case Section.IngredientsImages:
            return delegate?.updatedProduct?.ingredientsImages != nil && delegate!.updatedProduct!.ingredientsImages.count > 0 ? delegate!.updatedProduct!.ingredientsImages.count : product!.ingredientsImages.count
        case Section.NutrionImages:
            return delegate?.updatedProduct?.nutritionImages != nil && delegate!.updatedProduct!.nutritionImages.count > 0 ? delegate!.updatedProduct!.nutritionImages.count : product!.nutritionImages.count
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
            if let images = delegate?.updatedProduct?.frontImages {
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
                if indexPath.row < product!.frontImages.count {
                    let key = keyTuples(for:Array(product!.frontImages.keys))[indexPath.row].0
                    if let result = product!.frontImages[key]?.display?.fetch() {
                        switch result {
                        case .available:
                            if let validImage = product!.frontImages[key]?.display?.image {
                                cell.imageView.image = validImage
                            }
                        default:
                            cell.imageView.image = UIImage.init(named:"NotOK")
                        }
                        cell.label.text = keyTuples(for:Array(product!.frontImages.keys))[indexPath.row].1
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
            if let images = delegate?.updatedProduct?.ingredientsImages  {
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
                if indexPath.row < product!.ingredientsImages.count {
                    let key = keyTuples(for:Array(product!.ingredientsImages.keys))[indexPath.row].0
                    if let result = product!.ingredientsImages[key]?.display?.fetch() {
                        switch result {
                        case .available:
                            if let validImage = product!.ingredientsImages[key]?.display?.image {
                                cell.imageView.image = validImage
                            }
                        default:
                            cell.imageView.image = UIImage.init(named:"NotOK")
                        }
                        cell.label.text = keyTuples(for:Array(product!.ingredientsImages.keys))[indexPath.row].1
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
            if let images = delegate?.updatedProduct?.nutritionImages {
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
                if indexPath.row < product!.nutritionImages.count {
                    let key = keyTuples(for:Array(product!.nutritionImages.keys))[indexPath.row].0
                    if let result = product!.nutritionImages[key]?.display?.fetch() {
                        switch result {
                        case .available:
                            if let validImage = product!.nutritionImages[key]?.display?.image {
                                cell.imageView.image = validImage
                            }
                        default:
                            cell.imageView.image = UIImage.init(named:"NotOK")
                        }
                        cell.label.text = keyTuples(for:Array(product!.nutritionImages.keys))[indexPath.row].1
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
            
                if let result = originalImages[key]?.display?.fetch() {
                 
                    switch result {
                    case .available:
                        if let validImage = originalImages[key]?.display?.image {
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
                headerView.label.text =  delegate?.updatedProduct?.frontImages != nil && delegate!.updatedProduct!.frontImages.count > 0 ?
                    Storyboard.HeaderTitle.Front + " (" + TranslatableStrings.Edited + ")" : Storyboard.HeaderTitle.Front
            case Section.IngredientsImages:
                headerView.label.text =  delegate?.updatedProduct?.ingredientsImages != nil && delegate!.updatedProduct!.ingredientsImages.count > 0 ?
                    Storyboard.HeaderTitle.Ingredients + " (" + TranslatableStrings.Edited + ")" : Storyboard.HeaderTitle.Ingredients
            case Section.NutrionImages:
                headerView.label.text =  delegate?.updatedProduct?.nutritionImages != nil && delegate!.updatedProduct!.nutritionImages.count > 0 ?
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
                        let languageCode = Array(product!.frontImages.keys.sorted(by: { $0 < $1 }))[selectedImage!.row]
                        vc.imageData = product!.image(for:languageCode, of:.front)
                        vc.imageTitle = OFFplists.manager.languageName(for:languageCode)
                        
                    case Section.IngredientsImages:
                        let languageCode = Array(product!.ingredientsImages.keys.sorted(by: { $0 < $1 }))[selectedImage!.row]
                        vc.imageData = product!.image(for:languageCode, of:.ingredients)
                        vc.imageTitle = OFFplists.manager.languageName(for:languageCode)
                        
                    case Section.NutrionImages:
                        let languageCode = Array(product!.nutritionImages.keys.sorted(by: { $0 < $1 }))[selectedImage!.row]
                        vc.imageData = product!.image(for:languageCode, of:.nutrition)
                        vc.imageTitle = OFFplists.manager.languageName(for:languageCode)
                        
                    case Section.OriginalImages:
                        let key = Array(product!.images.keys.sorted(by: { Int($0)! < Int($1)! }))[selectedImage!.row]
                        vc.imageData = product!.images[key]?.largest
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
                            vc.languageCodes = product!.languageCodes
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
                                delegate?.updated(frontImage: validImage, languageCode: selectedLanguageCode)
                            case .ingredients:
                                delegate?.updated(ingredientsImage: validImage, languageCode: selectedLanguageCode)
                            case .nutrition:
                                delegate?.updated(nutritionImage: validImage, languageCode: selectedLanguageCode)
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
            if barcode == product!.barcode.asString() {
                // reload product data
                OFFProducts.manager.reload(self.product!)
                // THis will result in a new notification if successfull, which will load the new images in turn
            }
        }
    }

    @objc func imageDeleted(_ notification: Notification) {
        // Check if this image was relevant to this product
        if let barcode = notification.userInfo?[OFFUpdate.Notification.ImageDeleteSuccessBarcodeKey] as? String {
            if barcode == product!.barcode.asString() {
                // reload product data
                OFFProducts.manager.reload(self.product!)
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
                let languageCode = keyTuples(for:Array(product!.frontImages.keys))[validIndexPath.row].0
                let update = OFFUpdate()
                update.deselect([languageCode], of: .front, for: product!)
            case Section.IngredientsImages:
                let languageCode = keyTuples(for:Array(product!.ingredientsImages.keys))[validIndexPath.row].0
                let update = OFFUpdate()
                update.deselect([languageCode], of: .ingredients, for: product!)
            case Section.NutrionImages:
                let languageCode = keyTuples(for:Array(product!.nutritionImages.keys))[validIndexPath.row].0
                let update = OFFUpdate()
                update.deselect([languageCode], of: .nutrition, for: product!)
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
        let newImageID = "\(product!.images.count + 1)"
        delegate?.updated(image: image, id: newImageID)
        
        collectionView?.reloadData()
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIDragInteractionDelegate Functions

extension ProductImagesCollectionViewController: UICollectionViewDragDelegate {
    
    @available(iOS 11.0, *)
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {

        // in editMode
        if editMode {
            return []
        }
        
        switch indexPath.section {
        case Section.OriginalImages:
            let key = Array(originalImages.keys.sorted(by: { Int($0)! < Int($1)! }))[indexPath.row]
                
            if let result = originalImages[key]?.display?.fetch() {
                switch result {
                case .available:
                    if let validImage = originalImages[key]?.display?.image {
                        let provider = NSItemProvider(object: validImage)
                        let item = UIDragItem(itemProvider: provider)
                        item.localObject = validImage
                        return [item]
                }
                default:
                    break
                }
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

