//
//  IngredientsTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import MobileCoreServices

class IngredientsTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {

    fileprivate var tableStructureForProduct: [(SectionType, Int, String?)] = []
    
    fileprivate var ingredientsImage: UIImage? = nil {
        didSet {
            refreshProduct()
        }
    }
    
    
    fileprivate var allergensToDisplay: Tags {
        get {
            return product!.translatedAllergens
        }
    }
    
    fileprivate var tracesToDisplay: Tags {
        get {
            // is an updated product available?
            if delegate?.updatedProduct != nil {
                // does it have brands defined?
                switch delegate!.updatedProduct!.traces {
                case .available, .empty:
                    return delegate!.updatedProduct!.traces
                default:
                    break
                }
            }
            return product!.translatedTraces
        }
    }
    
    fileprivate var additivesToDisplay: Tags {
        get {
            return product!.additives
        }
    }
    
    fileprivate var labelsToDisplay: Tags {
        get {
            // is an updated product available?
            if delegate?.updatedProduct != nil {
                // does it have brands defined?
                switch delegate!.updatedProduct!.labelArray {
                case .available, .empty:
                    return delegate!.updatedProduct!.labelArray
                default:
                    break
                }
            }
            return product!.labelArray
        }
    }

    fileprivate var searchResult: String = ""
    
    private var selectedSection: Int? = nil

    // MARK: - Public variables
    
    var product: FoodProduct? {
        didSet {
            if product != nil {
                ingredientsImage = nil
                tableStructureForProduct = analyseProductForTable(product!)
                refreshProduct()
            }
        }
    }
    
    var currentLanguageCode: String? = nil {
        didSet {
            if currentLanguageCode != oldValue {
                tableView.reloadData()
            }
        }
    }

    var editMode: Bool = false {
        didSet {
            // vc changed from/to editMode, need to repaint
            if editMode != oldValue {
                tableView.reloadData()
            }
        }
    }

    var delegate: ProductPageViewController? = nil

