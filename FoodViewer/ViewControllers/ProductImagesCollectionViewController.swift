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
    
    // https://stackoverflow.com/questions/31367387/detect-if-app-is-running-in-slide-over-or-split-view-mode-in-ios-9
    //private func deviceOrientation () -> UIDeviceOrientation {
     //   return UIDevice.current.orientation
    //}

    private var screenSize: (description:String, size:CGRect) {
        return ("SCREEN SIZE:\nwidth: \(UIScreen.main.bounds.size.width)\nheight: \(UIScreen.main.bounds.size.height)", UIScreen.main.bounds)
    }

    private var applicationSize: (description:String, size:CGRect) {
        return ("\n\nAPPLICATION SIZE:\nwidth: \(UIApplication.shared.windows[0].bounds.size.width)\nheight: \(UIApplication.shared.windows[0].bounds.size.height)", UIApplication.shared.windows[0].bounds)
    }

    enum LayoutStyle: String {
        case iPadFullscreen         = "iPad Full Screen"
        case iPadHalfScreen         = "iPad 1/2 Screen"
        case iPadTwoThirdScreeen    = "iPad 2/3 Screen"
        case iPadOneThirdScreen     = "iPad 1/3 Screen"
        case iPhoneFullScreen       = "iPhone"
    }

    private var layoutStyle: LayoutStyle {
        if UIDevice.current.orientation == .landscapeLeft
            || UIDevice.current.orientation == .landscapeRight {
            if UIDevice.current.userInterfaceIdiom == .phone {
                return .iPhoneFullScreen
            }
            if screenSize == applicationSize {
                return .iPadFullscreen
            }

            // Set a range in case there is some mathematical inconsistency or other outside influence that results in the application width being less than exactly 1/3, 1/2 or 2/3.
            let lowRange = screenSize.size.width - 15
            let highRange = screenSize.size.width + 15

            if lowRange / 2 <= applicationSize.size.width && applicationSize.size.width <= highRange / 2 {
            return .iPadHalfScreen
            } else if applicationSize.size.width <= highRange / 3 {
                return .iPadOneThirdScreen
            } else {
                return .iPadTwoThirdScreeen
            }
        } else {
            if UIDevice.current.userInterfaceIdiom == .phone {
                return .iPadOneThirdScreen
            }
            // in case the app is a slide over in portrait
            if applicationSize.size.width <= (screenSize.size.width + 15) / 2 {
                return .iPadOneThirdScreen
            } else {
                return .iPadHalfScreen
            }

        }

    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        reloadImages()
    }

    var coordinator: ProductImagesCoordinator? = nil

    // MARK: - public variables
    
    var delegate: ProductPageViewController? = nil {
        didSet {
            if delegate != oldValue {
                tableStructure = setupSections()
                collectionView.reloadData()
            }
        }
    }
    
    
    fileprivate var tableStructure: [SectionType] = []

    fileprivate enum SectionType {
        case frontImages(String)
        case ingredientsImages(String)
        case nutritionImages(String)
        case packagingImages(String)
        case originalImages(String)
        
        var header: String {
            switch self {
            case .frontImages(let headerTitle),
                 .ingredientsImages(let headerTitle),
                 .nutritionImages(let headerTitle),
                 .packagingImages(let headerTitle),
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
        sectionsAndRows.append(.packagingImages(TranslatableStrings.SelectedPackagingImages))
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
    
    private var productPair: ProductPair? {
        // collectionView?.reloadData()
        return delegate?.productPair
    }

    // Needed to show or hide buttons
    private var editMode: Bool {
        return delegate?.editMode ?? false
    }

    private var languageCode: String? {
        get {
            return delegate?.currentLanguageCode
        }
    }
    
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
            case .remote:
                newImages = productPair?.remoteProduct?.images ?? [:]
            case .new:
                newImages = productPair?.localProduct?.images ?? [:]
                if let validImages = productPair?.remoteProduct?.images {
                    let images = validImages
                    newImages = newImages.merging(images, uniquingKeysWith: { (first, last) in last } )
                }
            }
            return newImages
        }
    }
    
    fileprivate var frontImages: [String:ProductImageSize] {
        get {
            var newImages: [String:ProductImageSize] = [:]
            switch productVersion {
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
            return newImages
        }
    }

    fileprivate var ingredientsImages: [String:ProductImageSize] {
        get {
            var newImages: [String:ProductImageSize] = [:]
            switch productVersion {
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
            return newImages
        }
    }

    fileprivate var nutritionImages: [String:ProductImageSize] {
        get {
            var newImages: [String:ProductImageSize] = [:]
            switch productVersion {
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
            return newImages
        }
    }

    fileprivate var packagingImages: [String:ProductImageSize] {
        get {
            var newImages: [String:ProductImageSize] = [:]
            switch productVersion {
            case .remote:
                if let validImages = productPair?.remoteProduct?.packagingImages {
                    newImages = validImages
                }
            case .new:
                if let validImages = productPair?.localProduct?.packagingImages {
                    newImages = validImages
                }
                if let validImages = productPair?.remoteProduct?.packagingImages {
                    let images = validImages
                    newImages = newImages.merging(images, uniquingKeysWith: { (first, last) in last } )
                }

            }
            return newImages
        }
    }

    fileprivate var itemsPerRow: CGFloat {
        switch layoutStyle {
        case .iPadFullscreen:
            return 8
        case .iPadHalfScreen:
            return 5
        case .iPadTwoThirdScreeen:
            return 6
        case .iPadOneThirdScreen:
            return 3
        case .iPhoneFullScreen:
            return 3
        }
    }
    
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
            static let SectionHeader =  "GallerySectionHeaderView"
            static let TagListViewCell = "TagListViewCollectionViewCellIdentifier"
        }
        struct NibIdentifier {
            static let AddImageCollectionCell = "AddImageCollectionViewCell"
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return tableStructure.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        // If there are updated images, only show those
        // In edit mode show the edit controls as a separate item
        // In non-edit mode show the all the images or an image telling there are no images.
        switch tableStructure[section] {
        case .frontImages:
            return numberOfItems(in: editMode, for: frontImages.count )
        case .ingredientsImages:
            return numberOfItems(in: editMode, for: ingredientsImages.count)
        case .nutritionImages:
            return numberOfItems(in: editMode, for: nutritionImages.count )
        case .packagingImages:
            return numberOfItems(in: editMode, for: packagingImages.count )
        case .originalImages:
            // Allow the user to add an image when in editMode
            return numberOfItems(in: editMode, for: originalImages.count )
        }
    }
    
    private func numberOfItems(in editMode: Bool, for number: Int) -> Int {
        return editMode
            ? number + 1
            : ( number == 0 ? 1 : number )
    }
    
    private var addImageType: SectionType?

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch tableStructure[indexPath.section] {
        case .frontImages: // Front Images
            if frontImages.count > 0 && indexPath.row < frontImages.count {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.GalleryImageCell, for: indexPath) as! GalleryCollectionViewCell

                let key = keyTuples(for:Array(frontImages.keys))[indexPath.row].0
                if let result = frontImages[key]?.largest?.fetch() {
                    switch result {
                    case .success(let image):
                        cell.imageView.image = image
                    default:
                        cell.imageView.image = UIImage.init(named:"NotOK")
                    }
                }
                cell.label.text = keyTuples(for:Array(frontImages.keys))[indexPath.row].1
                cell.indexPath = indexPath
                cell.editMode = editMode
                cell.delegate = self
                return cell
            } else {
                if editMode {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.AddImageCell, for: indexPath) as! AddImageCollectionViewCell
                    cell.delegate = self
                    cell.tag = 0
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.TagListViewCell, for: indexPath) as! TagListViewCollectionViewCell
                    cell.setup(datasource: self, delegate: nil, width: 30, tag: 0)
                    return cell
                }
            }
        case .ingredientsImages:
            if indexPath.row < ingredientsImages.count && ingredientsImages.count > 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.GalleryImageCell, for: indexPath) as! GalleryCollectionViewCell
                let key = keyTuples(for:Array(ingredientsImages.keys))[indexPath.row].0
                if let result = ingredientsImages[key]?.largest?.fetch() {
                    switch result {
                    case .success(let image):
                        cell.imageView.image = image
                    default:
                        cell.imageView.image = UIImage.init(named:"NotOK")
                    }
                }
                cell.label.text = keyTuples(for:Array(ingredientsImages.keys))[indexPath.row].1
                cell.indexPath = indexPath
                cell.editMode = editMode
                cell.delegate = self
                return cell
            } else {
                if editMode {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.AddImageCell, for: indexPath) as! AddImageCollectionViewCell
                    cell.delegate = self
                    cell.tag = 1
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.TagListViewCell, for: indexPath) as! TagListViewCollectionViewCell
                 cell.setup(datasource: self, delegate: nil, width: 30, tag: 1)
                    return cell
                }
            }

        case .nutritionImages:
            if indexPath.row < nutritionImages.count && nutritionImages.count > 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.GalleryImageCell, for: indexPath) as! GalleryCollectionViewCell
                let key = keyTuples(for:Array(nutritionImages.keys))[indexPath.row].0
                if let result = nutritionImages[key]?.largest?.fetch() {
                    switch result {
                    case .success(let image):
                        cell.imageView.image = image
                    default:
                        cell.imageView.image = UIImage.init(named:"NotOK")
                    }
                }
                cell.label.text = keyTuples(for:Array(nutritionImages.keys))[indexPath.row].1
                cell.indexPath = indexPath
                cell.editMode = editMode
                cell.delegate = self
                return cell
            } else {
                if editMode {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.AddImageCell, for: indexPath) as! AddImageCollectionViewCell
                    cell.delegate = self
                    cell.tag = 2
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.TagListViewCell, for: indexPath) as! TagListViewCollectionViewCell
                    cell.setup(datasource: self, delegate: nil, width: 30, tag: 2)
                    return cell
                }
            }

            case .packagingImages:
                if indexPath.row < packagingImages.count && packagingImages.count > 0 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.GalleryImageCell, for: indexPath) as! GalleryCollectionViewCell
                    let key = keyTuples(for:Array(packagingImages.keys))[indexPath.row].0
                    if let result = packagingImages[key]?.largest?.fetch() {
                        switch result {
                        case .success(let image):
                            cell.imageView.image = image
                        default:
                            cell.imageView.image = UIImage.init(named:"NotOK")
                        }
                    }
                    cell.label.text = keyTuples(for:Array(packagingImages.keys))[indexPath.row].1
                    cell.indexPath = indexPath
                    cell.editMode = editMode
                    cell.delegate = self
                    return cell
                } else {
                    if editMode {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.AddImageCell, for: indexPath) as! AddImageCollectionViewCell
                        cell.delegate = self
                        cell.tag = 3
                        return cell
                    } else {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.TagListViewCell, for: indexPath) as! TagListViewCollectionViewCell
                        cell.setup(datasource: self, delegate: nil, width: 30, tag: 2)
                        return cell
                    }
                }

        default:
            // in editMode the last element of a row is an add button
            if indexPath.row < originalImages.count && originalImages.count > 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.GalleryImageCell, for: indexPath) as! GalleryCollectionViewCell
                let key = Array(originalImages.keys.sorted(by: { Int($0)! < Int($1)! }))[indexPath.row]
                
                if let result = originalImages[key]?.largest?.fetch() {
                    switch result {
                    case .success(let image):
                        cell.imageView.image = image
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
            } else {
                if editMode {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.AddImageCell, for: indexPath) as! AddImageCollectionViewCell
                    cell.delegate = self
                    cell.tag = 3
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.TagListViewCell, for: indexPath) as! TagListViewCollectionViewCell
                    cell.setup(datasource: self, delegate: nil, width: 30, tag: 3)
                    return cell
                }
            }
        }
    }
    

// MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
                                
        //1
        switch kind {
        //2
        case UICollectionView.elementKindSectionHeader:
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                 withReuseIdentifier: Storyboard.CellIdentifier.SectionHeader,
                                                                             for: indexPath) as! GalleryCollectionReusableView
            var newTitle = ""

            switch tableStructure[indexPath.section] {
            case .frontImages:
                switch productVersion {
                case .new:
                    if productPair?.localProduct?.frontImages != nil && !productPair!.localProduct!.frontImages.isEmpty {
                        newTitle = TranslatableStrings.SelectedFrontImagesEdited
                    } else {
                        newTitle = TranslatableStrings.SelectedFrontImages
                    }
                default:
                    newTitle = TranslatableStrings.SelectedFrontImagesOriginal
                }
            case .ingredientsImages:
                switch productVersion {
                case .new:
                    if productPair?.localProduct?.ingredientsImages != nil && !productPair!.localProduct!.ingredientsImages.isEmpty {
                        newTitle = TranslatableStrings.SelectedIngredientImagesEdited
                    } else {
                        newTitle = TranslatableStrings.SelectedIngredientImages
                    }
                default:
                    newTitle = TranslatableStrings.SelectedIngredientImagesOriginal
                }
            case .nutritionImages:
                switch productVersion {
                case .new:
                    if productPair?.localProduct?.nutritionImages != nil && !productPair!.localProduct!.nutritionImages.isEmpty {
                        newTitle = TranslatableStrings.SelectedNutritionImagesEdited
                    } else {
                        newTitle = TranslatableStrings.SelectedNutritionImages
                    }
                default:
                    newTitle = TranslatableStrings.SelectedNutritionImagesOriginal
                }
                case .packagingImages:
                    switch productVersion {
                    case .new:
                        if productPair?.localProduct?.packagingImages != nil && !productPair!.localProduct!.packagingImages.isEmpty {
                            newTitle = TranslatableStrings.SelectedPackagingImagesEdited
                        } else {
                            newTitle = TranslatableStrings.SelectedPackagingImages
                        }
                    default:
                        newTitle = TranslatableStrings.SelectedPackagingImagesOriginal
                    }
            case .originalImages:
                switch productVersion {
                case .new:
                    if productPair?.localProduct?.images != nil && !productPair!.localProduct!.images.isEmpty {
                        newTitle = TranslatableStrings.OriginalImagesEdited
                    } else {
                        newTitle = TranslatableStrings.OriginalImages
                    }
                default:
                    newTitle = TranslatableStrings.OriginalImagesOriginal

                }
            }
            headerView.label?.text = newTitle
            return headerView
        default:
            assert(false, "ProductImagesCollectionViewController: Unexpected element kind")
        }
        return UICollectionReusableView()
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if editMode && indexPath.row == originalImages.count {
        } else {
            selectedImage = indexPath
            guard selectedImage != nil else { return }
            let imageTuple = imageDetailsTuple(for: selectedImage!.section)
            guard let title = imageTuple.0 else { return }
            guard let size = imageTuple.1 else { return }
            coordinator?.showImage(imageTitle: title, imageSize: size)
        }
    }
    
    private func imageDetailsTuple(for section: Int) -> (String?, ProductImageSize?) {
        switch tableStructure[section] {
        case .frontImages:
            let languageCode = Array(productPair!.remoteProduct!.frontImages.keys.sorted(by: { $0 < $1 }))[selectedImage!.row]
            return ( OFFplists.manager.languageName(for:languageCode), productPair!.remoteProduct!.image(for:languageCode, of:.front) )
        case .ingredientsImages:
            let languageCode = Array(productPair!.remoteProduct!.ingredientsImages.keys.sorted(by: { $0 < $1 }))[selectedImage!.row]
            return ( OFFplists.manager.languageName(for:languageCode), productPair!.remoteProduct!.image(for:languageCode, of:.ingredients) )
        case .nutritionImages:
            let languageCode = Array(productPair!.remoteProduct!.nutritionImages.keys.sorted(by: { $0 < $1 }))[selectedImage!.row]
            return ( OFFplists.manager.languageName(for:languageCode), productPair!.remoteProduct!.image(for:languageCode, of:.nutrition) )
        case .packagingImages:
            let languageCode = Array(productPair!.remoteProduct!.packagingImages.keys.sorted(by: { $0 < $1 }))[selectedImage!.row]
            return ( OFFplists.manager.languageName(for:languageCode), productPair!.remoteProduct!.image(for:languageCode, of:.packaging) )
        case .originalImages:
            let key = Array(productPair!.remoteProduct!.images.keys.sorted(by: { Int($0)! < Int($1)! }))[selectedImage!.row]
            return (key, productPair!.remoteProduct!.images[key])
        }

    }

    private func takePhotoButtonTapped() {
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

    private func useCameraRollButtonTapped() {
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
    
    
    fileprivate func newImageSelected(info: [UIImagePickerController.InfoKey : Any]) {
        var image: UIImage? = nil
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
    }
    /*
    private func imageToShow() -> (ProductImageData?, String?) {
        guard let validSection = selectedImage?.section else { return (nil,nil) }
        switch tableStructure[validSection] {
        case .frontImages:
            let languageCode = Array(productPair!.remoteProduct!.frontImages.keys.sorted(by: { $0 < $1 }))[selectedImage!.row]
            let imageData = productPair!.remoteProduct!.image(for:languageCode, of:.front)
            let imageTitle = OFFplists.manager.languageName(for:languageCode)
            return (imageData, imageTitle)
        case .ingredientsImages:
            let languageCode = Array(productPair!.remoteProduct!.ingredientsImages.keys.sorted(by: { $0 < $1 }))[selectedImage!.row]
            let imageData = productPair!.remoteProduct!.image(for:languageCode, of:.ingredients)
            let imageTitle = OFFplists.manager.languageName(for:languageCode)
            return (imageData, imageTitle)
        case .nutritionImages:
            let languageCode = Array(productPair!.remoteProduct!.nutritionImages.keys.sorted(by: { $0 < $1 }))[selectedImage!.row]
            let imageData = productPair!.remoteProduct!.image(for:languageCode, of:.nutrition)
            let imageTitle = OFFplists.manager.languageName(for:languageCode)
            return (imageData, imageTitle)
        case .packagingImages:
            let languageCode = Array(productPair!.remoteProduct!.packagingImages.keys.sorted(by: { $0 < $1 }))[selectedImage!.row]
            let imageData = productPair!.remoteProduct!.image(for:languageCode, of:.packaging)
            let imageTitle = OFFplists.manager.languageName(for:languageCode)
            return (imageData, imageTitle)
        case .originalImages:
            let key = Array(productPair!.remoteProduct!.images.keys.sorted(by: { Int($0)! < Int($1)! }))[selectedImage!.row]
            let imageData = productPair!.remoteProduct!.images[key]?.largest
            let imageTitle = key
            return (imageData, imageTitle)
        }
    }
 */

    @objc func reloadImages() {
        collectionView?.reloadData()
    }

    @objc func reloadProduct(_ notification: Notification) {
        // Check if this image was relevant to this product
        if let barcode = notification.userInfo?[ProductPair.Notification.BarcodeKey] as? String {
            if barcode == productPair!.barcodeType.asString {
                // reload product data
                OFFProducts.manager.reload(productPair: productPair)
                // This will result in a new notification if successfull, which will load the new images in turn
            }
        }
    }

    @objc func imageDeleted(_ notification: Notification) {
        // Check if this image was relevant to this product
        if let barcode = notification.userInfo?[ProductPair.Notification.BarcodeKey] as? String {
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
        
        coordinator = ProductImagesCoordinator(with: self)
        self.refresher = UIRefreshControl()
        self.refresher.tintColor = .systemRed
        self.refresher.addTarget(self, action: #selector(ProductImagesCollectionViewController.refresh(sender:)), for: .valueChanged)
        self.collectionView!.alwaysBounceVertical = true
        self.collectionView?.addSubview(refresher)
        self.collectionView?.delegate = self
        if #available(iOS 11.0, *) {
            self.collectionView?.dragDelegate = self
            self.collectionView?.dropDelegate = self
        }
        
        tableStructure = setupSections()

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
        
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(ProductImagesCollectionViewController.reloadImages),
            name: .ProductPairLocalStatusChanged,
            object:nil)
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(ProductImagesCollectionViewController.reloadImages),
            name:.ImageSet,
            object:nil)
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(ProductImagesCollectionViewController.reloadImages),
            name:.ProductUpdateSucceeded,
            object:nil)
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(ProductImagesCollectionViewController.reloadImages),
            name:.ProductPairRemoteStatusChanged,
            object:nil)
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(ProductImagesCollectionViewController.reloadProduct),
            name:.ProductPairImageUploadSuccess,
            object:nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        if let validGestureRecognizers = collectionView?.gestureRecognizers {
            for gesture in validGestureRecognizers {
                if let doubleTapGesture = gesture as? UITapGestureRecognizer,
                    doubleTapGesture.numberOfTapsRequired == 2,
                    doubleTapGesture.numberOfTouchesRequired == 1 {
                    collectionView?.removeGestureRecognizer(gesture)
                }
            }
        }
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        OFFplists.manager.flush()
        // Dispose of any resources that can be recreated.
    }

}
//
// MARK: - AddImageCollectionViewCellDelegate Functions
//
extension ProductImagesCollectionViewController : AddImageCollectionViewCellDelegate {
    func addImageCollectionViewCellAddFromCamera(_ sender: AddImageCollectionViewCell, receivedTapOn button: UIButton) {
        switch sender.tag {
        case 0:
            addImageType = .frontImages("")
        case 1:
            addImageType = .ingredientsImages("")
        case 2:
            addImageType = .nutritionImages("")
        case 3:
            addImageType = .packagingImages("")
        default:
            addImageType = .originalImages("")
        }
        takePhotoButtonTapped()
    }
    
