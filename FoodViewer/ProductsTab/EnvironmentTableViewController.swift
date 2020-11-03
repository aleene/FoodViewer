//
//  EnvironmentTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 16/10/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit
import MobileCoreServices

class EnvironmentTableViewController: UITableViewController {
//
// MARK: - public variables
//
var delegate: ProductPageViewController? = nil {
    didSet {
        if delegate != oldValue {
                tableView.reloadData()
            }
        }
    }
    
    var coordinator: EnvironmentCoordinator? = nil
    
    private var editMode: Bool {
        return delegate?.editMode ?? false
    }
    
//
// MARK: - Fileprivate Functions/variables
//
    fileprivate enum ProductVersion {
        case remoteUser // data as entered by the user
        //case remoteTags // data interpreted by off
        case new // new data as entered by the user locally
        
        var isRemote: Bool {
            switch self {
            case .new:
                return false
            default:
                return true
            }
        }
    }
    
    // Determines which version of the product needs to be shown, the remote or local
    // Default is the edited product version and then the translated version
    fileprivate var productVersion: ProductVersion = .new

    fileprivate var productPair: ProductPair? {
        return delegate?.productPair
    }

    // The languageCode as defined by the user (double tapping/selecting)
    // The user can set for which language he wants to see the name/genericName and packaging image
    public var currentLanguageCode: String? {
        get {
            return delegate?.currentLanguageCode
        }
        set {
            // This is set when a new LanguageCode is added, the interface will be updated
            // so that the user can enter data for this new languageCode
            delegate?.currentLanguageCode = newValue
        }
    }
    
    // This variable defined the languageCode that must be used to display the product data
    // This is either the languageCode selected by the user or the best match for the current product
    private var displayLanguageCode: String? {
        return currentLanguageCode ?? productPair?.product?.matchedLanguageCode(codes: Locale.preferredLanguageCodes)
    }
    
    fileprivate var packagingToDisplay: Tags {
        get {
            switch productVersion {
            case .new:
                if let checked = checkedTags(productPair?.localProduct?.packagingOriginal) {
                    return checked
                }
                // no taxonomy in use
            //case .remoteTags:
            //    productPair?.remoteProduct?.packagingInterpreted ?? .undefined
            default: break
            }
            // remove the currentLanguage prefix if there is one
            let cleanedTags = productPair?.remoteProduct?.packagingOriginal.prefixed(withAdded: nil, andRemoved: Locale.interfaceLanguageCode)
            return  cleanedTags ?? .undefined
        }
    }
        
    fileprivate func checkedTags(_ tags:Tags?) -> Tags? {
        if let validTags = tags,
            validTags.isAvailable {
            return validTags
        }
        return nil
    }
    
    fileprivate var searchResult: String = ""

    // MARK: - Action methods
    
