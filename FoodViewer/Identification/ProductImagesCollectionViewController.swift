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
    private func keyTuples(for keys: [String]) -> [(String, String)] {
        var tuples: [(String, String)] = []
        for key in keys {
            tuples.append((key,OFFplists.manager.languageName(for:key)))
        }
        return tuples.sorted(by: { $0.1 < $1.1 } )
    }
    
    private var originalImages: [String:ProductImageSize] {
        get {
            var images = product!.images
            if let updatedImages = delegate?.updatedProduct?.images {
                updatedImages.forEach( { images[$0.key] = $0.value } )
            }
            return images
        }
    }
    fileprivate let itemsPerRow: CGFloat = 5
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)

    private var selectedImage: IndexPath? = nil
    
    @IBOutlet weak var addImageFromCameraButton: UIButton!
    
    @IBAction func addImageFromCameraButtonTapped(_ sender: UIButton) {
    }
    
    @IBOutlet weak var addImageFromCameraRollButton: UIButton!
    
    @IBAction func addImageFromCameraRollButtonTapped(_ sender: UIButton) {
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
        }

    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard product != nil else { return 0 }
        switch section {
        case 0:
            return product!.frontImages.count
        case 1:
            return product!.ingredientsImages.count
        case 2:
            return product!.nutritionImages.count
        case 3:
            // Allow the user to add an image when in editMode
            return editMode ? originalImages.count + 1 : originalImages.count
        default:
            assert(false, "ProductImagesCollectionViewController: unexpected number of sections")
        }
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.GalleryImageCell, for: indexPath) as! GalleryCollectionViewCell

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
            return cell
        
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.GalleryImageCell, for: indexPath) as! GalleryCollectionViewCell

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
                    assert(false, "ProductImagesCollectionViewController: indexPath.row ingredientsImages to large")
                }
            }
            return cell
            
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.GalleryImageCell, for: indexPath) as! GalleryCollectionViewCell
            
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
                assert(false, "ProductImagesCollectionViewController: indexPath.row nutritionImages to large")
            }
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
                return cell
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
        case UICollectionElementKindSectionHeader:
            //3
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: Storyboard.CellIdentifier.SectionHeader,
                                                                             for: indexPath) as! GalleryCollectionReusableView
            switch indexPath.section {
            case 0:
                headerView.label.text = Storyboard.HeaderTitle.Front
            case 1:
                headerView.label.text = Storyboard.HeaderTitle.Ingredients
            case 2:
                headerView.label.text = Storyboard.HeaderTitle.Nutrition
            case 3:
                headerView.label.text = Storyboard.HeaderTitle.Original
            default:
                assert(false, "ProductImagesCollectionViewController: unexpected number of sections")
            }

            
            return headerView
        default:
            //4
            assert(false, "ProductImagesCollectionViewController: Unexpected element kind")
        }
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
                    case 0:
                        let key = Array(product!.frontImages.keys.sorted(by: { $0 < $1 }))[selectedImage!.row]
                        vc.imageData = product!.frontImages[key]?.largest()
                        vc.imageTitle = OFFplists.manager.languageName(for:key)
                        
                    case 1:
                        let key = Array(product!.ingredientsImages.keys.sorted(by: { $0 < $1 }))[selectedImage!.row]
                        vc.imageData = product!.ingredientsImages[key]?.largest()
                        vc.imageTitle = OFFplists.manager.languageName(for:key)
                        
                    case 2:
                        let key = Array(product!.nutritionImages.keys.sorted(by: { $0 < $1 }))[selectedImage!.row]
                        vc.imageData = product!.nutritionImages[key]?.largest()
                        vc.imageTitle = OFFplists.manager.languageName(for:key)
                        
                    case 3:
                        let key = Array(product!.images.keys.sorted(by: { Int($0)! < Int($1)! }))[selectedImage!.row]
                        vc.imageData = product!.images[key]?.largest()
                        vc.imageTitle = key
                        
                    default:
                        assert(false, "ProductImagesCollectionViewController: inexisting section")
                    }
                }
                default: break
            }
        }
    }

    
    func takePhotoButtonTapped() {
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

    func useCameraRollButtonTapped() {
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

    func reloadImages() {
        collectionView?.reloadData()
    }

    func registerCollectionViewCell()
    {
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
        
        collectionView?.delegate = self
        
        registerCollectionViewCell()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector:#selector(ProductImagesCollectionViewController.reloadImages), name:.ImageSet, object:nil)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


