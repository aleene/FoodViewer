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
                if let checked = availableTags(productPair?.localProduct?.tracesOriginal) {
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
            return availableTags(productPair?.remoteProduct?.labelsTranslated) ?? .undefined
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

    var delegate: ProductPageViewController? = nil {
        didSet {
            if delegate != oldValue {
                refreshProduct()
            }
        }
    }
    
    // MARK: - Actions and Outlets
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        if refreshControl!.isRefreshing {
            OFFProducts.manager.reload(productPair: productPair)
            refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Table view data source
    

    fileprivate struct Storyboard {
        struct CellIdentifier {
            static let Ingredients = "Ingredients Full Cell"
            static let TagListView = "TagListView Cell"
            static let TagListViewWithSegmentedControl = "TagListView With SegmentedControl Cell"
            static let Image = "Ingredients Image Cell"
            //static let NoImage = "No Image Cell"
            static let TagListViewAddImage = "Ingredients TagListView Add Image Cell"
        }
        
        struct SegueIdentifier {
            static let ShowIdentification = "Show Ingredients Image"
            static let SelectLanguage = "Show Ingredients Languages"
        }
        
        struct Nib {
            static let LanguageHeaderView = "LanguageHeaderView"
        }
        
        struct ReusableHeaderFooterView {
            static let Language = "LanguageHeaderView"
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
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
                cell.width = tableView.frame.size.width
                cell.datasource = self
                cell.delegate = self
                cell.editMode = false
                cell.tag = indexPath.section
                return cell
            default:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Ingredients, for: indexPath) as! IngredientsFullTableViewCell
            cell.delegate = self
            cell.textViewTag = indexPath.section
            cell.editMode = editMode // currentLanguageCode == product!.primaryLanguageCode ? editMode : false
            if let validLanguageCode = displayLanguageCode,
                productPair?.localProduct?.ingredientsLanguage[validLanguageCode] != nil {
                cell.editMode = productVersion.isRemote ? false : true
            }

            cell.textView.textColor = .gray
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

            // print("cell frame", cell.frame)
            return cell
            }

        case .allergens, .additives, .minerals, .vitamins, .nucleotides, .otherNutritionalSubstances, .aminoAcids:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.editMode = false
            cell.tag = indexPath.section
            return cell

        case .traces:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.editMode = editMode
            if editMode,
                let oldTags = productPair?.localProduct?.tracesOriginal {
                switch oldTags {
                case .available:
                    cell.editMode = productVersion.isRemote ? false : true
                default:
                    break
                }
            }
            cell.tag = indexPath.section
            return cell

        case .labels:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.editMode = editMode
            if let oldTags = productPair?.localProduct?.labelsOriginal {
                switch oldTags {
                case .available:
                    cell.editMode = productVersion.isRemote ? false : true
                default:
                    break
                }
            }
            cell.tag = indexPath.section
            return cell
        
        case .image:
            if imageToShow != nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as! ProductImageTableViewCell
                cell.editMode = editMode
                if localImageToShow != nil {
                    cell.editMode = productVersion.isRemote ? false : true
                }
                cell.productImage = imageToShow
                cell.delegate = self
                return cell
            } else {
                searchResult = TranslatableStrings.NoImageAvailable
                // Show a tag with the option to set an image
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewAddImage, for: indexPath) as! TagListViewAddImageTableViewCell
                cell.width = tableView.frame.size.width
                cell.scheme = ColorSchemes.error
                cell.editMode = editMode
                cell.datasource = self
                cell.delegate = self
                cell.tag = indexPath.section
                cell.accessoryType = .none
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
        if let images = productPair?.remoteProduct?.ingredientsImages,
            !images.isEmpty,
            let validLanguageCode = displayLanguageCode,
            let result = images[validLanguageCode]?.display?.fetch() {
            switch result {
            case .success(let image):
                return image
            default:
                searchResult = result.description
                break
            }
            // fall back to the primary languagecode ingredient image
            // if we are NOT in edit mode
        } else if !editMode,
            let images = productPair?.remoteProduct?.ingredientsImages,
            let primaryLanguageCode = productPair!.remoteProduct!.primaryLanguageCode,
            let result = images[primaryLanguageCode]?.display?.fetch() {
            switch result {
            case .success(let image):
                return image
            default:
                break
            }
        }
        // No relevant image is available
        return nil
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

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSection = indexPath.section
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let currentProductSection = tableStructure[section]

        var buttonNotDoubleTap: Bool {
            return ViewToggleModeDefaults.manager.buttonNotDoubleTap ?? ViewToggleModeDefaults.manager.buttonNotDoubleTapDefault
        }

        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Storyboard.ReusableHeaderFooterView.Language) as! LanguageHeaderView
        
        headerView.section = section
        headerView.delegate = self
        headerView.changeViewModeButton.isHidden = true
        headerView.buttonNotDoubleTap = buttonNotDoubleTap
        var header = ""

        switch currentProductSection {
        case .image, .ingredients : // Header with a language
            headerView.changeLanguageButton.isHidden = true
            switch currentProductSection {
            case .image:
                headerView.changeLanguageButton.isHidden = false
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
                headerView.title = header + " - "

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
            headerView.title = headerView.changeLanguageButton.isHidden ? header : header + " - "
            headerView.buttonText = OFFplists.manager.languageName(for: displayLanguageCode)
            headerView.buttonIsEnabled = editMode ? true : ( (productPair?.product?.languageCodes.count ?? 0) > 1 ? true : false )
            return headerView
        
        case .labels, .traces, .additives, .allergens, .aminoAcids, .minerals, .vitamins, .nucleotides, .otherNutritionalSubstances:
            headerView.changeLanguageButton.isHidden = true
            
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

        sectionsAndRows.append(.ingredients(TableSection.Size.Ingredients))
        // not needed for .product, .petFood and .beauty
        switch currentProductType {
        case .food:
            // 1:  allergens section
            if validProductPair.hasAllergens || show {
                sectionsAndRows.append(.allergens(TableSection.Size.Allergens))
            }
            
            // 2: traces section
            sectionsAndRows.append(.traces(TableSection.Size.Traces))
            
            if validProductPair.hasMinerals || show {
                sectionsAndRows.append(.minerals(TableSection.Size.Minerals))
            }
            if validProductPair.hasVitamins || show {
                sectionsAndRows.append(.vitamins(TableSection.Size.Vitamins))
            }
            if validProductPair.hasNucleotides || show {
                sectionsAndRows.append(.minerals(TableSection.Size.Nucleotides))
            }
            if validProductPair.hasOtherNutritionalSubstances || show {
                sectionsAndRows.append(.otherNutritionalSubstances(TableSection.Size.OtherNutritionalSubstances))
            }

        default :
            break
        }
        if productPair!.hasAdditives {
            sectionsAndRows.append(.additives(TableSection.Size.Additives))
        }
        sectionsAndRows.append(.labels(TableSection.Size.Labels))
        sectionsAndRows.append(.image(TableSection.Size.Image))
        
        return sectionsAndRows
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.SegueIdentifier.ShowIdentification:
                if let vc = segue.destination as? ImageViewController,
                    let validLanguageCode = displayLanguageCode {
                    vc.imageTitle = TextConstants.ShowIdentificationTitle
                    if let images = productPair?.localProduct?.ingredientsImages,
                        !images.isEmpty {
                        vc.imageData = productPair!.localProduct!.image(for:validLanguageCode, of:.ingredients)
                    } else {
                        vc.imageData = productPair!.remoteProduct!.image(for:validLanguageCode, of:.ingredients)
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
                            //if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of the popOver
                                //ppc.permittedArrowDirections = .right
                                // I need the button coordinates in the coordinates of the current controller view
                                //let anchorFrame = button.convert(button.bounds, to: self.view)
                                //ppc.sourceRect = anchorFrame // leftMiddle(anchorFrame)
                                //ppc.delegate = self
                            vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                                
                                vc.currentLanguageCode = displayLanguageCode
                                vc.languageCodes = productPair!.remoteProduct!.languageCodes
                                vc.updatedLanguageCodes = productPair?.localProduct?.languageCodes ?? []
                                vc.primaryLanguageCode = productPair!.remoteProduct?.primaryLanguageCode
                                vc.sourcePage = 1
                                vc.editMode = editMode
                            //}
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
        let userInfo = (notification as NSNotification).userInfo
        guard userInfo != nil && imageSectionIndex != nil else { return }
        // only update if the image barcode corresponds to the current product
        if productPair!.remoteProduct!.barcode.asString == userInfo![ProductImageData.Notification.BarcodeKey] as! String {
            if userInfo!.count == 1 {
                reloadImageSection()
                return
            }
            if let validValue = userInfo?[ProductImageData.Notification.ImageTypeCategoryKey] as? Int {
                if let category = ImageTypeCategory(rawValue: validValue),
                    category == .ingredients {
                    // We are only interested in medium-sized front images
                    //if let validValue = userInfo?[ProductImageData.Notification.ImageSizeCategoryKey] as? Int {
                    //    imageSizeCategory = ImageSizeCategory(rawValue: validValue)
                    reloadImageSection()
                }
            }
        }
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
    }


    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        
        if #available(iOS 11.0, *) {
            tableView.dragDelegate = self
            tableView.dropDelegate = self
        }
        self.tableView.isUserInteractionEnabled = true
        // For custom tableView headers
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 70
        tableView.register(UINib(nibName: "LanguageHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "LanguageHeaderView")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // delegate?.title = TranslatableStrings.Ingredients
        // print("ing viewWillAppear", self.view.frame, self.parent?.view.frame)

        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.refreshProduct), name:.ProductPairRemoteStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.refreshProduct), name:.ProductUpdateSucceeded, object:nil)

        //NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.removeProduct), name:.HistoryHasBeenDeleted, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.imageUpdated(_:)), name:.ImageSet, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.imageUploaded(_:)), name:.ProductPairImageUploadSuccess, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.imageDeleted(_:)), name:.ProductPairImageDeleteSuccess, object:nil)
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

// MARK: - TagListViewCellDelegate Functions

extension IngredientsTableViewController: TagListViewCellDelegate {
    
    // function to let the delegate know that the switch changed
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedSingleTapOn tagListView:TagListView) {
    }
    
    // function to let the delegate know that the switch changed
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedDoubleTapOn tagListView:TagListView) {
    }
}