    // should redownload the current product and reload it in this scene
    @IBAction func refresh(_ sender: UIRefreshControl) {
        if refreshControl!.isRefreshing {
            OFFProducts.manager.reload(productPair: productPair)
            refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Tableview methods

    fileprivate var tableStructure: [SectionType] = []
    
    fileprivate enum SectionType {
        case packaging(Int, String)
        case image(Int, String)
        
        var header: String {
            switch self {
            case .packaging(_, let headerTitle),
                 .image(_, let headerTitle):
                return headerTitle
            }
        }
        
        var numberOfRows: Int {
            switch self {
            case .packaging(let numberOfRows, _),
                 .image(let numberOfRows, _):
                return numberOfRows
            }
        }
    }

    private var tagListViewHeight: [Int:CGFloat] = [:]
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // should return all sections
        return tableStructure.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableStructure[section].numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableStructure[indexPath.section] {
        case .packaging:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewTableViewCell.self), for: indexPath) as! TagListViewTableViewCell
            cell.setup(datasource: self, delegate: self, width: tableView.frame.size.width, tag: indexPath.section)
            return cell
            
        case .image:
            if currentImage.0 != nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: ProductImageTableViewCell.self), for: indexPath) as! ProductImageTableViewCell
                cell.editMode = editMode
                if editMode,
                    let localPair = localPackagingImage,
                    localPair.0 != nil {
                    cell.editMode = productVersion.isRemote ? false : true
                }
                cell.productImage = currentImage.0
                cell.uploadTime = currentImage.2
                cell.delegate = self
                return cell
            } else {
                searchResult = currentImage.1
                // Show a tag with the option to set an image
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewAddImageTableViewCell.self), for: indexPath) as! TagListViewAddImageTableViewCell
                cell.accessoryType = .none
                cell.setup(datasource: self, delegate: self, editMode: editMode, width: tableView.frame.size.width, tag: indexPath.section, prefixLabelText: nil, scheme: ColorSchemes.error)
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath:IndexPath) {
        tableView.deselectRow(at:indexPath, animated: false)
        switch tableStructure[indexPath.section] {
        case .image:
            if let validLanguageCode = displayLanguageCode {
                if let images = productPair?.localProduct?.packagingImages,
                    !images.isEmpty {
                    coordinator?.showImage(imageTitle: TranslatableStrings.Identification,
                                           imageSize: productPair!.localProduct!.image(for:validLanguageCode, of:.packaging))
                } else {
                    coordinator?.showImage(imageTitle: TranslatableStrings.Identification, imageSize: productPair!.remoteProduct!.image(for:validLanguageCode, of: .packaging))
                }
            }
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let validCell = cell as? TagListViewTableViewCell {
            validCell.willDisappear()
        } else if let validCell = cell as? TagListViewAddImageTableViewCell {
            validCell.willDisappear()
        }
        
    }

    public var currentImage: (UIImage?, String, Double?) {
        switch productVersion {
        case .new:
            return localPackagingImage ?? remotePackagingImage ?? ( nil,TranslatableStrings.NoImageAvailable, nil)
        default:
            return remotePackagingImage ?? (nil, TranslatableStrings.NoImageAvailable, nil)
        }
    }
    
    private var localPackagingImage: (UIImage?, String, Double?)? {
        if let images = productPair?.localProduct?.packagingImages,
            let validLanguageCode = displayLanguageCode,
            !images.isEmpty,
            let fetchResult = images[validLanguageCode]?.original?.fetch() {
            switch fetchResult {
            case .success(let image):
                return (image, "Updated Image", nil)
            default: break
            }
        }
        return nil
    }
    
    private var remotePackagingImage: (UIImage?, String, Double?)? {

        func processLanguageCode(_ languageCode: String) -> (UIImage?, String, Double?)?{
            guard let imageSet = productPair?.remoteProduct?.image(for: languageCode, of: .packaging) else { return nil }
            let result = imageSet.original?.fetch()
            switch result {
            case .success(let image):
                return (image, "Current Language Image", imageSet.imageDate)
            case .loading:
                return (nil, ImageFetchResult.loading.description, imageSet.imageDate)
            case .loadingFailed(let error):
                return (nil, error.localizedDescription, imageSet.imageDate)
            case .noResponse:
                return (nil, ImageFetchResult.noResponse.description, imageSet.imageDate)
            default:
                return nil
            }
        }
        
        guard let validDisplayLanguageCode = displayLanguageCode else { return nil }
        guard let validPrimaryLanguageCode = productPair?.remoteProduct?.primaryLanguageCode else { return nil }
        
        if editMode {
            return processLanguageCode(validDisplayLanguageCode)
        } else {
            return processLanguageCode(validDisplayLanguageCode) ?? processLanguageCode(validPrimaryLanguageCode)
        }
    }


    func changeLanguage() {
        // set the next language in the array
        if let availableLanguages = productPair!.remoteProduct?.languageCodes {
            let nextCode = nextLanguageCode()
            if availableLanguages.count > 1 && currentLanguageCode != nextCode {
                currentLanguageCode = nextCode
            }
        }
    }
    
    fileprivate func nextLanguageCode() -> String {
        if let product = productPair?.remoteProduct {
            if let validLanguageCode = currentLanguageCode,
                let currentIndex = product.languageCodes.firstIndex(of: validLanguageCode) {
                    let nextIndex = currentIndex == ( product.languageCodes.count - 1 ) ? 0 : currentIndex + 1
                    return product.languageCodes[nextIndex]
            } else {
                if let code = product.primaryLanguageCode {
                    return code
                }
            }
        }
        return "??"
    }
        
    fileprivate struct Constants {
        struct CellHeight {
            static let TagListViewCell = CGFloat(27.0)
            // This is the cell with two buttons on the right, which allow the user to add an image.
            static let TagListViewAddImageCell = CGFloat(25.0) + CGFloat(8.0) + CGFloat(25.0)
        }
        struct CellMargin {
            static let ContentView = CGFloat(11.0)
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let currentProductSection = tableStructure[section]
        
        var buttonNotDoubleTap: Bool {
            return ViewToggleModeDefaults.manager.buttonNotDoubleTap ?? ViewToggleModeDefaults.manager.buttonNotDoubleTapDefault
        }

        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: LanguageHeaderView.identifier) as! LanguageHeaderView
        headerView.section = section
        headerView.delegate = self
        // do not add any button or double tap
        headerView.buttonNotDoubleTap = buttonNotDoubleTap

        headerView.changeViewModeButton.isHidden = true
        var header = tableStructure[section].header
        // The headers with a language
        switch currentProductSection {
        case .image:
            if let validNumberOfProductLanguages = productPair?.remoteProduct?.languageCodes.count {
            // Hide the change language button if there is only one language, but not in editMode
                headerView.changeLanguageButton.isHidden = validNumberOfProductLanguages > 1 ? false : !editMode
            } else {
                headerView.changeLanguageButton.isHidden = false
            }
            switch currentProductSection {
            case .image:
                switch productVersion {
                case .new:
                    if let localPair = localPackagingImage,
                        localPair.0 != nil {
                        // the local version has been requested and is available
                        header = TranslatableStrings.PackagingImageEdited
                    } else {
                        header = TranslatableStrings.PackagingImage
                    }
                default:
                        // the local version has been requested and is available
                    header = TranslatableStrings.PackagingImageOriginal
                }
            default: break
            }
            headerView.title = header
            return headerView
        case .packaging:
            headerView.changeLanguageButton.isHidden = true

            switch currentProductSection {
            case .packaging:
                switch productVersion {
                case .new:
                    if let newTags = productPair?.localProduct?.packagingOriginal {
                        switch newTags {
                        case .available:
                            // the local version has been requested and is available
                            header = TranslatableStrings.PackagingEdited
                        default:
                            header = TranslatableStrings.Packaging
                        }
                    } else {
                        header = TranslatableStrings.Packaging
                    }
                default:
                //case .remoteUser:
                    header = TranslatableStrings.PackagingOriginal
                //case .remoteTags:
                //    header = TranslatableStrings.PackagingInterpreted
                }
            default:
                break
            }
            headerView.title = header
            return headerView
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        if let validView = view as? LanguageHeaderView {
            validView.willDisappear()
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentProductSection = tableStructure[indexPath.section]
        switch currentProductSection {
        case .packaging:
            let height = tagListViewHeight[indexPath.section] ?? Constants.CellHeight.TagListViewCell
            return height + 2 * Constants.CellMargin.ContentView
        case .image:
            if currentImage.0 != nil {
                // The height is determined by the image
                return UITableView.automaticDimension
            } else {
                // the height is determnined by the buttons
                let height = Constants.CellHeight.TagListViewAddImageCell
                return height + 2 * Constants.CellMargin.ContentView
            }
        //default:
        //    return UITableView.automaticDimension
        }
    }
    fileprivate struct TableSection {
        struct Size {
            static let Packaging = 1
            static let Image = 1
        }
        struct Header {
            static let Packaging = TranslatableStrings.Packaging
            static let Image = TranslatableStrings.MainImage
        }
    }

    fileprivate func setupSections() -> [SectionType] {
        // The returnValue is an array with sections
        // And each element is a  section type with the number of rows and the section title
        //
        //  The order of each element determines the order in the presentation
        var sectionsAndRows: [SectionType] = []
        sectionsAndRows.append(.packaging(TableSection.Size.Packaging, TableSection.Header.Packaging))
        sectionsAndRows.append(.image(TableSection.Size.Image,TableSection.Header.Image))

        return sectionsAndRows
    }

//
// MARK: - Notification handlers
//
    @objc func imageUpdated(_ notification: Notification) {
        guard !editMode else { return }
        let userInfo = (notification as NSNotification).userInfo
        guard userInfo != nil && imageSectionIndex != nil else { return }
        // only update if the image barcode corresponds to the current product
        if let barcodeString = productPair?.remoteProduct?.barcode.asString,
            let info = userInfo?[ProductImageData.Notification.BarcodeKey] as? String,
            barcodeString == info {
            // Filtering on image type, is not possible as unmarked images are read from cache
            reloadImageSection()
        }
    }
    
    private func reloadImageSection() {
        // The reloading of the image sectionresults in a crash
        tableView.reloadData() //.reloadSections([imageSectionIndex!], with: .none)
    }
    
    fileprivate var imageSectionIndex: Int? {
        for (index, sectionType) in tableStructure.enumerated() {
            switch sectionType {
            case .image:
                return index
            default:
                continue
            }
        }
        return nil
    }
    
    @objc func refreshProduct() {
        productVersion = .new
        tableView.reloadData()
        
    }


    fileprivate lazy var imagePicker: GKImagePicker = {
        let picker = GKImagePicker.init()
        picker.imagePickerController = UIImagePickerController.init()
        // picker.mediaTypes = [kUTTypeImage as String]
        return picker
    }()
    
    fileprivate func newImageSelected(info: [UIImagePickerController.InfoKey : Any]) {
        var image: UIImage? = nil
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
    }
    
    func takePhoto() {
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
    
    func selectCameraRollPhoto() {
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

    @objc func imageUploaded(_ notification: Notification) {
        guard !editMode else { return }
        // Check if this image is relevant to this product
        if let barcode = notification.userInfo?[ProductPair.Notification.BarcodeKey] as? String {
            if let productBarcode = productPair!.remoteProduct?.barcode.asString {
                if barcode == productBarcode {
                    // is it relevant to the main image?
                    if let id = notification.userInfo?[ProductPair.Notification.ImageTypeCategoryKey] as? String {
                        if id.contains(OFFHttpPost.AddParameter.ImageField.Value.Packaging) {
                            // reload product data
                            self.productPair?.reload()
                        }
                    }
                }
            }
        }
    }
    
    @objc func imageDeleted(_ notification: Notification) {
        // Check if this image was relevant to this product
        if let barcode = notification.userInfo?[ProductPair.Notification.BarcodeKey] as? String {
            if barcode == productPair!.remoteProduct!.barcode.asString {
                // is it relevant to the main image?
                if let id = notification.userInfo?[ProductPair.Notification.ImageTypeCategoryKey] as? String {
                    if id.contains(OFFHttpPost.AddParameter.ImageField.Value.Ingredients) {
                        // reload product data
                        self.productPair?.reload()
                    }
                }
            }
        }
    }

    @objc func doubleTapOnTableView() {
        // double tapping implies cycling through the product possibilities
        switch productVersion {
        case .new:
            productVersion = .remoteUser
        case .remoteUser:
            productVersion = .new
        }
        tableView.reloadData()
    }

// MARK: - ViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        coordinator = EnvironmentCoordinator.init(with: self)

        if #available(iOS 11.0, *) {
            tableView.dragDelegate = self
            tableView.dropDelegate = self
        }
        
        self.tableView.estimatedRowHeight = 44.0
        tableView.allowsSelection = true
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 70
        tableView.register(UINib(nibName: LanguageHeaderView.identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: LanguageHeaderView.identifier)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableStructure = setupSections()
        tableView.reloadData()

        navigationController?.setNavigationBarHidden(false, animated: false)
        
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(IdentificationTableViewController.refreshProduct),
            name: .ProductPairLocalStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.imageUpdated(_:)), name:.ImageSet, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.refreshProduct), name:.ProductPairRemoteStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.refreshProduct), name:.ProductUpdateSucceeded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.refreshProduct), name:.HistoryHasBeenDeleted, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.imageUploaded(_:)), name:.ProductPairImageUploadSuccess, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.imageDeleted(_:)), name:.ProductPairImageDeleteSuccess, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.imageDeleted(_:)), name:.OFFProductsImageDeleteSuccess, object:nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
        OFFplists.manager.flush()
    }

}

