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
    
    var delegate: ProductPageViewController? = nil {
        didSet {
            if delegate != oldValue {
                refreshProduct()
            }
        }
    }

    var coordinator: IngredientsCoordinator? = nil
    
    fileprivate var tableStructure: [SectionType] = []
    
    fileprivate enum ProductVersion {
        case remoteUser // data as entered by the user
        case remoteTags // data interpreted by off
        case remoteTagsTranslated
        case remoteTagsHierarchy
        case remoteTagsHierarchyTranslated
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
    fileprivate var productVersion: ProductVersion = .new
    
    fileprivate var ingredientsImage: UIImage? = nil {
        didSet {
            refreshProduct()
        }
    }
    
// MARK: - Tags variables
    
    fileprivate var ingredientsToDisplay: Tags {
        get {
            switch productVersion {
            case .new:
                // show the local ingredients if available
                guard let validLanguageCode = displayLanguageCode,
                    let text = productPair?.localProduct?.ingredientsLanguage[validLanguageCode] ??
                    productPair?.remoteProduct?.ingredientsLanguage[validLanguageCode],
                    let validText = text else { return .empty }
                return Tags.init(text: validText)
            case .remoteTags:
                return availableTags(productPair?.remoteProduct?.ingredientsTags) ?? .undefined
            case .remoteTagsTranslated:
                return availableTags(productPair?.remoteProduct?.ingredientsTranslated) ?? .undefined
            case .remoteTagsHierarchy:
                return availableTags(productPair?.remoteProduct?.ingredientsHierarchy) ?? .undefined
            case .remoteTagsHierarchyTranslated:
                return availableTags(productPair?.remoteProduct?.ingredientsHierarchyTranslated) ?? .undefined
            default:
                // always show the remote ingredients
                guard let validLanguageCode = displayLanguageCode,
                    let text = productPair?.remoteProduct?.ingredientsLanguage[validLanguageCode],
                    let validText = text else { return .undefined }
                return Tags.init(text: validText)
            }
        }
    }


    fileprivate var allergensToDisplay: Tags {
        get {
            switch productVersion {
            case .remoteTags:
                return availableTags(productPair?.remoteProduct?.allergensInterpreted) ?? .undefined
            default:
                return availableTags(productPair?.remoteProduct?.allergensTranslated) ?? .undefined
            }
            // There are no local tags. 
        }
    }

    fileprivate var mineralsToDisplay: Tags {
        get {
            switch productVersion {
            case .remoteTags:
                return availableTags(productPair?.remoteProduct?.minerals) ?? .undefined
            default:
                return availableTags(productPair?.remoteProduct?.mineralsTranslated) ?? .undefined
            }
        }
    }

    fileprivate var vitaminsToDisplay: Tags {
        get {
            switch productVersion {
            case .remoteTags:
                return availableTags(productPair?.remoteProduct?.vitamins) ?? .undefined
            default:
                return availableTags(productPair?.remoteProduct?.vitaminsTranslated) ?? .undefined
            }
        }
    }
    
    fileprivate var nucleotidesToDisplay: Tags {
        get {
            switch productVersion {
            case .remoteTags:
                return availableTags(productPair?.remoteProduct?.nucleotides) ?? .undefined
            default:
                return availableTags(productPair?.remoteProduct?.nucleotidesTranslated) ?? .undefined
            }
        }
    }

    fileprivate var otherNutritionalSubstancesToDisplay: Tags {
        get {
            switch productVersion {
            case .remoteTags:
                return availableTags(productPair?.remoteProduct?.otherNutritionalSubstances) ?? .undefined
            default:
                return availableTags(productPair?.remoteProduct?.otherNutritionalSubstancesTranslated) ?? .undefined
            }
        }
    }
    
    fileprivate var tracesToDisplay: Tags {
        get {
            switch productVersion {
            case .new:
                if let checked = availableTags(productPair?.localProduct?.tracesTranslated) {
                    return checked
                }
            case .remoteTags:
                return availableTags(productPair?.remoteProduct?.tracesInterpreted) ?? .undefined
            case .remoteUser:
                return availableTags(productPair?.remoteProduct?.tracesOriginal) ?? .undefined
            default: break
            }
            return availableTags(productPair?.remoteProduct?.tracesTranslated) ?? .undefined
        }
    }
    
    fileprivate var additivesToDisplay: Tags {
        get {
            switch productVersion {
            case .remoteTags:
                return availableTags(productPair?.remoteProduct?.additivesInterpreted) ?? .undefined
            default:
                return availableTags(productPair?.remoteProduct?.additivesTranslated) ?? .undefined
            }
        }
    }

    fileprivate var aminoAcidsToDisplay: Tags {
        get {
            switch productVersion {
            case .remoteTags:
                return availableTags(productPair?.remoteProduct?.aminoAcids) ?? .undefined
            default:
                return availableTags(productPair?.remoteProduct?.aminoAcidsTranslated) ?? .undefined
            }
        }
    }

    fileprivate var labelsToDisplay: Tags {
        get {
            switch productVersion {
            case .new:
                if let checked = availableTags(productPair?.localProduct?.labelsOriginal) {
                    return checked
                }
            case .remoteTags:
                return availableTags(productPair?.remoteProduct?.labelsInterpreted) ?? .undefined
            case .remoteUser:
                return availableTags(productPair?.remoteProduct?.labelsOriginal) ?? .undefined
            default: break
            }
            // the original labels are in the product main language
            // In non-editMode the translated and interpreted labels are shown,
            // otherwise the original labels with the main product language removed
            return editMode
                ? ( availableTags(productPair?.remoteProduct?.labelsOriginal)?.prefixed(withAdded: nil, andRemoved: productPair?.primaryLanguageCode) ?? .undefined )
                :  availableTags(productPair?.remoteProduct?.labelsTranslated)
                    ?? .undefined
        }
    }
    
    fileprivate func availableTags(_ tags:Tags?) -> Tags? {
        if let validTags = tags,
            validTags.isAvailable {
            return validTags
        }
        return nil
    }

    fileprivate var searchResult: String = ""

    private var uploadProgressRatio: CGFloat? = nil

    private var imageUploadTime: Double?
        
    private var ocrRequest: OFFOCRRequestAPI? = nil
    
    private var selectedSection: Int? = nil

    fileprivate var productPair: ProductPair? {
        return delegate?.productPair
    }
    

    var currentLanguageCode: String? {
        get {
            return delegate?.currentLanguageCode
        }
        set {
            delegate?.currentLanguageCode = newValue
        }
    }
    
    // This variable defined the languageCode that must be used to display the product data
    // It first does a validity check
    private var displayLanguageCode: String? {
        get {
            let value = currentLanguageCode ?? productPair?.product?.matchedLanguageCode(codes: Locale.preferredLanguageCodes)
            return value
        }
    }
    
    private var editMode: Bool {
        return self.delegate?.editMode ?? false
    }

    
    // MARK: - Actions and Outlets
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        if refreshControl!.isRefreshing {
            OFFProducts.manager.reload(productPair: productPair)
            refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Table view data source
    
    fileprivate enum SectionType {
        case ingredients(Int)
        case allergens(Int)
        case minerals(Int)
        case vitamins(Int)
        case nucleotides(Int)
        case otherNutritionalSubstances(Int)
        case traces(Int)
        case labels(Int)
        case additives(Int)
        case aminoAcids(Int)
        case image(Int)
        
        var numberOfRows: Int {
            switch self {
            case .ingredients(let numberOfRows),
                 .minerals(let numberOfRows),
                 .vitamins(let numberOfRows),
                 .nucleotides(let numberOfRows),
                 .otherNutritionalSubstances(let numberOfRows),
                 .allergens(let numberOfRows),
                 .traces(let numberOfRows),
                 .labels(let numberOfRows),
                 .additives(let numberOfRows),
                 .aminoAcids(let numberOfRows),
                 .image(let numberOfRows):
                return numberOfRows
            }
        }
    }
    
    private var cellHeight: [Int:CGFloat] = [:]
    
    fileprivate struct Constants {
        struct CellHeight {
            static let TagListViewCell = CGFloat(27.0)
            static let TagListViewAddImageCell = 2 * CGFloat(25.0) + CGFloat(8.0)
        }
        struct CellMargin {
            static let ContentView = CGFloat(11.0)
        }
    }

    fileprivate struct TextConstants {
        static let ShowIdentificationTitle = TranslatableStrings.Image
    }
        
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableStructure.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = tableStructure[section].numberOfRows
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print(tableView.frame.size.width)

        switch tableStructure[indexPath.section] {
        case .ingredients:
            switch productVersion {
            case .remoteTags, .remoteTagsHierarchy, .remoteTagsTranslated, .remoteTagsHierarchyTranslated:
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewTableViewCell.self), for: indexPath) as! TagListViewTableViewCell
                cell.setup(datasource: self, delegate: self, width: tableView.frame.size.width, tag: indexPath.section)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: IngredientsFullTableViewCell.self), for: indexPath) as! IngredientsFullTableViewCell
                cell.delegate = self
                cell.textViewTag = indexPath.section
                cell.editMode = editMode // currentLanguageCode == product!.primaryLanguageCode ? editMode : false
                if let validLanguageCode = displayLanguageCode,
                    productPair?.localProduct?.ingredientsLanguage[validLanguageCode] != nil {
                    cell.editMode = productVersion.isRemote ? false : true
                }

            //cell.textView.textColor = .gray
            switch ingredientsToDisplay {
            case .available(let array):
                if !array.isEmpty && !array.first!.isEmpty {
                    cell.ingredients = array.first
                } else {
                    fallthrough
                }
            default:
                cell.ingredients = editMode ? TranslatableStrings.PlaceholderIngredients : nil
            }
            cell.isMultilingual =  (productPair?.product?.languageCodes.count ?? 0) > 1 ? true : false 
            cell.buttonNotDoubleTap = ViewToggleModeDefaults.manager.buttonNotDoubleTap ?? ViewToggleModeDefaults.manager.buttonNotDoubleTapDefault
            // jkhfkhdprint(cell.frame.size.height)
            return cell
            }

        case .allergens, .additives, .minerals, .vitamins, .nucleotides, .otherNutritionalSubstances, .aminoAcids:
        // These are all calculated fields, i.e. determined by OFF
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for:TagListViewTableViewCell.self), for: indexPath) as! TagListViewTableViewCell
            cell.setup(datasource: self, delegate: nil, width: tableView.frame.size.width, tag: indexPath.section)
            return cell

        case .traces:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewButtonTableViewCell.self), for: indexPath) as! TagListViewButtonTableViewCell
            cell.setup(datasource: self, delegate: self, showButton: !editMode, width: tableView.frame.size.width, tag: indexPath.section)
            return cell

        case .labels:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for:TagListViewTableViewCell.self), for: indexPath) as! TagListViewTableViewCell
            cell.setup(datasource: self, delegate: self, width: tableView.frame.size.width, tag: indexPath.section)
            return cell
        
        case .image:
            if imageToShow != nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for:ProductImageTableViewCell.self), for: indexPath) as! ProductImageTableViewCell
                cell.editMode = editMode
                if localImageToShow != nil {
                    cell.editMode = productVersion.isRemote ? false : true
                }
                // show the up-/download ratio
                cell.progressRatio = self.uploadProgressRatio
                cell.productImage = imageToShow
                cell.uploadTime = imageUploadTime
                cell.delegate = self
                return cell
            } else {
                searchResult = TranslatableStrings.NoImageAvailable
                // Show a tag with the option to set an image
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for:TagListViewAddImageTableViewCell.self), for: indexPath) as! TagListViewAddImageTableViewCell
                cell.accessoryType = .none
                cell.setup(datasource: self, delegate: self, editMode: editMode, width: tableView.frame.size.width, tag: indexPath.section, prefixLabelText: nil, scheme: ColorSchemes.error)
                return cell
            }
        }
    }
    
    private var imageToShow: UIImage? {
        switch productVersion {
        case .new:
            return localImageToShow ?? remoteImageToShow
        default:
            return remoteImageToShow

        }
    }
    
    private var remoteImageToShow: UIImage? {
        
        func processLanguageCode(_ languageCode: String) -> UIImage? {
            guard let imageSet = productPair?.remoteProduct?.image(imageType: .ingredients(languageCode)) else { return nil }
            let result = imageSet.original?.fetch()
            switch result {
            case .success(let image):
                self.imageUploadTime = imageSet.imageDate
                return image
            case .loading, .noResponse:
                searchResult = result?.description ?? "NO"
                return nil
            case .loadingFailed(let error):
                searchResult = error.localizedDescription
                return nil
            default:
                return nil
            }
        }
        
        guard let validDisplayLanguageCode = displayLanguageCode else { return nil }
        guard let validPrimaryLanguageCode = productPair?.remoteProduct?.primaryLanguageCode else { return nil }
        
        if editMode {
            return processLanguageCode(validDisplayLanguageCode)
        } else {
            // Try the display languageCode image first.
            // If that is not there try to fallback to the primary languageCode image
            return processLanguageCode(validDisplayLanguageCode) ?? processLanguageCode(validPrimaryLanguageCode)
        }
    }
    
    private var localImageToShow: UIImage? {
        if let images = productPair?.localProduct?.ingredientsImages,
            !images.isEmpty,
            let validLanguageCode = displayLanguageCode,
            let fetchResult = images[validLanguageCode]?.original?.fetch() {
            switch fetchResult {
            case .success(let image):
                return image
            default: break
            }
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableStructure[indexPath.section] {
        case .image:
            if imageToShow != nil {
                // The height is determined by the image
                return UITableView.automaticDimension
            } else {
                // the height is determined by the buttons
                let height = Constants.CellHeight.TagListViewAddImageCell
                return height + 2 * Constants.CellMargin.ContentView
            }
        case .ingredients:
            return cellHeight[0] ?? 44.0
        default:
            let height = cellHeight[indexPath.section] ?? Constants.CellHeight.TagListViewCell
            return height + 2 * Constants.CellMargin.ContentView
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSection = indexPath.section
        switch tableStructure[indexPath.section] {
        case .image:
            if let validLanguageCode = displayLanguageCode {
                if let images = productPair?.localProduct?.ingredientsImages,
                    !images.isEmpty {
                    coordinator?.showImage(imageTitle: TextConstants.ShowIdentificationTitle, imageSize: productPair!.localProduct!.image(imageType:.ingredients(validLanguageCode)))
                } else {
                    coordinator?.showImage(imageTitle: TextConstants.ShowIdentificationTitle, imageSize: productPair!.remoteProduct!.image(imageType: .ingredients(validLanguageCode)))
                }
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        switch tableStructure[indexPath.section] {
        case .image, .ingredients:
            return indexPath
        default:
            break
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let validCell = cell as? TagListViewTableViewCell {
            validCell.willDisappear()
        } else if let validCell = cell as? IngredientsFullTableViewCell {
            validCell.willDisappear()
        } else if let validCell = cell as? TagListViewAddImageTableViewCell {
            validCell.willDisappear()
        } else if let validCell = cell as? TagListViewButtonTableViewCell {
            validCell.willDisappear()
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
        headerView.changeViewModeButton.isHidden = true
        headerView.buttonNotDoubleTap = buttonNotDoubleTap
        headerView.setButtonTypeToOCR = false
        var header = ""

        switch currentProductSection {
        case .image, .ingredients : // Header with a language
            headerView.changeLanguageButton.isHidden = true
            switch currentProductSection {
            case .image:
                if let validNumberOfProductLanguages = productPair?.remoteProduct?.languageCodes.count {
                // Hide the change language button if there is only one language, but not in editMode
                    headerView.changeLanguageButton.isHidden = validNumberOfProductLanguages > 1 ? false : !editMode
                } else {
                    headerView.changeLanguageButton.isHidden = false
                }
                headerView.setButtonTypeToOCR = editMode
                switch productVersion {
                case .new:
                    if localImageToShow != nil {
                    // the local version has been requested and is available
                        header = TranslatableStrings.IngredientsImageEdited
                    } else {
                        header = TranslatableStrings.IngredientsImage
                    }
                default:
                    header = TranslatableStrings.IngredientsImageOriginal
                }
                headerView.title = header + " "

            case .ingredients:
                switch productVersion {
                case .new:
                    if let validLanguageCode = displayLanguageCode,
                        productPair?.localProduct?.ingredientsLanguage[validLanguageCode] != nil {
                        // the local version has been requested and is available
                        header = TranslatableStrings.IngredientsEdited
                    } else {
                        header = TranslatableStrings.Ingredients
                    }
                    headerView.changeLanguageButton.isHidden = false
                case .remoteTags:
                    header = TranslatableStrings.IngredientsNormalized
                case .remoteTagsTranslated:
                    header = TranslatableStrings.IngredientsTranslated
                case .remoteTagsHierarchy:
                    header = TranslatableStrings.IngredientsHierarchy
                case .remoteTagsHierarchyTranslated:
                    header = TranslatableStrings.IngredientsHierarchyTranslated
                default:
                    headerView.changeLanguageButton.isHidden = false
                    header = TranslatableStrings.IngredientsOriginal
                }
            default:
                break
            }
            headerView.title = headerView.changeLanguageButton.isHidden ? header : header + " "
            headerView.buttonText = OFFplists.manager.languageName(for: displayLanguageCode)
            headerView.languageButtonIsEnabled = editMode ? true : ( (productPair?.product?.languageCodes.count ?? 0) > 1 ? true : false )
            headerView.changeViewModeButton.isHidden = editMode
            return headerView
        
        case .labels, .traces, .additives, .allergens, .aminoAcids, .minerals, .vitamins, .nucleotides, .otherNutritionalSubstances:
            headerView.changeLanguageButton.isHidden = true
            headerView.changeViewModeButton.isHidden = editMode
            switch currentProductSection {
            case .labels:
                switch productVersion {
                case .new:
                    if let newTags = productPair?.localProduct?.labelsOriginal {
                        switch newTags {
                        case .available:
                            // the local version has been requested and is available
                            header = TranslatableStrings.LabelsEdited
                        default:
                            header = TranslatableStrings.Labels
                        }
                    } else {
                        header = TranslatableStrings.Labels
                    }
                case .remoteUser:
                    header = TranslatableStrings.LabelsOriginal
                case .remoteTags:
                    header = TranslatableStrings.LabelsNormalized
                default:
                    header = TranslatableStrings.LabelsTranslated
                }

            case .traces:
                switch productVersion {
                case .new:
                    if let newTags = productPair?.localProduct?.tracesOriginal {
                        switch newTags {
                        case .available:
                            // the local version has been requested and is available
                                header = TranslatableStrings.TracesEdited
                        default:
                            header = TranslatableStrings.Traces
                        }
                    } else {
                        header = TranslatableStrings.Traces
                    }
                case .remoteUser:
                    header = TranslatableStrings.TracesOriginal
                case .remoteTags:
                    header = TranslatableStrings.TracesNormalized
                default:
                    header = TranslatableStrings.TracesTranslated
                }
            case .additives:
                switch productVersion {
                case .new:
                    header = TranslatableStrings.DetectedAdditives
                case .remoteTags:
                    header = TranslatableStrings.DetectedAdditivesNormalized
                default:
                    header = TranslatableStrings.DetectedAdditivesTranslated
                }

            case .allergens:
                switch productVersion {
                case .new:
                    header = TranslatableStrings.DetectedAllergens
                case .remoteTags:
                    header = TranslatableStrings.DetectedAllergensNormalized
                default:
                    header = TranslatableStrings.DetectedAllergensTranslated
                }
            case .minerals:
                switch productVersion {
                case .new:
                    header = TranslatableStrings.DetectedMinerals
                case .remoteTags:
                    header = TranslatableStrings.DetectedMineralsNormalized
                default:
                    header = TranslatableStrings.DetectedMineralsTranslated
                }
            case .aminoAcids:
                switch productVersion {
                case .new:
                    header = TranslatableStrings.DetectedAminoAcids
                case .remoteTags:
                    header = TranslatableStrings.DetectedAminoAcidsNormalized
                default:
                    header = TranslatableStrings.DetectedAminoAcidsTranslated
                }

            case .otherNutritionalSubstances:
                switch productVersion {
                case .new:
                    header = TranslatableStrings.DetectedOtherNutritionalSubstances
                case .remoteTags:
                    header = TranslatableStrings.DetectedOtherNutritionalSubstancesNormalized
                default:
                    header = TranslatableStrings.DetectedOtherNutritionalSubstancesTranslated
                }
            case .vitamins:
                switch productVersion {
                case .new:
                    header = TranslatableStrings.DetectedVitamins
                case .remoteTags:
                    header = TranslatableStrings.DetectedVitaminsNormalized
                default:
                    header = TranslatableStrings.DetectedVitaminsTranslated
                }
            case .nucleotides:
                switch productVersion {
                case .new:
                    header = TranslatableStrings.DetectedNucleotides
                case .remoteTags:
                    header = TranslatableStrings.DetectedNucleotidesNormalized
                default:
                    header = TranslatableStrings.DetectedNucleotidesTranslated
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

    fileprivate func nextLanguageCode() -> String {
        if let product = productPair?.remoteProduct {
            if let validLanguageCode = displayLanguageCode,
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

    fileprivate struct TableSection {
        struct Size {
            static let Ingredients = 1
            static let Minerals = 1
            static let Vitamins = 1
            static let Nucleotides = 1
            static let OtherNutritionalSubstances = 1
            static let Allergens = 1
            static let Traces = 1
            static let Additives = 1
            static let Labels = 1
            static let Image = 1
        }
    }
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }
    
    fileprivate func setupSections() -> [SectionType] {
        // The returnValue is an array with sections
        // And each element is a  section type with the number of rows and the section title
        //
        guard let validProductPair = productPair else { return [] }
        
        let show = NegativeIngredientDetectionsDefaults.manager.negativeIngredientDetectionsShown ?? NegativeIngredientDetectionsDefaults.manager.negativeIngredientDetectionsShownDefault
        
        //  The order of each element determines the order in the presentation
        var sectionsAndRows: [SectionType] = []
        var rowIndex = 0
        
        sectionsAndRows.append(.ingredients(TableSection.Size.Ingredients))
        cellHeight[0] = 44.0
        rowIndex += 1
        // not needed for .product, .petFood and .beauty
        switch currentProductType {
        case .food:
            // 1:  allergens section
            if validProductPair.hasAllergens || show {
                sectionsAndRows.append(.allergens(TableSection.Size.Allergens))
                cellHeight[rowIndex] = Constants.CellHeight.TagListViewCell
                rowIndex += 1
            }
            
            // 2: traces section
            sectionsAndRows.append(.traces(TableSection.Size.Traces))
            cellHeight[rowIndex] = Constants.CellHeight.TagListViewCell
            rowIndex += 1

            if validProductPair.hasMinerals || show {
                sectionsAndRows.append(.minerals(TableSection.Size.Minerals))
                cellHeight[rowIndex] = Constants.CellHeight.TagListViewCell
                rowIndex += 1
            }
            if validProductPair.hasVitamins || show {
                sectionsAndRows.append(.vitamins(TableSection.Size.Vitamins))
                cellHeight[rowIndex] = Constants.CellHeight.TagListViewCell
                rowIndex += 1
            }
            if validProductPair.hasNucleotides || show {
                sectionsAndRows.append(.minerals(TableSection.Size.Nucleotides))
                cellHeight[rowIndex] = Constants.CellHeight.TagListViewCell
                rowIndex += 1
            }
            if validProductPair.hasOtherNutritionalSubstances || show {
                sectionsAndRows.append(.otherNutritionalSubstances(TableSection.Size.OtherNutritionalSubstances))
                cellHeight[rowIndex] = Constants.CellHeight.TagListViewCell
                rowIndex += 1
            }

        default :
            break
        }
        if validProductPair.hasAdditives {
            sectionsAndRows.append(.additives(TableSection.Size.Additives))
            cellHeight[rowIndex] = Constants.CellHeight.TagListViewCell
            rowIndex += 1
        }
        sectionsAndRows.append(.labels(TableSection.Size.Labels))
        cellHeight[rowIndex] = Constants.CellHeight.TagListViewCell
        sectionsAndRows.append(.image(TableSection.Size.Image))
        
        return sectionsAndRows
    }
    
    @objc func doubleTapOnTableView() {
        // double tapping implies cycling through the product possibilities
        switch productVersion {
        case .new:
            productVersion = .remoteTags
        case .remoteTags:
            productVersion = .remoteTagsTranslated
        case .remoteTagsTranslated:
            productVersion = .remoteTagsHierarchy
        case .remoteTagsHierarchy:
            productVersion = .remoteTagsHierarchyTranslated
        case .remoteTagsHierarchyTranslated:
            productVersion = .remoteUser
        case .remoteUser:
            productVersion = productPair?.localProduct != nil ? .new : .remoteTags
        }
        tableView.reloadData()
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
//
// MARK: - Notification handler
//
    @objc func imageUpdated(_ notification: Notification) {
        guard let currentProductBarcode = productPair?.remoteProduct?.barcode.asString else { return }
        guard let noticifationBarcode = notification.userInfo?[ProductImageData.Notification.BarcodeKey] as? String else { return }
        guard currentProductBarcode == noticifationBarcode else { return }

        // We can not check the imageType,
        // as the image might be retrieved from disk
        // is it relevant to the main image?
        //guard let id = notification.userInfo?[ProductImageData.Notification.ImageTypeCategoryKey] as? String else { return }
        //guard id.contains(OFFHttpPost.AddParameter.ImageField.Value.Front) else { return }

        self.uploadProgressRatio = nil
        // Filtering on image type, is not possible as unmarked images are read from cache
        reloadImageSection()
    }

    @objc func reloadImageSection() { // (_ notification: Notification) {
        tableView.reloadData()
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
        guard productPair != nil else { return }
        productVersion = .new
        tableStructure = setupSections()
        tableView.reloadData()
    }
    
    func changeLanguage() {
        // set the next language in the array
        if currentLanguageCode != nextLanguageCode() {
            currentLanguageCode = nextLanguageCode()
            // reload the first row
            let indexPaths = [IndexPath.init(row: 0, section: 0)]
            tableView.reloadRows(at: indexPaths, with: UITableView.RowAnimation.fade)
            tableView.deselectRow(at: indexPaths.first!, animated: true)
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
        if image != nil,
            let validLanguageCode = displayLanguageCode {
            productPair?.update(ingredientsImage: image!, for: validLanguageCode)
            tableView.reloadData()
        }
    }

    @objc func imageUploaded(_ notification: Notification) {
        guard !editMode else { return }
        // Check if this image is relevant to this product
        if let barcode = notification.userInfo?[ProductPair.Notification.BarcodeKey] as? String {
            if barcode == productPair!.barcodeType.asString {
                // is it relevant to the ingredients image?
                if let id = notification.userInfo?[ProductPair.Notification.ImageTypeCategoryKey] as? String {
                    if id.contains(OFFHttpPost.AddParameter.ImageField.Value.Ingredients) {
                        // reload product data
                        self.productPair?.reload()
                    }
                }
            }
        }
    }
    
    @objc func progress(_ notification: Notification) {
        guard !editMode else { return }
        // Check if this upload progress is relevant to this product
        guard let barcode = notification.userInfo?[OFFImageUploadAPI.Notification.BarcodeKey] as? String else { return }
        guard let productBarcode = productPair!.remoteProduct?.barcode.asString else { return }
        guard barcode == productBarcode else { return }
                    // is it relevant to the main image?
        guard let id = notification.userInfo?[OFFImageUploadAPI.Notification.ImageTypeCategoryKey] as? String else { return }
        guard id.contains(OFFHttpPost.AddParameter.ImageField.Value.Ingredients) else  { return }
        guard let progress = notification.userInfo?[OFFImageUploadAPI.Notification.ProgressKey] as? String else { return }
        guard let progressDouble = Double(progress) else { return }
        self.uploadProgressRatio = CGFloat(progressDouble)
        // reload the tabel to update the progress indicator
        self.tableView.reloadData()
    }

    @objc func imageDeleted(_ notification: Notification) {
        // Check if this image was relevant to this product
        if let barcode = notification.userInfo?[ProductPair.Notification.BarcodeKey] as? String {
            if barcode == productPair!.barcodeType.asString {
                // is it relevant to the ingredients image?
                if let id = notification.userInfo?[ProductPair.Notification.ImageTypeCategoryKey] as? String {
                    if id.contains(OFFHttpPost.AddParameter.ImageField.Value.Ingredients) {
                        // reload product data
                        self.productPair?.reload()
                    }
                }
            }
        }
        if let barcode = notification.userInfo?[OFFProducts.Notification.BarcodeKey] as? String {
            if barcode == productPair!.barcodeType.asString {
                // is it relevant to the ingredients image?
                if let id = notification.userInfo?[OFFProducts.Notification.ImageTypeCategoryKey] as? String {
                    if id.contains(OFFHttpPost.AddParameter.ImageField.Value.Ingredients) {
                        // reload product data
                        self.productPair?.reload()
                    }
                }
            }
        }

    }


    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        
        coordinator = IngredientsCoordinator.init(with: self)
        
        if #available(iOS 11.0, *) {
            tableView.dragDelegate = self
            tableView.dropDelegate = self
        }
        self.tableView.isUserInteractionEnabled = true
        // For custom tableView headers
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 70
        tableView.register(UINib(nibName: LanguageHeaderView.identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: LanguageHeaderView.identifier)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // delegate?.title = TranslatableStrings.Ingredients
        // print("ing viewWillAppear", self.view.frame, self.parent?.view.frame)

        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.refreshProduct), name:.ProductPairRemoteStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.refreshProduct), name:.ProductUpdateSucceeded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.refreshProduct), name:.ProductPairLocalStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.imageUpdated(_:)), name:.ImageSet, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.imageUploaded(_:)), name:.ProductPairImageUploadSuccess, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.imageDeleted(_:)), name:.ProductPairImageDeleteSuccess, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.imageDeleted(_:)), name:.OFFProductsImageDeleteSuccess, object:nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(IngredientsTableViewController.refreshProduct),
            name: .ProductPairLocalStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.progress(_:)), name:.ImageUploadProgress, object:nil)

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
// MARK: - TagListViewButtonCellDelegate Functions
//
extension IngredientsTableViewController: TagListViewButtonCellDelegate {
    func tagListViewButtonTableViewCell(_ sender: TagListViewButtonTableViewCell, receivedTapOn button: UIButton) {
        coordinator?.selectTraces(for: self.productPair, anchoredOn:button)
    }
}
//
// MARK: - IngredientsImageCellDelegate Functions
//
extension IngredientsTableViewController: ProductImageCellDelegate {
    func productImageTableViewCell(_ sender: ProductImageTableViewCell, receivedActionOnCamera button:UIButton) {
        takePhoto()
    }
    
    func productImageTableViewCell(_ sender: ProductImageTableViewCell, receivedActionOnCameraRoll button:UIButton) {
        selectCameraRollPhoto()
    }
    
    func productImageTableViewCell(_ sender: ProductImageTableViewCell, receivedActionOnDeselect button: UIButton) {
        guard let validLanguageCode = displayLanguageCode,
            let validProductPair = productPair else { return }
        OFFProducts.manager.deselectImage(for: validProductPair, in: validLanguageCode, of: .ingredients(validLanguageCode))
    }

}


// MARK: - TagListViewAddImageCellDelegate functions

extension IngredientsTableViewController: TagListViewAddImageCellDelegate {
    
    func tagListViewAddImageTableViewCell(_ sender: TagListViewAddImageTableViewCell, receivedActionOnCamera button:UIButton) {
        takePhoto()
    }
    
    func tagListViewAddImageTableViewCell(_ sender: TagListViewAddImageTableViewCell, receivedActionOnCameraRoll button:UIButton) {
        selectCameraRollPhoto()
    }
    
}

// MARK: - IngredientsFullCellDelegate Delegate Functions

extension IngredientsTableViewController: IngredientsFullCellDelegate {
    
    func ingredientsFullTableViewCell(_ sender: IngredientsFullTableViewCell, heightChangedTo height: CGFloat) {
        // only do the layouting if it is really necessary
        if abs(cellHeight[0] ?? 44.0 - height) > 2.0 {
            cellHeight[0] = height
            tableView.setNeedsLayout()
        }
    }
    

    func ingredientsFullTableViewCell(_ sender: IngredientsFullTableViewCell, receivedActionOn textView:UITextView) {
        textView.endEditing(true)
        changeLanguage()
    }

    func ingredientsFullTableViewCell(_ sender: IngredientsFullTableViewCell, receivedTapOn button:UIButton) {
        changeLanguage()
    }

}

// MARK: - TextView Delegate Functions

extension IngredientsTableViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return editMode
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == TranslatableStrings.PlaceholderIngredients {
            textView.text = ""
        }
        if #available(iOS 13.0, *) {
            textView.textColor = .label
        } else {
            textView.textColor = .darkGray
        }
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.isFirstResponder { textView.resignFirstResponder() }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        switch tableStructure[textView.tag] {
        case .ingredients:
            if let validText = textView.text {
                if validText.isEmpty {
                    textView.text = TranslatableStrings.PlaceholderIngredients
                    if #available(iOS 13.0, *) {
                        textView.textColor = .placeholderText
                    } else {
                        textView.textColor = .gray
                    }
                } else if
                    let validLanguageCode = displayLanguageCode {
                    productPair?.update(ingredients: validText, in: validLanguageCode)
                    if #available(iOS 13.0, *) {
                        textView.textColor = .secondaryLabel
                    } else {
                        textView.textColor = .black
                    }
                    tableView.reloadData()
                }
            }
        default:
            break
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        let newCellHeight = newSize.height + 16.0
        if abs(newCellHeight - (cellHeight[0] ?? 44.0)) > 2.0 {
            cellHeight[0] = newCellHeight
// https://stackoverflow.com/questions/9309929/i-do-not-want-animation-in-the-begin-updates-end-updates-block-for-uitableview
            tableView.beginUpdates()
            tableView.endUpdates()
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
    
    func tagListViewCanDeleteTags(_ tagListView: TagListView) -> Bool {
                switch tableStructure[tagListView.tag] {
        case .labels, .traces:
            return editMode
        default:
            return false
        }

    }
        
    func tagListViewCanAddTags(_ tagListView: TagListView) -> Bool {
        switch tableStructure[tagListView.tag] {
        case .labels:
            return editMode
        default:
            // .traces can only be added through the picklist
            return false
        }
    }
    
    public func tagListView(_ tagListView: TagListView, didAddTagWith title: String) {
        switch tableStructure[tagListView.tag] {
        case .traces:
            switch tracesToDisplay {
            case .undefined, .empty:
                productPair?.update(tracesTags: [title])
            case var .available(list):
                list.append(title)
                productPair?.update(tracesTags: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .labels:
            // use the original values and not the translated ones to update
            switch labelsToDisplay {
            case .undefined, .empty:
                productPair?.update(labelTags: [title])
            case var .available(list):
                list.append(title)
                productPair?.update(labelTags: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        default:
            return
        }
        tableView.reloadData()
    }
    
    public func tagListView(_ tagListView: TagListView, didDeleteTagAt index: Int) {
        switch tableStructure[tagListView.tag] {
        case .traces:
            switch tracesToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                productPair?.update(tracesTags: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .labels:
            // use the original values and not the translated ones to update
            switch labelsToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                productPair?.update(labelTags: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        default:
            return
        }
        tableView.reloadData()
    }
    
    public func tagListView(_ tagListView: TagListView, canTapTagAt index: Int) -> Bool {
        
        guard tagListView.tag >= 0 && tagListView.tag < tableStructure.count else {
            print ("IngredientsTableViewController: tag index out of bounds", tagListView.tag, tableStructure.count - 1)
            return false
        }
        
        switch tableStructure[tagListView.tag] {
        case .labels:
            guard !editMode else { return false }
            // Do I need to take into account any regular tags?
            if let count = labelsToDisplay.count {
                if index <= count - 1 {
                    return false
                } else {
                    return true
                }
            } else {
                return true
            }
        default:
            return false
        }

    }

    public func tagListView(_ tagListView: TagListView, didTapTagAt index: Int) {
        
        func askQuestion(for type: RobotoffQuestionType, at index:Int) {
            guard let question = productPair?.remoteProduct?.robotoffQuestions(for: type)[index] else { return }
            var image: ProductImageSize?
            if let validID = question.imageID {
                if let validImages = productPair?.remoteProduct?.images {
                    image = validImages[validID]
                }
            }
            coordinator?.showQuestion(for: productPair, question: question, image: image)
        }
        
        guard tagListView.tag >= 0 && tagListView.tag < tableStructure.count else {
            print ("IngredientsTableViewController: tag index out of bounds", tagListView.tag, tableStructure.count - 1)
            return
        }
        guard !editMode else { return }

        switch tableStructure[tagListView.tag] {
        case .labels:
            // Do I need to take into account any regular tags?
            if let count = labelsToDisplay.count {
                if index <= count - 1 {
                    return
                } else {
                    askQuestion(for: .label, at: index - count)
                }
            } else {
                askQuestion(for: .label, at: index)
            }
        default:
            break
        }
    }

    public func tagListView(_ tagListView: TagListView, didLongPressTagAt index: Int) {
        
        switch tableStructure[tagListView.tag] {
        case .allergens:
            switch productPair!.remoteProduct!.allergensInterpreted {
            case .available:
                delegate?.search(for: productPair!.remoteProduct!.allergensInterpreted.tag(at: index), in: .allergen)
            default:
                break
            }
        case .traces:
            // the taxonomy key is used to define the search value
            switch productPair!.remoteProduct!.tracesInterpreted {
            case .available:
                delegate?.search(for: productPair!.remoteProduct!.tracesInterpreted.tag(at: index), in: .trace)
            default:
                break
            }
        case .labels:
            switch productPair!.remoteProduct!.labelsInterpreted {
            case .available:
                delegate?.search(for: productPair!.remoteProduct!.labelsInterpreted.tag(at: index), in: .label)
            default:
                break
            }
        default:
            break
        }
    }
    
    /// Called if the user wants to delete all tags
    public func didDeleteAllTags(_ tagListView: TagListView) {
        switch tableStructure[tagListView.tag] {
        case .labels:
            switch labelsToDisplay {
            case .available:
                productPair?.update(labelTags: [])
            default:
                assert(true, "How can I delete a tag when there are none")
            }
        case .traces:
            switch tracesToDisplay {
            case .available(var list):
                list.removeAll()
                productPair?.update(tracesTags: list)
            default:
                assert(true, "How can I clear a tag when there are none")
            }
        default:
            return
        }
        tableView.reloadData()
    }

}

// MARK: - TagListView DataSource Functions

extension IngredientsTableViewController: TagListViewDataSource {
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        
        func count(_ tags: Tags) -> Int {
            switch tags {
            case .undefined:
                return editMode ? 0 : 1
            case .empty:
                return editMode ? 0 : 1
            case let .available(list):
                return list.count
            case .notSearchable:
                return 1
            }
        }

        func detectedCount(_ tags: Tags) -> Int {
            switch tags {
            case .undefined:
                return 1 // editMode ? 0 : 1
            case .empty:
                return 1 // editMode ? 0 : 1
            case let .available(list):
                return list.count
            case .notSearchable:
                return 1
            }
        }

        guard tagListView.tag >= 0 && tagListView.tag < tableStructure.count else {
            print ("IngredientsTableViewController: tag index out of bounds", tagListView.tag, tableStructure.count - 1)
            return  1
        }
        switch tableStructure[tagListView.tag] {
        case .additives:
            return detectedCount(additivesToDisplay)
        case .allergens:
            return detectedCount(allergensToDisplay)
        case .labels:
            // do not show the robotoff labels in editMode
            guard let questions = productPair?.remoteProduct?.robotoffQuestions(for: .label),
                let validTags = editMode
                    ? labelsToDisplay
                    : Tags.add(right: labelsToDisplay,
                                         left: Tags(list:questions.map({ $0.value ?? "No value" })))
            else {
                return count(.undefined)
            }
            return count(validTags)
        case .image:
            return 1
        case .traces:
            return count(tracesToDisplay)
        case .ingredients:
            return detectedCount(ingredientsToDisplay)
        case .minerals:
            return detectedCount(mineralsToDisplay)
        case .vitamins:
            return detectedCount(vitaminsToDisplay)
        case .nucleotides:
            return detectedCount(nucleotidesToDisplay)
        case .otherNutritionalSubstances:
            return detectedCount(otherNutritionalSubstancesToDisplay)
        case .aminoAcids:
            return detectedCount(aminoAcidsToDisplay)

        }
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        guard tagListView.tag >= 0 && tagListView.tag < tableStructure.count else { return  "IngredientsTableViewController: tag out of bounds" }
        switch tableStructure[tagListView.tag] {
        case .additives:
            return additivesToDisplay.tag(at:index)!
        case .allergens:
            return allergensToDisplay.tag(at:index)!
        case .image:
            return searchResult
        case .labels:
            guard let questions = productPair?.remoteProduct?.robotoffQuestions(for: .label),
                let validTags = editMode
                    ? labelsToDisplay
                    : Tags.add(right: labelsToDisplay,
                                         left: Tags(list:questions.map({ $0.value ?? "No value" }))) else { return "" }
            return validTags.tag(at:index)!
        case .traces:
            return tracesToDisplay.tag(at:index)!
        case .minerals:
            return mineralsToDisplay.tag(at:index)!
        case .vitamins:
            return vitaminsToDisplay.tag(at:index)!
        case .nucleotides:
            return nucleotidesToDisplay.tag(at:index)!
        case .otherNutritionalSubstances:
            return otherNutritionalSubstancesToDisplay.tag(at:index)!
        case .ingredients:
            return ingredientsToDisplay.tag(at:index)!
        case .aminoAcids:
            return aminoAcidsToDisplay.tag(at:index)!

        }
    }

    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        if let validHeight = cellHeight[tagListView.tag],
            abs(validHeight - height) > CGFloat(3.0) {
            cellHeight[tagListView.tag] = height
            tableView.setNeedsLayout()
        }
    }

    public func tagListView(_ tagListView: TagListView, colorSchemeForTagAt index: Int) -> ColorScheme? {
        
        func colorScheme(_ tags: Tags) -> ColorScheme {
            switch tags {
            case .undefined, .notSearchable:
                return ColorSchemes.error
            case .empty:
                return ColorSchemes.none
            case .available:
                return ColorSchemes.normal
            }
        }

        guard tagListView.tag >= 0 && tagListView.tag < tableStructure.count else {
            print ("IngredientsTableViewController: tag index out of bounds", tagListView.tag, tableStructure.count - 1)
            return  nil
        }
        switch tableStructure[tagListView.tag] {
        case .labels:
            // Do I need to take into account any regular tags?
            if let validLabelsCount = labelsToDisplay.count,
                index <= validLabelsCount - 1 {
                return ColorSchemes.normal
            } else {
                if !editMode,
                    let questions = productPair?.remoteProduct?.robotoffQuestions(for: .label), !questions.isEmpty {
                    return ColorSchemes.robotoff
                } else {
                    return ColorSchemes.none
                }
            }
        case .additives:
            return colorScheme(additivesToDisplay)
        case .allergens:
            return colorScheme(allergensToDisplay)
        case .image:
            return ColorSchemes.error
        case .traces:
            return colorScheme(tracesToDisplay)
        case .ingredients:
            return colorScheme(ingredientsToDisplay)
        case .minerals:
            return colorScheme(mineralsToDisplay)
        case .vitamins:
            return colorScheme(vitaminsToDisplay)
        case .nucleotides:
            return colorScheme(nucleotidesToDisplay)
        case .otherNutritionalSubstances:
            return colorScheme(otherNutritionalSubstancesToDisplay)
        case .aminoAcids:
            return colorScheme(aminoAcidsToDisplay)
        }
    }

}

// MARK: - UINavigationControllerDelegate Functions


extension IngredientsTableViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        newImageSelected(info: info)
        picker.dismiss(animated: true, completion: nil)
        // notify the delegate
    }
    
}


extension IngredientsTableViewController: GKImagePickerDelegate {
    
    func imagePicker(_ imagePicker: GKImagePicker, cropped image: UIImage) {
        guard let validLanguageCode = displayLanguageCode else { return }
        productPair?.update(ingredientsImage: image, for: validLanguageCode)
        tableView.reloadData()
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - LanguageHeaderDelegate Functions

extension IngredientsTableViewController: LanguageHeaderDelegate {
    
    func changeLanguageButtonTapped(_ sender: UIButton, in section: Int) {
        guard let primaryLanguageCode = self.productPair?.primaryLanguageCode else { return }
        guard let languageCodes = self.productPair?.languageCodes else { return }
        coordinator?.selectLanguage(primaryLanguageCode: primaryLanguageCode, currentLanguageCode: displayLanguageCode, productLanguageCodes: languageCodes, atAnchor: sender)
    }
    
    func changeViewModeButtonTapped(_ sender: UIButton, in section: Int) {
        // If this comes from the ingredients section, then the behaviour depends
        if section == 0
            && editMode {
            guard let validBarcodeType = productPair?.barcodeType else { return }
            guard let validLanguageCode = currentLanguageCode else { return }
            // start OCR
            ocrRequest = OFFOCRRequestAPI(barcode: validBarcodeType, productType: currentProductType, languageCode: validLanguageCode)
            ocrRequest?.performOCR()
        } else {
            doubleTapOnTableView()
        }
    }
}

// MARK: - UIDragInteractionDelegate Functions

@available(iOS 11.0, *)
extension IngredientsTableViewController: UITableViewDragDelegate {
    
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
        if let images = productPair?.localProduct?.ingredientsImages,
            !images.isEmpty {
            productImageData = productPair!.localProduct!.image(imageType: .ingredients(validLanguageCode))?.largest
        } else {
            productImageData = productPair!.remoteProduct!.image(imageType:.ingredients(validLanguageCode))?.largest
        }
        // The largest image here is the display image, as the url for the original front image is not offered by OFF in an easy way
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
extension IngredientsTableViewController: UITableViewDropDelegate {
    
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
        }
        
        // guard currentLanguageCode != nil else { return }
        coordinator.session.loadObjects(ofClass: UIImage.self) { (images) in
            // Only one image is accepted as ingredients image for the current language
            if let validImage = (images as? [UIImage])?.first {
                setImage(image: validImage)
                //self.delegate?.updated(frontImage: validImage, languageCode:self.currentLanguageCode!)
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

extension IngredientsTableViewController: GKImageCropControllerDelegate {
    
    public func imageCropController(_ imageCropController: GKImageCropViewController, didFinishWith croppedImage: UIImage?) {
        guard let validLanguageCode = displayLanguageCode,
            let validImage = croppedImage else { return }
        imageCropController.dismiss(animated: true, completion: nil)
        productPair?.update(ingredientsImage: validImage, for:validLanguageCode)
        self.reloadImageSection()
    }
}
