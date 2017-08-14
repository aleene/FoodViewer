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

    fileprivate let itemsPerRow: CGFloat = 5
    fileprivate let sectionInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)

    private var selectedImage: IndexPath? = nil
    
    // MARK: UICollectionViewDataSource

    fileprivate struct Storyboard {
        struct CellIdentifier {
            static let GalleryImageCell = "Gallery Image Cell"
            static let SectionHeader =  "SectionHeaderView"
        }
        struct HeaderTitle {
            static let Front = NSLocalizedString("Selected Front Images", comment: "Gallery header text presenting the selected front images")
            static let Ingredients = NSLocalizedString("Selected Ingredients Images", comment: "Gallery header text presenting the selected ingredients images")
            static let Nutrition = NSLocalizedString("Selected Nutrition Images", comment: "Gallery header text presenting the selected nutrition images")
            static let Original = NSLocalizedString("Original Images", comment: "Gallery header text presenting the original images")
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
        switch section {
        case 0:
            return product!.frontImages.count
        case 1:
            return product!.nutritionImages.count
        case 2:
            return product!.ingredientsImages.count
        case 3:
            return product!.images.count
        default:
            assert(false, "ProductImagesCollectionViewController: unexpected number of sections")
        }
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.GalleryImageCell, for: indexPath) as! GalleryCollectionViewCell
        // cell.backgroundColor = UIColor.white
        switch indexPath.section {
        case 0:
            let key = Array(product!.frontImages.keys.sorted(by: { $0 < $1 }))[indexPath.row]
            if let result = product!.frontImages[key]?.display?.fetch() {
                switch result {
                case .available:
                    if let validImage = product!.frontImages[key]?.display?.image {
                        cell.imageView.image = validImage
                    }
                default:
                    cell.imageView.image = UIImage.init(named:"NotOK")
                }
                cell.label.text = OFFplists.manager.languageName(for:key)
            }
            
        case 1:
            let key = Array(product!.ingredientsImages.keys.sorted(by: { $0 < $1 }))[indexPath.row]
            if let result = product!.ingredientsImages[key]?.display?.fetch() {
                switch result {
                case .available:
                    if let validImage = product!.ingredientsImages[key]?.display?.image {
                        cell.imageView.image = validImage
                    }
                default:
                    cell.imageView.image = UIImage.init(named:"NotOK")
                }
                cell.label.text = OFFplists.manager.languageName(for:key)
            }
        case 2:
            let key = Array(product!.nutritionImages.keys.sorted(by: { $0 < $1 }))[indexPath.row]
            if let result = product!.nutritionImages[key]?.display?.fetch() {
                switch result {
                case .available:
                    if let validImage = product!.nutritionImages[key]?.display?.image {
                        cell.imageView.image = validImage
                    }
                default:
                    cell.imageView.image = UIImage.init(named:"NotOK")
                }
                cell.label.text = OFFplists.manager.languageName(for:key)
            }
            
        case 3:
            let key = Array(product!.images.keys.sorted(by: { Int($0)! < Int($1)! }))[indexPath.row]
            
            if let result = product!.images[key]?.display?.fetch() {
                 
            switch result {
            case .available:
                if let validImage = product!.images[key]?.display?.image {
                    cell.imageView.image = validImage
                }
            default:
                cell.imageView.image = UIImage.init(named:"NotOK")
            }
            cell.label.text = key
        }
            
        default:
            assert(false, "ProductImagesCollectionViewController: inexisting section")
        }

        
        return cell
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
            assert(false, "Unexpected element kind")
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
        selectedImage = indexPath
        performSegue(withIdentifier: Storyboard.SegueIdentifier.ShowImage, sender: self)
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
                if let vc = segue.destination as? imageViewController {
                    guard selectedImage != nil else { return }
                    switch selectedImage!.section {
                    case 0:
                        let key = Array(product!.frontImages.keys.sorted(by: { $0 < $1 }))[selectedImage!.row]
                        if let result = product!.frontImages[key]?.largest()?.fetch() {
                            switch result {
                            case .available:
                                if let validImage = product!.frontImages[key]?.largest()?.image {
                                    vc.image = validImage
                                }
                            default:
                                break
                            }
                            vc.imageTitle = OFFplists.manager.languageName(for:key)
                        }
                        
                    case 1:
                        let key = Array(product!.ingredientsImages.keys.sorted(by: { $0 < $1 }))[selectedImage!.row]
                        if let result = product!.ingredientsImages[key]?.largest()?.fetch() {
                            switch result {
                            case .available:
                                if let validImage = product!.ingredientsImages[key]?.largest()?.image {
                                    vc.image = validImage
                                }
                            default:
                                break
                            }
                            vc.imageTitle = OFFplists.manager.languageName(for:key)
                        }
                    case 2:
                        let key = Array(product!.nutritionImages.keys.sorted(by: { $0 < $1 }))[selectedImage!.row]
                        if let result = product!.nutritionImages[key]?.largest()?.fetch() {
                            switch result {
                            case .available:
                                if let validImage = product!.nutritionImages[key]?.largest()?.image {
                                    vc.image = validImage
                                }
                            default:
                                break
                            }
                            vc.imageTitle = OFFplists.manager.languageName(for:key)
                        }
                        
                    case 3:
                        let key = Array(product!.images.keys.sorted(by: { Int($0)! < Int($1)! }))[selectedImage!.row]
                        
                        if let result = product!.images[key]?.largest()?.fetch() {
                            switch result {
                            case .available:
                                if let validImage = product!.images[key]?.largest()?.image {
                                    vc.image = validImage
                                }
                            default:
                                break
                            }
                            vc.imageTitle = key
                        }
                        
                    default:
                        assert(false, "ProductImagesCollectionViewController: inexisting section")
                    }
                    

//                    if delegate?.updatedProduct?.frontImages != nil && !delegate!.updatedProduct!.frontImages.isEmpty {
//                        if let image = delegate!.updatedProduct!.frontImages[currentLanguageCode!]?.display.image {
//                            vc.image = image
//                        } else if let image = delegate!.updatedProduct!.frontImages[currentLanguageCode!]?.display.image {
//                            vc.image = image
//                        }
//                    } else if !product!.frontImages.isEmpty {
//                        // is the data for the current language available?
//                        // then fetch the image
//                        if let result = product!.frontImages[currentLanguageCode!]?.display.fetch() {
//                            switch result {
//                            case .available:
//                                vc.image = product!.frontImages[currentLanguageCode!]?.display.image
//                            default:
//                                break
//                            }
//                            // try to use the primary image
//                        } else if let result = product!.frontImages[product!.primaryLanguageCode!]?.display.fetch() {
//                            switch result {
//                            case .available:
//                                vc.image = product!.frontImages[product!.primaryLanguageCode!]?.display.image
//                            default:
//                                vc.image = nil
//                            }
//                        } else {
//                            vc.image = nil
//                        }
//                    }
                }
//            case Storyboard.SegueIdentifier.ShowImageSourceSelector:
//                if let vc = segue.destination as? SelectImageSourceViewController {
//                    // The segue can only be initiated from a button within a BarcodeTableViewCell
//                    if let button = sender as? UIButton {
//                        if button.superview?.superview as? IdentificationImageTableViewCell != nil {
//                            if let ppc = vc.popoverPresentationController {
//                                // set the main language button as the anchor of the popOver
//                                ppc.permittedArrowDirections = .any
//                                // I need the button coordinates in the coordinates of the current controller view
//                                let anchorFrame = button.convert(button.bounds, to: self.view)
//                                ppc.sourceRect = anchorFrame // bottomCenter(anchorFrame)
//                                ppc.delegate = self
//                                vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
//                                vc.delegate = self
//                            }
//                        }
//                    }
//                }
            default: break
            }
        }
    }

    func reloadImages() {
        collectionView?.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.delegate = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
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