//
// MARK: - IdentificationImageCellDelegate Functions
//
extension EnvironmentTableViewController: ProductImageCellDelegate {
    
    func productImageTableViewCell(_ sender: ProductImageTableViewCell, receivedActionOnCamera button:UIButton) {
        takePhoto()
        }
    
    func productImageTableViewCell(_ sender: ProductImageTableViewCell, receivedActionOnCameraRoll button:UIButton) {
        selectCameraRollPhoto()
    }
    
    func productImageTableViewCell(_ sender: ProductImageTableViewCell, receivedActionOnDeselect button: UIButton) {
        guard let validLanguageCode = displayLanguageCode,
        let validProductPair = productPair else { return }
        OFFProducts.manager.deselectImage(for: validProductPair, in: validLanguageCode, of: .packaging)
    }
    
}
//
// MARK: - TagListViewAddImageCellDelegate functions
//
extension EnvironmentTableViewController: TagListViewAddImageCellDelegate {
    
    func tagListViewAddImageTableViewCell(_ sender: TagListViewAddImageTableViewCell, receivedActionOnCamera button:UIButton) {
        takePhoto()
    }
    
    func tagListViewAddImageTableViewCell(_ sender: TagListViewAddImageTableViewCell, receivedActionOnCameraRoll button:UIButton) {
        selectCameraRollPhoto()
    }
    
}
//
// MARK: - TagListView DataSource Functions
//
extension EnvironmentTableViewController: TagListViewDataSource {
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        
        func count(_ tags: Tags) -> Int {
            switch tags {
            case .undefined:
                tagListView.normalColorScheme = ColorSchemes.error
                return editMode ? 0 : 1
            case .empty:
                tagListView.normalColorScheme = ColorSchemes.none
                return editMode ? 0 : 1
            case let .available(list):
                tagListView.normalColorScheme = ColorSchemes.normal
                return list.count
            case .notSearchable:
                tagListView.normalColorScheme = ColorSchemes.error
                return 1
            }
        }
        
