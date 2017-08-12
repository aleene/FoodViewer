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

    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)

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
//        struct SegueIdentifier {
//            static let ShowIdentificationImage = "Show Identification Image"
//            static let ShowNamesLanguages = "Show Names Languages"
//            static let ShowSelectMainLanguage = "Show Select Main Language Segue"
//            static let ShowImageSourceSelector = "Show Select Image Source Segue"
//        }
    }

    private var selectedFrontImages: [UIImage] {
        get {
            var validImages: [UIImage] = []
            
            if !product!.frontImages.isEmpty {
                for dict in product!.frontImages {
                    if let result = dict.value.small.fetch() {
                        switch result {
                        case .available:
                            if let validImage = dict.value.small.image {
                                validImages.append(validImage)
                            }
                        default:
                            break
                        }
                    }
                }
            }
            
            return validImages
        }
    }
    
    private var selectedIngredientsImages: [UIImage] {
        get {
            var validImages: [UIImage] = []
            
            if !product!.ingredientsImages.isEmpty {
                for dict in product!.ingredientsImages {
                    if let result = dict.value.small.fetch() {
                        switch result {
                        case .available:
                            if let validImage = dict.value.small.image {
                                validImages.append(validImage)
                            }
                        default:
                            break
                        }
                    }
                }
            }
            
            return validImages
        }
    }
    private var selectedNutritionImages: [UIImage] {
        get {
            var validImages: [UIImage] = []
            
            if !product!.nutritionImages.isEmpty {
                for dict in product!.nutritionImages {
                    if let result = dict.value.small.fetch() {
                        switch result {
                        case .available:
                            if let validImage = dict.value.small.image {
                                validImages.append(validImage)
                            }
                        default:
                            break
                        }
                    }
                }
            }
            
            return validImages
        }
    }

    private var originalImages: [UIImage] {
        get {
            var validImages: [UIImage] = []
            
            if !product!.images.isEmpty {
                for productImageSize in product!.images {
                    if let result = productImageSize.value.small.fetch() {
                        switch result {
                        case .available:
                            if let validImage = productImageSize.value.small.image {
                                validImages.append(validImage)
                            }
                        default:
                            break
                        }
                    }
                }
            }
            
            return validImages
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return selectedFrontImages.count
        case 1:
            return selectedIngredientsImages.count
        case 2:
            return selectedNutritionImages.count
        case 3:
            return originalImages.count
        default:
            assert(false, "ProductImagesCollectionViewController: unexpected number of sections")
        }
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.CellIdentifier.GalleryImageCell, for: indexPath) as! GalleryCollectionViewCell
        cell.backgroundColor = UIColor.white
        switch indexPath.section {
        case 0:
            cell.imageView.image = selectedFrontImages[indexPath.row]
        case 1:
            cell.imageView.image = selectedIngredientsImages[indexPath.row]
        case 2:
            cell.imageView.image = selectedNutritionImages[indexPath.row]
        case 3:
            cell.imageView.image = originalImages[indexPath.row]
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

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

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

    func reloadImages() {
        collectionView?.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
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

