//
//  ProductPair.swift
//  FoodViewer
//
//  Created by arnaud on 17/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

class ProductPair {
    
    internal struct Notification {
        //static let BarcodeDoesNotExistKey = "ProductPair.Notification.BarcodeDoesNotExist.Key"
        //static let SearchStringKey = "OFFProducts.Notification.SearchString.Key"
        //static let SearchOffsetKey = "OFFProducts.Notification.SearchOffset.Key"
        //static let SearchPageKey = "OFFProducts.Notification.SearchPage.Key"
        static let BarcodeKey = "ProductPair.Notification.Barcode.Key"
        static let ErrorKey = "ProductPair.Notification.Error.Key"
        static let RemoteStatusKey = "ProductPair.Notification.RemoteStatus.Key"
        static let ProductPairUpdatedKey = "ProductPair.Notification.Updated.Key"
        static let ImageTypeCategoryKey = "ProductPair.Notification.ImageTypeCategory.Key"
        static let ImageIDKey = "ProductPair.Notification.ImageID.Key"
    }

    /// The barcode identifies a product and thus a productPair
    /// it can not be nil !!!!
    public var barcodeType: BarcodeType = .undefined("not set", nil)
    
    // If false, then the use can not update this product
    // This is useful for the sample products and the mostRecent product
    public var updateIsAllowed = true
    
    /// A comment that can be added by the user. It will not be uploaded to OFF. It will be stored locally in the history. It is unaffected by any update from OFF, or local edits and removals.
    public var comment: String?

    // This defines the type of this product, such as .food, .beauty or .petFood
    //var productType: ProductType = .food
    
    // The product as it is stored on the OFF-servers
    // If the product is not downloaded or does not exist, it is nil
    var remoteProduct: FoodProduct? = nil {
        didSet {
            if ( remoteProduct != nil && oldValue == nil ) || ( remoteProduct == nil && oldValue != nil ) {
                let userInfo = [Notification.BarcodeKey: barcodeType.asString] as [String : Any]

                DispatchQueue.main.async(execute: { () -> Void in
                    NotificationCenter.default.post(name: .ProductPairUpdated, object:nil, userInfo: userInfo)
                })
            }
            if remoteProduct != nil {
                remoteStatus = .available(barcodeType.asString)
            }
        }
    }
    
    // The remote status described the relation with the OFF server
    var localStatus: ProductFetchStatus = .initialized {
        didSet {
            // only do something if there is a change
            if localStatus.rawValue != oldValue.rawValue {
                let userInfo = [Notification.BarcodeKey: barcodeType.asString,
                                Notification.RemoteStatusKey: localStatus.rawValue] as [String : Any]
                DispatchQueue.main.async(execute: { () -> Void in
                    NotificationCenter.default.post(name: .ProductPairLocalStatusChanged, object:nil, userInfo: userInfo)
                })
            }
        }
    }
    
    /// Indicates if product data is available
    var status: ProductFetchStatus {
        switch localStatus {
        case .available, .updated:
            return localStatus
        default:
            return remoteStatus
        }
    }
    
    /// Return the product which has info
    var product: FoodProduct? {
        return localProduct ?? remoteProduct
    }
    
    // The product as it is created or changed by the user
    // If the user did not do anything, it is nil
    var localProduct: FoodProduct? = nil {
        didSet {
            if ( localProduct != nil && oldValue == nil ) || ( localProduct == nil && oldValue != nil ) {
                let userInfo = [Notification.BarcodeKey: barcodeType.asString] as [String : Any]
                DispatchQueue.main.async(execute: { () -> Void in
                    NotificationCenter.default.post(name: .ProductPairUpdated, object:nil, userInfo: userInfo)
                })
            }

            if localProduct != nil {
                localStatus = .available(barcodeType.asString)
                if localProduct?.primaryLanguageCode == nil {
                    localProduct?.primaryLanguageCode = remoteProduct?.primaryLanguageCode ?? Locale.interfaceLanguageCode
                }
            } else {
                localStatus = .initialized
                // any locally stored data can be removed as well.
                ProductStorage.manager.delete(self.barcodeType)
            }
        }
    }
    
    // The remote status described the relation with the OFF server
    var remoteStatus: ProductFetchStatus = .initialized {
        didSet {
            // only do something if there is a change
            if remoteStatus.rawValue != oldValue.rawValue {
                let userInfo = [Notification.BarcodeKey: barcodeType.asString,
                                Notification.RemoteStatusKey: remoteStatus.rawValue] as [String : Any]
                DispatchQueue.main.async(execute: { () -> Void in
                    NotificationCenter.default.post(name: .ProductPairRemoteStatusChanged, object:nil, userInfo: userInfo)
                })
            }
        }
    }
//
// MARK: - Initialization functions
//
    init(remoteStatus: ProductFetchStatus, type: ProductType) {
        self.barcodeType = BarcodeType(barcodeString: remoteStatus.description, type:Preferences.manager.showProductType)
        self.remoteStatus = remoteStatus
    }
    
    //  This sets a remote product directly
    init(product: FoodProduct) {
        self.barcodeType = product.barcode
        self.remoteProduct = product
        // ensure there is a languageCode
        if self.remoteProduct?.primaryLanguageCode == nil {
            self.remoteProduct?.primaryLanguageCode = self.localProduct?.primaryLanguageCode ?? Locale.interfaceLanguageCode
        }
        // as the product is set, the status is available
        self.remoteStatus = .available(product.barcode.asString)
    }
    
    convenience init(barcodeString: String, type: ProductType) {
        self.init(barcodeType: BarcodeType(barcodeString: barcodeString, type: type), comment: nil)
    }