        let currentProductSection = tableStructure[tagListView.tag]
        
        switch currentProductSection {
        case .packaging:
            return count(packagingToDisplay)
        case .image:
            return 1
        }
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        // print("height", tagListView.frame.size.height)
        
        func title(_ tags: Tags) -> String {
            switch tags {
            case .undefined, .empty, .notSearchable:
                return tags.description()
            case .available:
                return tags.tag(at:index) ?? "EnvironmentTableViewController: Tag index out of bounds"
            }
        }
        
        let currentProductSection = tableStructure[tagListView.tag]
        switch currentProductSection {
        case .packaging:
            return title(packagingToDisplay)
        case .image:
            return searchResult
        //default:
        //    return("EnvironmentTableViewController: TagListView titleForTagAt error")
        }
    }

    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        if let cellHeight = tagListViewHeight[tagListView.tag],
            abs(cellHeight - height) > CGFloat(3.0) {
            tagListViewHeight[tagListView.tag] = height
            tableView.setNeedsLayout()
        }
    }

}
//
// MARK: - TagListViewDelegate Functions
//
extension EnvironmentTableViewController: TagListViewDelegate {
        
    func tagListViewCanDeleteTags(_ tagListView: TagListView) -> Bool {
        switch tableStructure[tagListView.tag] {
        case .packaging:
            return editMode
        default:
            return false
        }
    }