    // MARK: - Actions and Outlets
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        if refreshControl!.isRefreshing {
            OFFProducts.manager.reload(product!)
            refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Table view data source
    
    fileprivate enum SectionType {
        case ingredients
        case allergens
        case traces
        case additives
        case labels
        case image
    }

    fileprivate struct Storyboard {
        struct CellIdentifier {
            static let Ingredients = "Ingredients Full Cell"
            static let Allergens = "Allergens TagList Cell"
            static let Traces = "Traces TagList Cell"
            static let Additives = "Additives TagList Cell"
            static let Labels = "Labels TagList Cell"
            static let Image = "Ingredients Image Cell"
            static let NoImage = "No Image Cell"
        }
        struct SegueIdentifier {
            static let ShowIdentification = "Show Ingredients Image"
            static let SelectLanguage = "Show Ingredients Languages"
        }
    }
    
    fileprivate struct TextConstants {
        static let ShowIdentificationTitle = NSLocalizedString("Image", comment: "Title for the ViewController with the image of the product ingredients.")
        static let ViewControllerTitle = NSLocalizedString("Ingredients", comment: "Title for the ViewController with the product ingredients.")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableStructureForProduct.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let (_, numberOfRows, _) = tableStructureForProduct[section]
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let (currentProductSection, _, _) = tableStructureForProduct[(indexPath as NSIndexPath).section]
        
        // we assume that product exists
        switch currentProductSection {
        case .ingredients:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Ingredients, for: indexPath) as? IngredientsFullTableViewCell
            cell!.textViewDelegate = self
            cell!.textViewTag = indexPath.section
            cell!.editMode = editMode // currentLanguageCode == product!.primaryLanguageCode ? editMode : false
            if let validCurrentLanguageCode = currentLanguageCode {
                // has the product been edited?
                if let validName = delegate?.updatedProduct?.ingredientsLanguage[validCurrentLanguageCode] {
                    cell!.ingredients = validName
                } else if let validName = product?.ingredientsLanguage[validCurrentLanguageCode] {
                        cell!.ingredients = validName
                } else {
                    cell!.ingredients = nil
                }
            }
            return cell!
            
        case .allergens:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Allergens, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.tag = indexPath.section
            return cell
            
        case .traces:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Traces, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.editMode = editMode
            cell.tag = indexPath.section
            return cell
            
        case .additives:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Additives, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.tag = indexPath.section
            return cell
            
        case .labels:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Labels, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.editMode = editMode
            cell.tag = indexPath.section
            return cell
            
        case .image:
            // are there any updated images?
            if delegate?.updatedProduct?.ingredientsImages?.display != nil && delegate!.updatedProduct!.ingredientsImages!.display.count > 0 {
                // is there an updated image for the current language?
                if let image = delegate!.updatedProduct!.ingredientsImages!.display[currentLanguageCode!]?.image {
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as? IngredientsImageTableViewCell
                    cell?.editMode = editMode
                    cell?.ingredientsImage = image
                    return cell!
                // in non-editMode show the updated image for the primary language
                } else if !editMode, let primaryLanguageCode = delegate?.updatedProduct?.primaryLanguageCode, let image = delegate!.updatedProduct!.ingredientsImages!.display[primaryLanguageCode]?.image {
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as? IngredientsImageTableViewCell
                    cell?.editMode = editMode
                    cell?.ingredientsImage = image
                    return cell!
                // otherwise show an error
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NoImage, for: indexPath) as? TagListViewTableViewCell //
                    cell?.datasource = self
                    cell?.tag = indexPath.section
                    cell?.width = tableView.frame.size.width
                    cell?.scheme = ColorSchemes.error
                    searchResult = "No image in the right language"
                    return cell!
                }
            // are there any ingredients images?
            } else if product!.ingredientsImages != nil && product!.ingredientsImages!.display.count > 0 {
                // is there a current language image
                if let result = product!.ingredientsImages!.display[currentLanguageCode!]?.fetch() {
                    switch result {
                    case .success:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as? IngredientsImageTableViewCell
                        cell?.ingredientsImage = product!.ingredientsImages!.display[currentLanguageCode!]?.image
                        cell?.editMode = editMode
                        return cell!
                    default:
                        searchResult = result.description()
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NoImage, for: indexPath) as? TagListViewTableViewCell //
                        cell?.datasource = self
                        cell?.tag = indexPath.section
                        cell?.width = tableView.frame.size.width
                        cell?.scheme = ColorSchemes.error
                        return cell!
                    }
                // if not in editMode show the image in the primary language
                } else if !editMode, let primaryLanguageCode = product?.primaryLanguageCode, let result = product!.ingredientsImages!.display[primaryLanguageCode]?.fetch() {
                    switch result {
                    case .success:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as? IngredientsImageTableViewCell
                        cell?.ingredientsImage = product!.ingredientsImages!.display[primaryLanguageCode]?.image
                        cell?.editMode = editMode
                        return cell!
                    default:
                        searchResult = result.description()
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NoImage, for: indexPath) as? TagListViewTableViewCell //
                        cell?.datasource = self
                        cell?.tag = indexPath.section
                        cell?.width = tableView.frame.size.width
                        cell?.scheme = ColorSchemes.error
                        return cell!
                    }
                // neither an image in the chose languageCodes are available
                } else {
                    if editMode {
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as? IngredientsImageTableViewCell
                        cell?.ingredientsImage = nil
                        cell?.editMode = editMode
                        return cell!
                    } else {
                        // image could not be found (yet)
                        searchResult = ImageFetchResult.noImageAvailable.description()
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NoImage, for: indexPath) as? TagListViewTableViewCell //
                        cell?.datasource = self
                        cell?.tag = indexPath.section
                        cell?.width = tableView.frame.size.width
                        cell?.scheme = ColorSchemes.error
                        return cell!
                    }
                }
            // no language available at all
            } else {
                if editMode {
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as? IngredientsImageTableViewCell
                    cell?.ingredientsImage = nil
                    cell?.editMode = editMode
                    return cell!
                } else {
                    searchResult = ImageFetchResult.noImageAvailable.description()
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NoImage, for: indexPath) as? TagListViewTableViewCell //
                    cell?.datasource = self
                    cell?.tag = indexPath.section
                    cell?.width = tableView.frame.size.width
                    cell?.scheme = ColorSchemes.error
                    return cell!
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (_, _, header) = tableStructureForProduct[section]
        let (currentProductSection, _, _) = tableStructureForProduct[section]
        
        switch currentProductSection {
        case .image, .ingredients:
            return nil
        default:
            return header
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSection = indexPath.section
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        let (currentProductSection, _, _) = tableStructureForProduct[(indexPath as NSIndexPath).section]
        
        switch currentProductSection {
        case .image, .ingredients:
            return indexPath
        default:
            break
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let (currentProductSection, _, _) = tableStructureForProduct[section]
        
        switch currentProductSection {
        case .image, .ingredients :
            let (_, _, header) = tableStructureForProduct[section]
            
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "LanguageHeaderView") as! LanguageHeaderView
            
            headerView.section = section
            headerView.delegate = self
            headerView.title = header
            headerView.languageCode = currentLanguageCode
            headerView.buttonIsEnabled = editMode ? true : ( product!.languageCodes.count > 1 ? true : false )
            
            return headerView
        default:
            return nil
        }
    }

    fileprivate func nextLanguageCode() -> String {
        let currentIndex = (product?.languageCodes.index(of: currentLanguageCode!))!
        
        let nextIndex = currentIndex == ((product?.languageCodes.count)! - 1) ? 0 : (currentIndex + 1)
        return (product?.languageCodes[nextIndex])!
    }

    fileprivate struct TableSection {
        struct Size {
            static let Ingredients = 1
            static let Allergens = 1
            static let Traces = 1
            static let Additives = 1
            static let Labels = 1
            static let Image = 1
        }
        struct Header {
            static let Ingredients = NSLocalizedString("Ingredients", comment: "Header title for the product ingredients section.")
            static let Allergens = NSLocalizedString("Allergens", comment: "Header title for the product allergens section, i.e. the allergens derived from the ingredients.")
            static let Traces = NSLocalizedString("Traces", comment: "Header title for the product traces section, i.e. the traces are from products which are worked with in the factory and are indicated separate on the label.")
            static let Additives = NSLocalizedString("Additives", comment: "Header title for the product additives section, i.e. the additives are derived from the ingredients list.")
            static let Labels = NSLocalizedString("Labels", comment: "Header title for the product labels section, i.e. images, logos, etc.")
            static let Image = NSLocalizedString("Ingredients Image", comment: "Header title for the ingredients image section, i.e. the image of the package with the ingredients")
        }
    }
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }
    
    fileprivate func analyseProductForTable(_ product: FoodProduct) -> [(SectionType,Int, String?)] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections
        // And each element is a tuple with the section type and number of rows
        //
        //  The order of each element determines the order in the table
        var sectionsAndRows: [(SectionType,Int, String?)] = []
        
        // 0: ingredients
        sectionsAndRows.append((SectionType.ingredients,
            TableSection.Size.Ingredients,
            TableSection.Header.Ingredients))
        
        
        // not needed for .petFood and .beauty
        switch currentProductType {
        case .food:
            // 1:  allergens section
            sectionsAndRows.append((
                SectionType.allergens,
                TableSection.Size.Allergens,
                TableSection.Header.Allergens))
            // 2: traces section
            sectionsAndRows.append((
                SectionType.traces,
                TableSection.Size.Traces,
                TableSection.Header.Traces))
        default :
            break
        }

    
        // 3: additives section
        sectionsAndRows.append((
            SectionType.additives,
            TableSection.Size.Additives,
            TableSection.Header.Additives))
        
        // 4: labels section
        sectionsAndRows.append((
            SectionType.labels,
            TableSection.Size.Labels,
            TableSection.Header.Labels))
        
        
        // 5: image section
        sectionsAndRows.append((
            SectionType.image,
            TableSection.Size.Image,
            TableSection.Header.Image))
        
        return sectionsAndRows
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.SegueIdentifier.ShowIdentification:
                if let vc = segue.destination as? imageViewController {
                    vc.imageTitle = TextConstants.ShowIdentificationTitle
                    if delegate?.updatedProduct?.ingredientsImages?.display != nil && delegate!.updatedProduct!.ingredientsImages!.display.count > 0 {
                        if let image = delegate!.updatedProduct!.ingredientsImages!.display[currentLanguageCode!]?.image {
                            vc.image = image
                        } else if let image = delegate!.updatedProduct!.ingredientsImages!.display[currentLanguageCode!]?.image {
                            vc.image = image
                        }
                    } else if product!.ingredientsImages !=  nil && product!.ingredientsImages!.display.count > 0 {
                        // is the data for the current language available?
                        // then fetch the image
                        if let result = product!.ingredientsImages!.display[currentLanguageCode!]?.fetch() {
                            switch result {
                            case .success:
                                vc.image = product!.ingredientsImages!.display[currentLanguageCode!]?.image
                            default:
                                break
                            }
                            // try to use the primary image
                        } else if let result = product!.ingredientsImages!.display[product!.primaryLanguageCode!]?.fetch() {
                            switch result {
                            case .success:
                                vc.image = product!.ingredientsImages!.display[product!.primaryLanguageCode!]?.image
                            default:
                                vc.image = nil
                            }
                        } else {
                            vc.image = nil
                        }
                    }
                }
            case Storyboard.SegueIdentifier.SelectLanguage:
                if let vc = segue.destination as? SelectLanguageViewController {
                    // The segue can only be initiated from a button within a ProductNameTableViewCell
                    if let button = sender as? UIButton {
                        // The button should be in a view,
                        // which is in a TableHeaderFooterView,
                        // which is in a TableView
                        if button.superview?.superview?.superview as? UITableView != nil {
                            if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of the popOver
                                ppc.permittedArrowDirections = .right
                                // I need the button coordinates in the coordinates of the current controller view
                                let anchorFrame = button.convert(button.bounds, to: self.view)
                                ppc.sourceRect = anchorFrame // leftMiddle(anchorFrame)
                                ppc.delegate = self
                                vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                                
                                vc.currentLanguageCode = currentLanguageCode
                                vc.languageCodes = product!.languageCodes
                                vc.updatedLanguageCodes = delegate?.updatedProduct != nil ? delegate!.updatedProduct!.languageCodes : []
                                vc.primaryLanguageCode = product?.primaryLanguageCode
                                vc.sourcePage = 1
                                vc.editMode = editMode
                            }
                        }
                    }
                }
            default: break
            }
        }
    }
    
    // function that defines a pixel on the bottom center of a frame
    private func leftMiddle(_ frame: CGRect) -> CGRect {
        var newFrame = frame
        newFrame.origin.y += frame.size.height / 2
        newFrame.size.height = 1
        newFrame.size.width = 1
        return newFrame
    }
    
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

    // MARK: - Notification handler
    
    func reloadImageSection() { // (_ notification: Notification) {
        tableView.reloadData()
        // tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 5)], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func refreshProduct() {
        tableView.reloadData()
    }
    
    func removeProduct() {
        product = nil
        tableView.reloadData()
    }

    func changeLanguage() {
        // set the next language in the array
        if currentLanguageCode != nextLanguageCode() {
            currentLanguageCode = nextLanguageCode()
            // reload the first row
            let indexPaths = [IndexPath.init(row: 0, section: 0)]
            tableView.reloadRows(at: indexPaths, with: UITableViewRowAnimation.fade)
            tableView.deselectRow(at: indexPaths.first!, animated: true)
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
                popoverPresentationController.sourceRect = tableView.frame
                popoverPresentationController.sourceView = self.view
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
            imagePicker.imagePickerController!.modalPresentationStyle = .fullScreen
            imagePicker.sourceType = .savedPhotosAlbum


            imagePicker.delegate = self
            
            present(imagePicker.imagePickerController!, animated: true, completion: nil)
            if let popoverPresentationController = imagePicker.imagePickerController!.popoverPresentationController {
                popoverPresentationController.sourceRect = tableView.frame
                popoverPresentationController.sourceView = self.view
            }
        }
    }

    fileprivate func newImageSelected(info: [String : Any]) {
        var image: UIImage? = nil
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        if image != nil {
            delegate?.updated(ingredientsImage: image!, languageCode: currentLanguageCode!)
            tableView.reloadData()
        }
    }

    func imageUploaded(_ notification: Notification) {
        // Check if this image is relevant to this product
        if let barcode = notification.userInfo?[OFFUpdate.Notification.ImageUploadSuccessBarcodeKey] as? String {
            if barcode == product!.barcode.asString() {
                // is it relevant to the main image?
                if let id = notification.userInfo?[OFFUpdate.Notification.ImageUploadSuccessImagetypeKey] as? String {
                    if id.contains(OFFHttpPost.AddParameter.ImageField.Value.Ingredients) {
                        // reload product data
                        OFFProducts.manager.reload(self.product!)
                    }
                }
            }
        }
    }
    
    

    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        
        // For custom tableView headers
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 70
        tableView.register(UINib(nibName: "LanguageHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "LanguageHeaderView")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = TextConstants.ViewControllerTitle
        
        // NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.reloadImageSection(_:)), name:.IngredientsImageSet, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.refreshProduct), name:.ProductUpdated, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.removeProduct), name:.HistoryHasBeenDeleted, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.changeLanguage), name:.IngredientsTextViewTapped, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.reloadImageSection), name:.ImageSet, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.takePhotoButtonTapped), name:.IngredientsTakePhotoButtonTapped, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.useCameraRollButtonTapped), name:.IngredientsSelectFromCameraRollButtonTapped, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.imageUploaded), name:.OFFUpdateImageUploadSuccess, object:nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }

}

// MARK: - TextView Delegate Functions

extension IngredientsTableViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return editMode
        
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.isFirstResponder { textView.resignFirstResponder() }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let (currentProductSection, _, _) = tableStructureForProduct[textView.tag]
        switch currentProductSection {
        case .ingredients:
            if let validText = textView.text {
                delegate?.updated(ingredients: validText, languageCode: currentLanguageCode!)
            }
        default:
            break
        }
    }
    
    func textViewHeightForAttributedText(text: NSAttributedString, andWidth width: CGFloat) -> CGFloat {
        let calculationView = UITextView()
        calculationView.attributedText = text
        let size = calculationView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        return size.height
    }
    
}