    convenience init(barcodeString: String, comment: String?, type: ProductType) {
        self.init(barcodeType: BarcodeType(barcodeString: barcodeString, type: type), comment: comment)
    }

    init(barcodeType: BarcodeType, comment: String?) {
        self.barcodeType = barcodeType
        self.remoteStatus = .initialized
        self.comment = comment
    }

//
// MARK: Unique variables
//
    /// The name of the local product otherwise the remote product
    var name: String? {
        return remoteProduct?.name ?? localProduct?.name
    }
    
    /// The interpreted categories of the local product otherwise the remote product
    var categoriesInterpreted: Tags? {
        return localProduct?.categoriesInterpreted ?? remoteProduct?.categoriesInterpreted
    }
    
    var categoriesTranslated: Tags? {
        return localProduct?.categoriesTranslated ?? remoteProduct?.categoriesTranslated
    }
    
    /// The interpreted countries of the local product otherwise the remote product
    var countriesInterpreted: Tags? {
        return localProduct?.countriesInterpreted ?? remoteProduct?.countriesInterpreted
    }
    
    /// The interpreted traces of the local product otherwise the remote product
    var tracesInterpreted: Tags? {
        return localProduct?.tracesInterpreted ?? remoteProduct?.tracesInterpreted
    }

    var brand: String? {
        return localProduct?.brandsOriginal.tag(at: 0) ?? remoteProduct?.brandsOriginal.tag(at: 0)
    }
    
    var primaryLanguageCode: String {
        return localProduct?.primaryLanguageCode ?? remoteProduct?.primaryLanguageCode ??  Locale.interfaceLanguageCode
    }
    
    var regionURL: URL? {
        return remoteProduct?.regionURL ?? localProduct?.regionURL
    }
    
    var frontImages:[String:ProductImageSize] {
        return remoteProduct?.frontImages ?? localProduct?.frontImages ?? [:]
    }
    // tags in the local product should contain edited and nwe tags
    var folksonomyTags: [FSNM.Tag]? {
        return remoteProduct?.folksonomyTags
    }
    
    /// The languages found on the product expressed as two character languageCodes ("en").
    var languageCodes: [String]? {
        return localProduct?.languageCodes ?? remoteProduct?.languageCodes
    }
    
    /// Has the product  nutrition facts defined?
    var hasNutritionFacts: Bool? {
        // The local product overrides the remote product
        return localProduct?.hasNutritionFacts ?? remoteProduct?.hasNutritionFacts
    }
    
    /// initialize the local product for editing
    func initLocalProduct() {
        if localProduct == nil {
            if let barcodeType = remoteProduct?.barcode {
                let test = FoodProduct(with: barcodeType)
                localProduct = test
            } else {
                localProduct = FoodProduct(with: barcodeType)
            }
        }

    }
    
    var hasAdditives: Bool {
        if let hasTags = localProduct?.additivesOriginal.hasTags,
            hasTags {
            return true
        }
        if let hasTags = remoteProduct?.additivesInterpreted.hasTags,
            hasTags {
            return true
        }
        return false
    }

    var hasAllergens: Bool {
        if let hasTags = remoteProduct?.allergensInterpreted.hasTags,
            hasTags {
            return true
        }
        return false
    }

    var hasMinerals: Bool {
        if let hasTags = localProduct?.minerals.hasTags,
            hasTags {
            return true
        }
        if let hasTags = remoteProduct?.minerals.hasTags,
            hasTags {
            return true
        }
        return false
    }

    var hasNucleotides: Bool {
        if let hasTags = localProduct?.nucleotides.hasTags,
            hasTags {
            return true
        }
        if let hasTags = remoteProduct?.nucleotides.hasTags,
            hasTags {
            return true
        }
        return false
    }

    var hasOtherNutritionalSubstances: Bool {
        if let hasTags = localProduct?.otherNutritionalSubstances.hasTags,
            hasTags {
            return true
        }
        if let hasTags = remoteProduct?.otherNutritionalSubstances.hasTags,
            hasTags {
            return true
        }
        return false
    }

    var hasTraces: Bool {
        if let hasTags = localProduct?.tracesOriginal.hasTags,
            hasTags {
            return true
        }
        if let hasTags = remoteProduct?.tracesOriginal.hasTags,
            hasTags {
            return true
        }
        return false
    }

    var hasVitamins: Bool {
        if let hasTags = localProduct?.vitamins.hasTags,
            hasTags {
            return true
        }
        if let hasTags = remoteProduct?.vitamins.hasTags,
            hasTags {
            return true
        }
        return false
    }
    
    func preFetch() {
        switch remoteStatus {
        case .available, .productNotAvailable, .loadingFailed, .loading:
            break
        default:
            newFetch()
        }
        // Check and load a locally stored product
        ProductStorage.manager.load(barcodeType) { (completionHandler: FoodProduct?) in
            let product = completionHandler
            if product != nil {
                self.localProduct = product
            }
        }
    }
    
    func newFetch() {
        fetch(shouldBeReloaded: false)
    }
    
    func reload() {
        fetch(shouldBeReloaded: true)
    }
        