    public func tagListViewCanAddTags(_ tagListView: TagListView) -> Bool {
        switch tableStructure[tagListView.tag] {
        case .packaging:
            return editMode
        default:
            return false
        }
    }
    
    public func tagListView(_ tagListView: TagListView, didTapTagAt index: Int) {
    }

    public func tagListView(_ tagListView: TagListView, didAddTagWith title: String) {
        switch tableStructure[tagListView.tag] {
        case .packaging:
            switch packagingToDisplay {
            case .undefined, .empty:
                productPair?.update(packagingTags: [title])
            case .available(var list):
                list.append(title)
                productPair?.update(packagingTags: list)
            default:
                assert(true, "EnvironmentTableViewController: How can I add a packaging tag when the field is non-editable")
            }
        default:
            return
        }
        tableView.reloadData()
    }
    
    public func tagListView(_ tagListView: TagListView, didDeleteTagAt index: Int) {
        let currentProductSection = tableStructure[tagListView.tag]
        switch currentProductSection {
        case .packaging:
            switch packagingToDisplay {
            case .undefined, .empty:
                assert(true, "EnvironmentTableViewController: How can I delete a tag when there are none")
            case .available(var list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                productPair?.update(packagingTags: list)
            case .notSearchable:
                assert(true, "EnvironmentTableViewController: How can I add a tag when the field is non-editable")
            }
        default:
            return
        }
        tableView.reloadData()
    }
    
    public func tagListView(_ tagListView: TagListView, didLongPressTagAt index: Int) {
        
        let currentProductSection = tableStructure[tagListView.tag]
        switch currentProductSection {
        case .packaging:
            switch productPair!.remoteProduct!.packagingInterpreted {
            case .available:
                delegate?.search(for: productPair!.remoteProduct!.packagingInterpreted.tag(at: index), in: .packaging)
            default:
                break
            }

        default:
            break

        }
    }
    
    /// Called if the user wants to delete all tags
    public func didDeleteAllTags(_ tagListView: TagListView) {
        let currentProductSection = tableStructure[tagListView.tag]
        switch currentProductSection {
        case .packaging:
            switch packagingToDisplay {
            case .available(var list):
                list.removeAll()
                productPair?.update(packagingTags: list)
            default:
                assert(true, "IdentificationTableViewController: How can I delete a tag when there are none")
                
            }
        default:
            return
        }
        tableView.reloadData()
    }

}
//
// MARK: - UIImagePickerControllerDelegate Functions
//
extension EnvironmentTableViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        newImageSelected(info: info)
        picker.dismiss(animated: true, completion: nil)
    }

}
//
// MARK: - UIPopoverPresentationControllerDelegate Functions
//
extension EnvironmentTableViewController: UIPopoverPresentationControllerDelegate {
    
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
//
// MARK: - GKImagePickerDelegate Functions
//
extension EnvironmentTableViewController: GKImagePickerDelegate {
    