// MARK: - IngredientsImageCellDelegate Delegate Functions

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
        OFFProducts.manager.deselectImage(for: validProductPair, in: validLanguageCode, of: .ingredients)
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

    func ingredientsFullTableViewCell(_ sender: IngredientsFullTableViewCell, receivedActionOn textView:UITextView) {
        textView.endEditing(true)
        changeLanguage()
    }

    func ingredientsFullTableViewCell(_ sender: IngredientsFullTableViewCell, receivedTapOn button:UIButton) {
        changeLanguage()
    }

}

// MARK: - TagListViewSegmentedControlCellDelegate Delegate Functions

extension IngredientsTableViewController: TagListViewSegmentedControlCellDelegate {
    
    func tagListViewSegmentedControlTableViewCell(_ sender: TagListViewSegmentedControlTableViewCell, receivedActionOn segmentedControl: UISegmentedControl) {
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
            textView.textColor = .black
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
                if (textView.text == "") {
                    textView.text = TranslatableStrings.PlaceholderIngredients
                    textView.textColor = .lightGray
                } else if
                    let validLanguageCode = displayLanguageCode {
                    productPair?.update(ingredients: validText, in: validLanguageCode)
                    tableView.reloadData()
                }
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
    
    func tagListView(_ tagListView: TagListView, moveTagAt sourceIndex: Int, to destinationIndex: Int) {
    }
    
    
    func tagListView(_ tagListView: TagListView, canEditTagAt index: Int) -> Bool {
        return false
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
    public func didClear(_ tagListView: TagListView) {
        switch tableStructure[tagListView.tag] {
        case .labels:
            switch labelsToDisplay {
            case .available(var list):
                list.removeAll()
                productPair?.update(labelTags: list)
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

        func detectedCount(_ tags: Tags) -> Int {
            switch tags {
            case .undefined:
                tagListView.normalColorScheme = ColorSchemes.error
                return 1 // editMode ? 0 : 1
            case .empty:
                tagListView.normalColorScheme = ColorSchemes.none
                return 1 // editMode ? 0 : 1
            case let .available(list):
                tagListView.normalColorScheme = ColorSchemes.normal
                return list.count
            case .notSearchable:
                tagListView.normalColorScheme = ColorSchemes.error
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
            return count(labelsToDisplay)
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
            return labelsToDisplay.tag(at:index)!
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
    
    func tagListView(_ tagListView: TagListView, colorSchemeForTagAt index: Int) -> ColorScheme? {
        return nil
    }

    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        tableView.reloadData()
    }
    
    func tagListViewCollapsedText(_ tagListView: TagListView) -> String {
        return "Collapsed text"
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
        performSegue(withIdentifier: Storyboard.SegueIdentifier.SelectLanguage, sender: sender)
    }
    
    func changeViewModeButtonTapped(_ sender: UIButton, in section: Int) {
        doubleTapOnTableView()
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
            productImageData = productPair!.localProduct!.image(for:validLanguageCode, of:.ingredients)
        } else {
            productImageData = productPair!.remoteProduct!.image(for:validLanguageCode, of:.ingredients)
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