    private func fetch(shouldBeReloaded: Bool) {
        switch barcodeType {
        case .search:
            // TODO should I add the search fetch here?
            // if this is a search nothing can be fetched
            break
        default:
        // only start fetch if we are not already busy loading
            switch remoteStatus {
            case .loading:
                break
            default:
                let request = OpenFoodFactsRequest()
                remoteStatus = .loading(barcodeType.asString)
                request.fetchProduct(for:self.barcodeType, shouldBeReloaded:shouldBeReloaded) { (completion: ProductFetchStatus) in
                    let fetchResult = completion
                    switch fetchResult {
                    case .success(let product):
                        if product.barcode.asString == self.barcodeType.asString {
                            // if this was the stored most recent product, the local version can be deleted
                            switch self.barcodeType {
                            case .mostRecent:
                                self.barcodeType = product.barcode
                                self.localProduct = nil
                                 self.updateIsAllowed = true
                            default:
                                break
                            }
                            self.remoteProduct = product
                            // Check if all elements of the local product have been updated
                            switch self.localStatus {
                            case .updated:
                                // Then the local product can be removed
                                self.localProduct = nil
                            default: break
                            }
                        }
                    
                    case .loadingFailed(let barcodeString):
                         self.remoteStatus = .loadingFailed(barcodeString)
                        // I could try to check the local off database here
                        OFFDatabase.manager.product(for: barcodeString) { (product: FoodProduct?) in
                            if let validProduct = product {
                                self.remoteProduct = validProduct
                            }
                        }
                        self.initLocalProduct()
                        //self.localProduct?.nameLanguage[self.localProduct?.primaryLanguageCode ?? Locale.interfaceLanguageCode] = "New local product"
                    case .productNotAvailable(let barcodeString):
                        self.remoteStatus = .productNotAvailable(barcodeString)
                        // If we create a local product here we do not longer now that it is an unavailable product
                        self.initLocalProduct()
                        //self.localProduct?.nameLanguage[self.localProduct?.primaryLanguageCode ?? Locale.interfaceLanguageCode] = "New product"
                        // create an empty product with the required barcode on off
                        //self.upload()
                    
                    default: break
                    }
                }
            }
        }
    }
    
    func removeLocalProduct() {
        // if the localProduct no longer has any images, it can be nillified
        if self.localProduct != nil,
            self.localProduct!.hasImages == false,
            self.localProduct!.isEmpty {
            self.localProduct = nil
        }
    }
    
    func flushImages() {
        remoteProduct?.nutritionImages.forEach({ $0.value.flush() })
        remoteProduct?.frontImages.forEach({ $0.value.flush() })
        remoteProduct?.ingredientsImages.forEach({ $0.value.flush() })
        remoteProduct?.images.forEach({ $0.value.flush() })
        
        // TODO: I hope that they are stored before hand
        localProduct?.nutritionImages.forEach({ $0.value.flush() })
        localProduct?.frontImages.forEach({ $0.value.flush() })
        localProduct?.ingredientsImages.forEach({ $0.value.flush() })
        localProduct?.images.forEach({ $0.value.flush() })
    }
    
//
// MARK: - Update functions for the local product
//
    // The updated product contains only those fields that have been edited.
    // Thus one can always revert to the original product
    // And we know exactly what has changed
    // The user can undo an edit in progress by stepping back, i.e. selecting another product
    // First it is checked whether a change to the field has been made
    
    /// Tell any listener (viewControllers) that the local data has changed.
    private func sendLocalStatusChangeNotification() {
        let userInfo = [Notification.BarcodeKey: self.barcodeType.asString as String]
        NotificationCenter.default.post(name: .ProductPairLocalStatusChanged, object:nil, userInfo: userInfo)
    }
    
    func update(name: String, in languageCode: String) {
        if let validRemoteProduct = remoteProduct {
            if !validRemoteProduct.contains(name: name, for: languageCode) {
                initLocalProduct()
                localProduct?.set(newName: name, for: languageCode)
            }
        } else {
            initLocalProduct()
            localProduct?.set(newName: name, for: languageCode)
        }
    }
    
    func update(genericName: String, in languageCode: String) {
        if let validRemoteProduct = remoteProduct {
            if !validRemoteProduct.contains(genericName: genericName, for: languageCode) {
                initLocalProduct()
                localProduct?.set(newGenericName: genericName, for: languageCode)
            }
        } else {
            initLocalProduct()
            localProduct?.set(newGenericName: genericName, for: languageCode)
        }
    }
    
    func update(ingredients: String, in languageCode: String) {
        if let validRemoteProduct = remoteProduct {
            if !validRemoteProduct.contains(ingredients: ingredients, in:languageCode) {
                initLocalProduct()
                localProduct?.set(newIngredients: ingredients, for: languageCode)
            }
        } else {
            initLocalProduct()
            localProduct?.set(newIngredients: ingredients, for: languageCode)
        }
    }
    
    func update(portion: String) {
        if let validRemoteProduct = remoteProduct {
            if !validRemoteProduct.contains(servingSize: portion) {
                initLocalProduct()
                localProduct?.servingSize = portion
            }
        } else {
            initLocalProduct()
            localProduct?.servingSize = portion
        }
    }
    
    func update(barcode: String) {
        if let validRemoteProduct = remoteProduct {
            if !validRemoteProduct.contains(barcode: barcode) {
                initLocalProduct()
                localProduct?.barcode.string(barcode)
            }
        } else {
            initLocalProduct()
            localProduct?.barcode.string(barcode)
        }
    }
    
    func update(expirationDate: Date?) {
        guard let validDate = expirationDate else { return }
        if let validRemoteProduct = remoteProduct {
            if !validRemoteProduct.contains(expirationDate: validDate) {
                initLocalProduct()
                localProduct?.expirationDate = validDate
            }
        } else {
            initLocalProduct()
            localProduct?.expirationDate = validDate
        }
        sendLocalStatusChangeNotification()
    }
    
    func update(expirationDateString: String) {
        if let validRemoteProduct = remoteProduct {
            if !validRemoteProduct.contains(expirationDateString: expirationDateString) {
                initLocalProduct()
                localProduct?.expirationDateString = expirationDateString
            }
        } else {
            initLocalProduct()
            localProduct?.expirationDateString = expirationDateString
        }
    }
    