// MARK: - TagListView Delegate functions

extension IngredientsTableViewController: TagListViewDelegate {
    
    
    public func tagListView(_ tagListView: TagListView, didAddTagWith title: String) {
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        switch currentProductSection {
        case .traces:
            switch tracesToDisplay {
            case .undefined, .empty:
                delegate?.update(tracesTags: [title])
            case var .available(list):
                list.append(title)
                delegate?.update(tracesTags: list)
            }
            // tableView.reloadData()
        case .labels:
            switch labelsToDisplay {
            case .undefined, .empty:
                delegate?.update(labelTags: [title])
            case var .available(list):
                list.append(title)
                delegate?.update(labelTags: list)
            }
            // tableView.reloadData()
        default:
            break
        }
    }
    
    public func tagListView(_ tagListView: TagListView, didDeleteTagAt index: Int) {
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        switch currentProductSection {
        case .traces:
            switch tracesToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                delegate?.update(tracesTags: list)
            }
            tableView.reloadData()
        case .labels:
            switch labelsToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                delegate?.update(labelTags: list)
            }
            tableView.reloadData()
        default:
            break
        }
    }
}

// MARK: - TagListView DataSource Functions

extension IngredientsTableViewController: TagListViewDataSource {
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        switch currentProductSection {
        case .allergens:
            switch allergensToDisplay {
            case .undefined:
                tagListView.normalColorScheme = ColorSchemes.error
                return 1
            case .empty:
                tagListView.normalColorScheme = ColorSchemes.none
                return 1
            case let .available(list):
                tagListView.normalColorScheme = ColorSchemes.normal
                return list.count
            }
            
        case .traces:
            switch tracesToDisplay {
            case .undefined:
                tagListView.normalColorScheme = ColorSchemes.error
                return editMode ? 0 : 1
            case .empty:
                tagListView.normalColorScheme = ColorSchemes.none
                return editMode ? 0 : 1
            case let .available(list):
                tagListView.normalColorScheme = ColorSchemes.normal
                return list.count
            }
        case .additives:
            switch additivesToDisplay {
            case .undefined:
                tagListView.normalColorScheme = ColorSchemes.error
                return 1
            case .empty:
                tagListView.normalColorScheme = ColorSchemes.none
                return 1
            case let .available(list):
                tagListView.normalColorScheme = ColorSchemes.normal
                return list.count
            }
        case .labels:
            switch labelsToDisplay {
            case .undefined:
                tagListView.normalColorScheme = ColorSchemes.error
                return editMode ? 0 : 1
            case .empty:
                tagListView.normalColorScheme = ColorSchemes.none
                return editMode ? 0 : 1
            case let .available(list):
                tagListView.normalColorScheme = ColorSchemes.normal
                return list.count
            }
        case .image:
            return 1
        default: break
        }
        return 0
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        switch currentProductSection {
        case .allergens:
            return allergensToDisplay.tagWithoutPrefix(index, locale:Locale.preferredLanguages[0])!
        case .traces:
            return tracesToDisplay.tagWithoutPrefix(index, locale:Locale.preferredLanguages[0])!
        case .additives:
            return additivesToDisplay.tagWithoutPrefix(index, locale:Locale.preferredLanguages[0])!
        case .labels:
            return labelsToDisplay.tagWithoutPrefix(index, locale:Locale.preferredLanguages[0])!
        case .image:
            return searchResult
        default: break
        }
        return("tagListView error")
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .automatic)
    }

}

extension IngredientsTableViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        newImageSelected(info: info)
        picker.dismiss(animated: true, completion: nil)
        // notify the delegate
    }
    
}


extension IngredientsTableViewController: GKImagePickerDelegate {
    
    func imagePicker(_ imagePicker: GKImagePicker, cropped image: UIImage) {
        delegate?.updated(ingredientsImage: image, languageCode: currentLanguageCode!)
        tableView.reloadData()
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - LanguageHeaderDelegate Functions

extension IngredientsTableViewController: LanguageHeaderDelegate {
    
    func changeLanguageButtonTapped(_ sender: UIButton, in section: Int) {
        performSegue(withIdentifier: Storyboard.SegueIdentifier.SelectLanguage, sender: sender)
    }
}