    func addImageCollectionViewCellAddFromCameraRoll(_ sender: AddImageCollectionViewCell, receivedTapOn button: UIButton) {
        switch sender.tag {
        case 0:
            addImageType = .frontImages("")
        case 1:
            addImageType = .ingredientsImages("")
        case 2:
            addImageType = .nutritionImages("")
        case 3:
            addImageType = .packagingImages("")
        default:
            addImageType = .originalImages("")
        }
        useCameraRollButtonTapped()
    }
    
    
}
//
// MARK: - UICollectionViewDelegateFlowLayout Functions
//
extension ProductImagesCollectionViewController : GalleryCollectionViewCellDelegate {
    
    // function to let the delegate know that the deselect button has been tapped
    func galleryCollectionViewCell(_ sender: GalleryCollectionViewCell, receivedTapOn button:UIButton, for key:String?) {
        guard let validIndexPath = sender.indexPath,
             let validProductPair = productPair else { return }
        switch tableStructure[validIndexPath.section] {
        case .frontImages:
            let languageCode = keyTuples(for:Array(validProductPair.remoteProduct!.frontImages.keys))[validIndexPath.row].0
                OFFProducts.manager.deselectImage(for: validProductPair, in: languageCode, of: .front)
        case .ingredientsImages:
                let languageCode = keyTuples(for:Array(validProductPair.remoteProduct!.ingredientsImages.keys))[validIndexPath.row].0
            OFFProducts.manager.deselectImage(for: validProductPair, in: languageCode, of: .ingredients)
        case .nutritionImages:
            let languageCode = keyTuples(for:Array(validProductPair.remoteProduct!.nutritionImages.keys))[validIndexPath.row].0
            OFFProducts.manager.deselectImage(for: validProductPair, in: languageCode, of: .nutrition)
        case .packagingImages:
            let languageCode = keyTuples(for:Array(validProductPair.remoteProduct!.packagingImages.keys))[validIndexPath.row].0
            OFFProducts.manager.deselectImage(for: validProductPair, in: languageCode, of: .packaging)
        case .originalImages:
            guard let validCodes = productPair?.languageCodes else { return }
            coordinator?.showSelectLanguageAndImageType(for: self.productPair, languageCodes:validCodes, key: key)
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
    
    //func collectionView(_ collectionView: UICollectionView, layout
    //    collectionViewLayout: UICollectionViewLayout,
     //                   referenceSizeForFooterInSection section: Int) -> CGSize {
    //    return CGSize(width:200, height:88)
   // }
    
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
        guard productPair != nil else { return }

        let newImageID = "\(originalImages.count + 1)"
        switch addImageType ?? SectionType.originalImages("") {
        case .frontImages:
            productPair!.update(frontImage: image, for: productPair!.primaryLanguageCode)
        case .ingredientsImages:
            productPair!.update(ingredientsImage: image, for: productPair!.primaryLanguageCode)
        case .nutritionImages:
            productPair!.update(nutritionImage: image, for: productPair!.primaryLanguageCode)
        case .packagingImages:
            productPair!.update(packagingImage: image, for: productPair!.primaryLanguageCode)
        default:
            productPair?.update(image: image, id: newImageID)
        }
        
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
//
// MARK: - TagListView Datasource Functions
//
extension ProductImagesCollectionViewController: TagListViewDataSource {
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        return 1
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        return TranslatableStrings.None
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
    }
    
    public func tagListView(_ tagListView: TagListView, colorSchemeForTagAt index: Int) -> ColorScheme? {
        return ColorSchemes.error
    }
}