    func update(primaryLanguageCode: String) {
        if let validRemoteProduct = remoteProduct {
            if !validRemoteProduct.contains(primaryLanguageCode: primaryLanguageCode) {
                initLocalProduct()
                // what happens if the primary language is already an existing language?
                if !validRemoteProduct.contains(languageCode: primaryLanguageCode) {
                    // add a NEW language
                    localProduct?.add(languageCode: primaryLanguageCode)
                } else {
                    // use the existing language
                    // copy existing fields so that they can be edited
                    if let validName = validRemoteProduct.nameLanguage[primaryLanguageCode] {
                        if let name = validName {
                            update(name: name, in: primaryLanguageCode)
                        }
                    }
                    if let name = validRemoteProduct.genericNameLanguage[primaryLanguageCode] {
                        if let validGenericName = name  {
                            update(genericName: validGenericName, in: primaryLanguageCode)
                        }
                    }
                    if let validIngredients = validRemoteProduct.ingredientsLanguage[primaryLanguageCode],
                        let ingredients = validIngredients {
                        update(ingredients: ingredients, in: primaryLanguageCode)
                    }
                }
                // now it is possible to change the primary languageCode
                localProduct?.primaryLanguageCode = primaryLanguageCode
            }

        } else {
            initLocalProduct()
            // Add the new primary language to the possible languages
            localProduct?.add(languageCode: primaryLanguageCode)
            // If the old primary language code was not used yet, I guess I can throw away the language itself fields
            if let validOldPrimaryLanguageCode = localProduct?.primaryLanguageCode,
                localProduct?.nameLanguage[validOldPrimaryLanguageCode] == nil,
                localProduct?.ingredientsLanguage[validOldPrimaryLanguageCode] == nil,
                localProduct?.genericNameLanguage[validOldPrimaryLanguageCode] == nil,
                localProduct?.images[validOldPrimaryLanguageCode] ==  nil,
                localProduct?.frontImages[validOldPrimaryLanguageCode] ==  nil,
                localProduct?.ingredientsImages[validOldPrimaryLanguageCode] ==  nil,
                localProduct?.nutritionImages[validOldPrimaryLanguageCode] ==  nil {
                if let index = localProduct?.languageCodes.firstIndex(of: validOldPrimaryLanguageCode) {
                    localProduct?.languageCodes.remove(at: index) }
            }
            // now it is possible to change the primary languageCode
            localProduct?.primaryLanguageCode = primaryLanguageCode
        }
        sendLocalStatusChangeNotification()
    }
    
    func update(addLanguageCode languageCode: String) {
        if let validRemoteProduct = remoteProduct {
            if !validRemoteProduct.contains(languageCode: languageCode) {
                initLocalProduct()
                localProduct?.add(languageCode: languageCode)
            }
        } else {
            initLocalProduct()
            localProduct?.add(languageCode: languageCode)
        }
        sendLocalStatusChangeNotification()
    }
    
    func update(shop: (String, Address)?) {
        guard let validShop = shop else { return }
        if let validRemoteProduct = remoteProduct {
            if !validRemoteProduct.contains(shop: validShop.0) {
                var localStores: [String] = []
                    
                initLocalProduct()
                guard let validLocalProduct = localProduct else { return }
                    
                // start out withe the existing local shops
                switch validLocalProduct.storesOriginal {
                case .available(let existingLocalStores):
                    localStores = existingLocalStores
                default: break
                }

                // Add the new local shop, but check anyway
                if !localStores.contains(validShop.0) {
                    localStores.append(validShop.0)
                }
                    
                // also add the remote shops if they are not already there
                switch validRemoteProduct.storesOriginal {
                case .available(let remoteStores):
                    for store in remoteStores {
                        if !validLocalProduct.contains(shop: store) {
                            localStores.append(store)
                        }
                    }
                default: break
                }

                validLocalProduct.storesOriginal = .available(localStores)
            }
            // replace the new product place in all cases
            localProduct?.purchasePlacesAddress = Address.init(with: validShop)
            if let purchasePlace = localProduct?.purchasePlacesAddress?.asSingleString(withSeparator: ",") {
                localProduct?.purchasePlacesOriginal = Tags.init(string:purchasePlace)
            }
        } else {
            initLocalProduct()
            localProduct?.storesOriginal = .available([validShop.0])

            // replace the new product place in all cases
            localProduct?.purchasePlacesAddress = Address.init(with: validShop)
            if let purchasePlace = localProduct?.purchasePlacesAddress?.asSingleString(withSeparator: ",") {
                localProduct?.purchasePlacesOriginal = Tags.init(string:purchasePlace)
            }
        }
        sendLocalStatusChangeNotification()
    }
    
    func update(brandTags: [String]?) {
        if let validTags = brandTags {
            if let validRemoteProduct = remoteProduct {
                if !validRemoteProduct.contains(brands: validTags) {
                    initLocalProduct()
                    localProduct?.brandsOriginal = .available(validTags)
                }
            } else {
                initLocalProduct()
                localProduct?.brandsOriginal = .available(validTags)
            }
        }
    }
    
    func update(packagingTags: [String]?) {
        if let validTags = packagingTags {
            if let validRemoteProduct = remoteProduct {
                if !validRemoteProduct.contains(packaging: validTags) {
                    initLocalProduct()
                    localProduct?.packagingOriginal = .available(validTags)
                }
            } else {
                initLocalProduct()
                localProduct?.packagingOriginal = .available(validTags)
            }
        }
    }
    