    func imagePicker(_ imagePicker: GKImagePicker, cropped image: UIImage) {
        guard let validLanguageCode = displayLanguageCode else { return }
        productPair?.update(packagingImage: image, for: validLanguageCode)
        tableView.reloadData()
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
//
// MARK: - LanguageHeaderDelegate Functions
//
extension EnvironmentTableViewController: LanguageHeaderDelegate {
    
    func changeLanguageButtonTapped(_ sender: UIButton, in section: Int) {
    }
    
    func changeViewModeButtonTapped(_ sender: UIButton, in section: Int) {
    }
}
//
// MARK: - UIDragInteractionDelegate Functions
//
@available(iOS 11.0, *)
extension EnvironmentTableViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItems(for: session, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(for: session, at: indexPath)
    }
    
    private func dragItems(for session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let validLanguageCode = displayLanguageCode else { return [] }
        var productImageData: ProductImageData? = nil
        // is there image data?
        if let localProduct = productPair?.localProduct {
            if !localProduct.packagingImages.isEmpty {
                productImageData = localProduct.image(for:validLanguageCode, of:.packaging)?.largest
            } else {
                productImageData = localProduct.image(for:validLanguageCode, of:.packaging)?.largest
            }
        }
        // The largest image here is the display image, as the url for the original packaging image is not offered by OFF in an easy way
        guard productImageData != nil else { return [] }
        
        guard let validProductImageData = productImageData else { return [] }
        
        // only allow flocking of another productImageSize
        for item in session.items {
            // Note kUTTypeImage is defined in MobileCoreServices, so need to import
            // This is an image, as that is what I offer to export
            guard item.itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) else { return [] }
        }
        
        switch tableStructure[indexPath.section] {
        case .image :
            // check if the selected image has not been added yet
            for item in session.items {
                guard item.localObject as! ProductImageData != validProductImageData else { return [] }
            }
            let provider = NSItemProvider(object: validProductImageData)
            let item = UIDragItem(itemProvider: provider)
            return [item]
        default:
            break
        }
        return []
    }
    
    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {

        switch tableStructure[indexPath.section] {
        case .image :
            if let cell = tableView.cellForRow(at: indexPath) as? ProductImageTableViewCell,
                let rect = cell.productImageView.imageRect {
                let parameters = UIDragPreviewParameters.init()
                parameters.visiblePath = UIBezierPath(roundedRect: rect, cornerRadius: 15)
                return parameters
            }
        default:
            break
        }
        return nil

    }
    
}

// MARK: - UITableViewDropDelegate Functions

@available(iOS 11.0, *)
extension EnvironmentTableViewController: UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        
        func setImage(image: UIImage) {
            let cropController = GKImageCropViewController.init()
            cropController.sourceImage = image
            cropController.view.frame = tableView.frame
            //cropController.preferredContentSize = picker.preferredContentSize
            cropController.hasResizableCropArea = true
            cropController.cropSize = CGSize.init(width: 300, height: 300)
            cropController.delegate = self
            cropController.modalPresentationStyle = .fullScreen

            present(cropController, animated: true, completion: nil)
            if let popoverPresentationController = cropController.popoverPresentationController {
                popoverPresentationController.sourceRect = tableView.frame
                popoverPresentationController.sourceView = self.view
            }
            //self.pushViewController(cropController, animated: false)
        }

        //guard currentLanguageCode != nil else { return }
        coordinator.session.loadObjects(ofClass: UIImage.self) { (images) in
            // Only one image is accepted as ingredients image for the current language
            if let validImage = (images as? [UIImage])?.first {
                setImage(image: validImage)
                //self.delegate?.updated(packagingImage: validImage, languageCode:self.currentLanguageCode!)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        // Only accept if an image is hovered above the image section
        if let validIndexPathSection = destinationIndexPath?.section {
            
            switch tableStructure[validIndexPathSection] {
            case .image :
                return editMode ? UITableViewDropProposal(operation: .copy, intent: .unspecified) : UITableViewDropProposal(operation: .forbidden, intent: .unspecified)
            default:
                break
            }
        }
        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
        
    }
}

// MARK: - GKImageCropController Delegate Methods

extension EnvironmentTableViewController: GKImageCropControllerDelegate {
    
    public func imageCropController(_ imageCropController: GKImageCropViewController, didFinishWith croppedImage: UIImage?) {
        guard let validLanguage = displayLanguageCode,
            let validImage = croppedImage else { return }
        imageCropController.dismiss(animated: true, completion: nil)
        productPair?.update(packagingImage: validImage, for: validLanguage)
        self.reloadImageSection()
    }
}