    func update(tracesTags: [String]?) {
        // are there any countries to update?
        // empty means deleting the entries (if any)
        guard let validTags = tracesTags else { return }
        // is there really an updated list of countries?
        guard let validRemoteProduct = remoteProduct,
            !validRemoteProduct.contains(traces: validTags) else { return }

        initLocalProduct()
        // needed for translation purposes
        localProduct?.tracesInterpreted = .available(validTags)
        // needed for OFF updating
        localProduct?.tracesOriginal = .available(validTags)
        sendLocalStatusChangeNotification()
    }
    
    func update(labelTags: [String]?) {
        if let validTags = labelTags {
            if let validRemoteProduct = remoteProduct {
                if !validRemoteProduct.contains(labels: validTags) {
                    initLocalProduct()
                    localProduct?.labelsOriginal = .available(validTags)
                }
            } else {
                initLocalProduct()
                localProduct?.labelsOriginal = .available(validTags)
            }
        }
    }
    
    func update(categories: [String]?) {
        // are there any countries to update?
        // empty means deleting the entries (if any)
        guard let validTags = categories else { return }
        // is there really an updated list of countries?
        guard let validRemoteProduct = remoteProduct,
            !validRemoteProduct.contains(categories: validTags) else { return }
        initLocalProduct()
        if validTags.isEmpty {
            localProduct?.categoriesOriginal = .empty
        } else {
            // needed for translation purposes
            localProduct?.categoriesInterpreted = .available(validTags)
            // needed for OFF updating
            localProduct?.categoriesOriginal = .available(validTags)
        }
        sendLocalStatusChangeNotification()
    }
    
    func update(producer: [String]?) {
        if let validTags = producer {
            if let validRemoteProduct = remoteProduct {
                if !validRemoteProduct.contains(producer: validTags) {
                    initLocalProduct()
                    localProduct?.manufacturingPlacesOriginal = .available(validTags)
                }
            } else {
                initLocalProduct()
                localProduct?.manufacturingPlacesOriginal = .available(validTags)
            }
        }
    }
    
    func update(producerCode: [String]?) {
        if let validTags = producerCode {
            if let validRemoteProduct = remoteProduct {
                if !validRemoteProduct.contains(producerCode: validTags) {
                    initLocalProduct()
                    localProduct?.embCodesOriginal = .available(validTags)
                }
            } else {
                initLocalProduct()
                localProduct?.embCodesOriginal = .available(validTags)
            }
        }
    }
    
    func update(ingredientsOrigin: [String]?) {
        if let validTags = ingredientsOrigin {
            if let validRemoteProduct = remoteProduct {
                if !validRemoteProduct.contains(ingredientsOrigin: validTags) {
                    initLocalProduct()
                    localProduct?.originsOriginal = .available(validTags)
                }
            } else {
                initLocalProduct()
                localProduct?.originsOriginal = .available(validTags)
            }
        }
    }
    
    func update(stores: [String]?) {
        if let validTags = stores {
            if let validRemoteProduct = remoteProduct {
                if !validRemoteProduct.contains(stores: validTags) {
                    initLocalProduct()
                    localProduct?.storesOriginal = .available(validTags)
                }
            } else {
                initLocalProduct()
                localProduct?.storesOriginal = .available(validTags)
            }
        }
    }
    
    func update(purchaseLocation: [String]?) {
        if let validTags = purchaseLocation {
            if let validRemoteProduct = remoteProduct {
                if !validRemoteProduct.contains(purchaseLocation: validTags) {
                    initLocalProduct()
                    localProduct?.purchasePlacesOriginal = .available(validTags)
                }
            } else {
                initLocalProduct()
                localProduct?.purchasePlacesOriginal = .available(validTags)
            }
        }
    }
    
    // The countries are encoded as keys "en:france"
    // The old (remote) values are contained in the update
    func update(countries: [String]?) {
        // are there any countries to update?
        // empty means deleting the entries (if any)
        guard let validTags = countries else { return }
        // is there really an updated list of countries?
        guard let validRemoteProduct = remoteProduct,
            !validRemoteProduct.contains(countries: validTags) else { return }

        initLocalProduct()
        // needed for translation purposes
        localProduct?.countriesInterpreted = .available(validTags)
        // needed for OFF updating
        localProduct?.countriesOriginal = .available(validTags)
        sendLocalStatusChangeNotification()
    }
    
    func update(quantity: String) {
        if let validRemoteProduct = remoteProduct {
            if !validRemoteProduct.contains(quantity: quantity) {
                initLocalProduct()
                localProduct?.quantity = quantity
            }
        } else {
            initLocalProduct()
            localProduct?.quantity = quantity
        }
    }
    
    func update(periodAfterOpeningString: String) {
        if let validRemoteProduct = remoteProduct {
            if !validRemoteProduct.contains(periodAfterOpeningString: periodAfterOpeningString) {
                initLocalProduct()
                localProduct?.periodAfterOpeningString = periodAfterOpeningString
            }
        } else {
            initLocalProduct()
            localProduct?.periodAfterOpeningString = periodAfterOpeningString
        }
    }
    
    
    func update(links: [String]?) {
        if let validLinks = links {
            if let validRemoteProduct = remoteProduct {
                if !validRemoteProduct.contains(links: validLinks) {
                    initLocalProduct()
                    for item in validLinks {
                        if let validURL = URL(string: item) {
                            localProduct?.links = []
                            localProduct?.links?.append(validURL)
                        }
                    }
                }
            } else {
                initLocalProduct()
                for item in validLinks {
                    if let validURL = URL(string: item) {
                        localProduct?.links = []
                        localProduct?.links?.append(validURL)
                    }
                }
            }
        }
    }
    
    func update(availability: Bool, nutritionFactsPreparationStyle: NutritionFactsPreparationStyle) {
        initLocalProduct()
        localProduct?.hasNutritionFacts = availability
        if !availability {
            // if indicated as not available, delete the existing nutritionFacts
            update(facts: [], nutritionFactsPreparationStyle: nutritionFactsPreparationStyle)
            }
    }
    
    func add(fact: NutritionFactItem?, nutritionFactsPreparationStyle: NutritionFactsPreparationStyle) {
        guard let validFact = fact  else { return }
        initLocalProduct()
        if localProduct?.nutritionFacts[nutritionFactsPreparationStyle] == nil {
            localProduct?.nutritionFacts = [nutritionFactsPreparationStyle: Set(arrayLiteral: validFact)]
        } else {
            localProduct?.nutritionFacts[nutritionFactsPreparationStyle]?.update(with: validFact)
        }
        // if nutritionFacts specified indicate as available
        localProduct?.hasNutritionFacts = true
    }

    func update(fact: NutritionFactItem?, perUnit: NutritionEntryUnit, nutritionFactsPreparationStyle: NutritionFactsPreparationStyle) {
        guard let validFact = fact  else { return }
        initLocalProduct()
        if localProduct?.nutritionFacts[nutritionFactsPreparationStyle] == nil {
            localProduct?.nutritionFacts = [nutritionFactsPreparationStyle: Set(arrayLiteral: validFact)]
        } else {
            localProduct?.nutritionFacts[nutritionFactsPreparationStyle]?.update(with: validFact)
        }
        // if nutritionFacts specified indicate as available
        localProduct?.hasNutritionFacts = true
        if localProduct?.nutritionFactsIndicationUnit?[nutritionFactsPreparationStyle] == nil {
            let newUnit = NutritionEntryUnit()
            localProduct!.nutritionFactsIndicationUnit = [nutritionFactsPreparationStyle: newUnit]
        } else {
            localProduct?.nutritionFactsIndicationUnit?[nutritionFactsPreparationStyle] = perUnit
        }
    }
    
/**
Update the nutrient unit of a nutrient. If  the nutrient already exists remotely, the corresponding values will be copied.

- Parameters:
    - nutrient: the nutrient to be changed
    - unit: the new unit to be used (kJ, Cal, milligram, etc)
    - perUnit: the per (serving/100g)
*/
    func update(nutrient: Nutrient?, unit: NutritionFactUnit?, perUnit: NutritionEntryUnit, nutritionFactsPreparationStyle: NutritionFactsPreparationStyle) {
        guard let validNutrient = nutrient else { return }
        guard let validUnitEdited = unit else { return }
        // has this nutrient already been edited?
        if let nutritionFactItems = localProduct?.nutritionFacts[nutritionFactsPreparationStyle]?.filter({ $0.key == validNutrient.key}),
            var editedNutritionFactItem = nutritionFactItems.first {
            editedNutritionFactItem.valueUnitEdited = validUnitEdited
            localProduct?.nutritionFacts[nutritionFactsPreparationStyle]?.update(with: editedNutritionFactItem)
        // is this an remotely existing nutrient?
        } else if let nutritionFactItems = remoteProduct?.nutritionFacts[nutritionFactsPreparationStyle]?.filter({ $0.key == validNutrient.key}),
            var editedNutritionFactItem = nutritionFactItems.first {
            // create a local product version if needed
            initLocalProduct()
            // copy only the values as this are the edited data
            switch perUnit {
            case .perStandardUnit:
                editedNutritionFactItem.valueEdited = editedNutritionFactItem.standard
            case .per1000Gram:
                editedNutritionFactItem.valueEdited = "1000 gram"
            case .perServing:
                editedNutritionFactItem.valueEdited = editedNutritionFactItem.serving
            case .perDailyValue:
                editedNutritionFactItem.valueEdited = "daily value"
            }
            editedNutritionFactItem.nutrient = validNutrient
            // set the new unit
            editedNutritionFactItem.valueUnitEdited = validUnitEdited
            localProduct?.nutritionFacts[nutritionFactsPreparationStyle]?.update(with: editedNutritionFactItem)
        // This nutrient does not exist remotely or locally
        } else {
            // create a local version if needed
            initLocalProduct()
            var editedNutritionFactItem = NutritionFactItem()
            // set the new unit
            editedNutritionFactItem.valueUnitEdited = validUnitEdited
            localProduct?.nutritionFacts[nutritionFactsPreparationStyle]?.update(with: editedNutritionFactItem)
        }
        sendLocalStatusChangeNotification()
        if localProduct?.nutritionFactsIndicationUnit?[nutritionFactsPreparationStyle] == nil {
            localProduct?.nutritionFactsIndicationUnit?[nutritionFactsPreparationStyle] = NutritionEntryUnit()
        }
        localProduct?.nutritionFactsIndicationUnit?[nutritionFactsPreparationStyle] = perUnit
    }
    
    func update(facts: Set<NutritionFactItem>, nutritionFactsPreparationStyle: NutritionFactsPreparationStyle) {
        // TODO: need to check if a fact has been updated
        initLocalProduct()
        
        localProduct?.nutritionFacts[nutritionFactsPreparationStyle] = facts

        localProduct?.hasNutritionFacts = !localProduct!.nutritionFacts.isEmpty ? true : false
    }
    
    func updateImage(key:String?, languageCode:String?, imageType:ImageTypeCategory?) {
        
        var originalImages: [String:ProductImageSize] {
            var newImages: [String:ProductImageSize] = [:]
            if localProduct == nil {
                newImages = remoteProduct?.images ?? [:]
            } else {
                newImages = localProduct?.images ?? [:]
                if let validImages = remoteProduct?.images {
                    let images = validImages
                    newImages = newImages.merging(images, uniquingKeysWith: { (first, last) in last } )
                }
            }
            return newImages
        }

        guard let selectedLanguageCode = languageCode else { return }
        guard let selectedImageTypeCategory = imageType else { return }
        guard let validKey = key else { return }
        if let result = originalImages[validKey]?.largest?.fetch() {
            switch result {
            case .success(let image):
                switch selectedImageTypeCategory {
                case .front:
                    update(frontImage: image, for: selectedLanguageCode)
                case .ingredients:
                    update(ingredientsImage: image, for: selectedLanguageCode)
                case .nutrition:
                    update(nutritionImage: image, for: selectedLanguageCode)
                case .packaging:
                    update(packagingImage: image, for: selectedLanguageCode)
                default:
                    break
                }
            default:
                break
            }
            sendLocalStatusChangeNotification()
        }
    }
    
    func update(frontImage: UIImage, for languageCode: String) {
        initLocalProduct()
        localProduct?.frontImages[languageCode] = ProductImageSize()
        localProduct?.frontImages[languageCode]?.original = ProductImageData.init(image: frontImage, url: ProductStorage.manager.fileUrl(with: self.barcodeType, for: languageCode, and: .front(languageCode)))
    }
    
    func update(nutritionImage: UIImage, for languageCode: String) {
        initLocalProduct()
        localProduct!.nutritionImages[languageCode] = ProductImageSize()
        localProduct!.nutritionImages[languageCode]?.original = ProductImageData.init(image: nutritionImage, url: ProductStorage.manager.fileUrl(with: self.barcodeType, for: languageCode, and: .nutrition(languageCode)))
    }
    
    func update(ingredientsImage: UIImage, for languageCode: String) {
        initLocalProduct()
        localProduct!.ingredientsImages[languageCode] = ProductImageSize()
        localProduct!.ingredientsImages[languageCode]?.original = ProductImageData.init(image: ingredientsImage, url: ProductStorage.manager.fileUrl(with: self.barcodeType, for: languageCode, and: .ingredients(languageCode)))
    }
    
    func update(packagingImage: UIImage, for languageCode: String) {
        initLocalProduct()
        localProduct!.packagingImages[languageCode] = ProductImageSize()
        localProduct!.packagingImages[languageCode]?.original = ProductImageData.init(image: packagingImage, url: ProductStorage.manager.fileUrl(with: self.barcodeType, for: languageCode, and: .packaging(languageCode)))
    }

    func update(image: UIImage, id: String) {
        initLocalProduct()
        localProduct!.images[id] = ProductImageSize()
        localProduct!.images[id]?.display = ProductImageData.init(image: image, url: ProductStorage.manager.fileUrl(with: self.barcodeType, for: id, and: .general(id)))
    }
    
    func uploadOperationsDict() -> [String:Operation] {
        
        // save any new comment in the history
        var storedHistory = History()
        storedHistory.add(barcodeType: barcodeType, with: comment)


        guard let validProduct = localProduct,
            updateIsAllowed else { return [:] }
        
        // Also create a local copy, just in case.
        ProductStorage.manager.save(validProduct) { (result: ResultType<FoodProduct>) in
            switch result {
            case .success:
                print("ProductPair: Local save successfull")
            case .failure(let error):
                print("ProductPair: error code: \(error.localizedDescription)")
            }
        }
        

        var operations: [String:Operation] = [:]

        operations[self.barcodeType.asString] = ProductUpdate(product: validProduct) { (result: ResultType<OFFProductUploadResultJson>) in
            switch result {
            case .success:
                DispatchQueue.main.async(execute: { () -> Void in
                    NotificationCenter.default.post(name: .ProductUpdateSucceeded, object: nil, userInfo: nil)
                })

                self.localProduct?.removedUpdatedData()
            case .failure(let error as NSError):
                DispatchQueue.main.async(execute: { () -> Void in
                    NotificationCenter.default.post(name: .ProductUpdateFailed, object: nil, userInfo: nil)
                    print("ProductPair: error code:", error.code, error.description)
                })

            }
            self.reloadAfterUpdate()
        }
        
        
        // add the image upload operations
        if validProduct.frontImages.count > 0 {
            operations = operations.merging(uploadImages(validProduct.frontImages, imageTypeCategory: .front(""))) { (_, new) in new }
        }
        
        if validProduct.ingredientsImages.count > 0 {
            operations = operations.merging(uploadImages(validProduct.ingredientsImages, imageTypeCategory: .ingredients(""))) { (_, new) in new }
        }
        
        if validProduct.nutritionImages.count > 0 {
            operations = operations.merging(uploadImages(validProduct.nutritionImages, imageTypeCategory: .nutrition(""))) { (_, new) in new }
        }
        
        if validProduct.packagingImages.count > 0 {
            operations = operations.merging(uploadImages(validProduct.packagingImages, imageTypeCategory: .packaging(""))) { (_, new) in new }
        }

        if validProduct.images.count > 0 {
            operations = operations.merging(uploadImages(validProduct.images, imageTypeCategory: .general(""))) { (_, new) in new }
        }

        return operations
    }
    
    func uploadRobotoffAnswer(question: RobotoffQuestion) -> [String:Operation] {
        
        var operations: [String:Operation] = [:]

        operations[self.barcodeType.asString] = RobotoffUpdate(question: question) { (result: ResultType<OFFRobotoffUploadResultJson>) in
            switch result {
            case .success:
                DispatchQueue.main.async(execute: { () -> Void in
                    NotificationCenter.default.post(name: .ProductUpdateSucceeded, object: nil, userInfo: nil)
                })
                self.remove(question)
            case .failure(let error as NSError):
                DispatchQueue.main.async(execute: { () -> Void in
                    NotificationCenter.default.post(name: .ProductUpdateFailed, object: nil, userInfo: nil)
                    print("ProductPair: error code:", error.code, error.description)
                })

            }
            self.reload()
        }
        
        return operations
    }
    
    private func remove(_ question: RobotoffQuestion) {
        remoteProduct?.remove(robotoff: question)
    }

    private func reloadAfterUpdate() {
        // if all local data has been uploaded, I can reset the local product and
        // keep only the remote product
        if self.localProduct!.isEmpty
            && !self.localProduct!.hasImages {
            self.localStatus = .updated(self.barcodeType.asString)
        }
        // get the new data from OFF
        self.reload()
    }

    private func uploadImages(_ dict: [String:ProductImageSize], imageTypeCategory: ImageTypeCategory) -> [String:Operation] {
        // any image to upload?
        guard dict.count > 0 else { return [:] }
        
        var operations: [String:Operation] = [:]
        for element in dict {
            
            // Is there a valid original image?
            if let fetchResult = element.value.largest?.fetch() {
                switch fetchResult {
                case .success(let image):
                    // start by unselecting any existing image
                    // this will remove any selected images from the cache as well
                    let imageDeselectOperationDict = deselect(element.key, of: imageTypeCategory)
                    let imageUploadOperation = ImageUpload(image: image,
                                                           languageCode: element.key,
                                                           productType: self.barcodeType.productType!,
                                                           imageTypeCategory: encodeImageType(key: element.key, type: imageTypeCategory),
                                                           barcodeString: self.barcodeType.asString ) {
                                                            (result: ProductUpdateStatus?) in
                        guard let validResult = result else { return }
                        switch validResult {
                        case .success:
                            switch imageTypeCategory {
                            case .front:
                                self.localProduct?.frontImages.removeValue(forKey: element.key)
                            case .ingredients:
                                self.localProduct?.ingredientsImages.removeValue(forKey: element.key)
                            case .nutrition:
                                self.localProduct?.nutritionImages.removeValue(forKey: element.key)
                            case .packaging:
                                self.localProduct?.packagingImages.removeValue(forKey: element.key)
                            case .general:
                                self.localProduct?.images.removeValue(forKey: element.key)
                            }
                            DispatchQueue.main.async(execute: {
                                print("ProductPair: image upload succeeded")
                                let userInfo = [Notification.BarcodeKey: self.barcodeType.asString as String,
                                            Notification.ImageTypeCategoryKey: imageTypeCategory.description as String,
                                            Notification.ImageIDKey: element.key as String]
                                NotificationCenter.default.post(name: .ProductPairImageUploadSuccess, object: nil, userInfo: userInfo)
                                self.reloadAfterUpdate()
                            })
                        default:
                            print("ProductPair: image upload failed")
                            break
                        }
                    }
                    for (key, operation) in imageDeselectOperationDict {
                        // The upload can only start when the deselections are finished.
                        imageUploadOperation.addDependency(operation)
                        operations[key] = operation
                    }
                    let key = barcodeType.asString + imageTypeCategory.description + element.key + "upload"
                    operations[key] = imageUploadOperation
                default: break
                }
            }
        }
        return operations
    }
    
    private func encodeImageType(key: String, type: ImageTypeCategory) -> ImageTypeCategory {
        switch type {
        case .general:
            return .general(key)
        case .front:
            return .front(key)
        case .ingredients:
            return .ingredients(key)
        case .nutrition:
            return .nutrition(key)
        case .packaging:
            return .packaging(key)
        }
    }
    
    func deselect(_ languageCode: String, of imageTypeCategory: ImageTypeCategory) -> [String:Operation] {
            // any remote image for the changed language and imageTypeCategory is no longer relevant
        switch imageTypeCategory {
        case .front:
            remoteProduct?.frontImages[languageCode]?.reset()
        case .ingredients:
            remoteProduct?.ingredientsImages[languageCode]?.reset()
        case .nutrition:
            remoteProduct?.nutritionImages[languageCode]?.reset()
        default: break
        }
        let operation = ImageDeselect(languageCode, imageTypeCategory: imageTypeCategory, productType: self.barcodeType.productType!, barcodeString: self.barcodeType.asString) { (result: ProductUpdateStatus?) in
                guard let validResult = result else { return }
                switch validResult {
                case .success:
                    DispatchQueue.main.async(execute: {
                        let userInfo = [Notification.BarcodeKey: self.barcodeType.asString as String,
                                    Notification.ImageTypeCategoryKey: imageTypeCategory.description as String]
                        NotificationCenter.default.post(name: .ProductPairImageDeleteSuccess, object: nil, userInfo: userInfo)
                        print("ProductPair: The selected on off is deleted")
                    })
                default:
                    break
                }
            }
        let key = barcodeType.asString + imageTypeCategory.description + languageCode + "deselect"
        return [key:operation]
    }

}

// Notification definitions

extension Notification.Name {
    static let ProductUpdateSucceeded = Notification.Name("ProductPair.Notification.ProductUpdateSucceeded")
    static let ProductUpdateFailed = Notification.Name("ProductPair.Notification.ProductUpdateFailed")
    static let ProductPairUpdated = Notification.Name("ProductPair.Notification.ProductPairUpdated")
    static let ProductPairLocalStatusChanged = Notification.Name("ProductPair.Notification.LocalStatusChanged")
    static let ProductPairRemoteStatusChanged = Notification.Name("ProductPair.Notification.RemoteStatusChanged")
    static let ProductPairImageUploadSuccess = Notification.Name("ProductPair.Notification.ImageUploadSuccess")
    static let ProductPairImageDeleteSuccess = Notification.Name("ProductPair.Notification.ImageDeleteSuccess")
}



