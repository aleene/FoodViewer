//
//  OFFOCRRequestAPI.swift
//  FoodViewer
//
//  Created by arnaud on 15/11/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

/// The OFFRobotoffQuestionFetchStatus describes the  retrieval status  of a robotoff question retrieval call
enum OFFOCRFetchStatus {
    // nothing is known at the moment
    case initialized
    // the barcode is set, but no load is initialised
    case notLoaded(String) // (barcodeString)
    // the load did not succeed
    case failed(String) // (barcodeString)
    // loading indicates that it is trying to load the product
    case loading(String) // (barcodeString)
    // the recginition has been loaded successfully and can be set.
    case success(String) // (recognised text)
    // the product is not available on the off servers
    case productNotAvailable(String) // (barcodeString)
}

/**
Functions to interface with the OCR API.
*/
class OFFOCRRequestAPI {
       
// MARK: - constants
    
    private struct Constant {
        
        struct Divider {
            static let Slash = "/"
            static let Dot = "."
            static let Equal = "="
            static let QuestionMark = "?"
            static let Ampersand = "&"
        }
        
        struct URL {
            static let Scheme = "https://"
            static let Prefix = "world"
            static let TopDomain = "org"
            static let CGI = "cgi/ingredients.pl"
            static let Code = "code"
            static let Id = "id"
            static let Ingredients = "ingredients_"
            static let Postfix = "&process_image=1&ocr_engine=tesseract"
        }
    }

    // Api usage example:
    // https://world.openfoodfacts.net/cgi/ingredients.pl?code=13333560&id=ingredients_en&process_image=1&ocr_engine=tesseract
    /*
    Retrieve the robotoff questions for a product
     Parameters:
     - barcode: the barcode of the product
     - id: the id of the image, ie always ingredients with the languageCode added
     - process_image: always 1 ?
    */
    private static func fetchOCRString(barcode: BarcodeType, productType: ProductType, languageCode: String) -> String {
        var fetchUrlString = Constant.URL.Scheme        // https://
        fetchUrlString += Constant.URL.Prefix           // world
        fetchUrlString += Constant.Divider.Dot          // .
        fetchUrlString += productType.rawValue          // openfoodfacts
        fetchUrlString += Constant.Divider.Dot          // .
        fetchUrlString += Constant.URL.TopDomain        // org
        
        fetchUrlString += Constant.Divider.Slash        // /
        fetchUrlString += Constant.URL.CGI              // cgi/ingredients.pl
        fetchUrlString += Constant.Divider.QuestionMark // ?
        
        fetchUrlString += Constant.URL.Code             // code
        fetchUrlString += Constant.Divider.Equal        // =
        fetchUrlString += barcode.asString         // 1234567890123
        
        fetchUrlString += Constant.Divider.Ampersand    // &
        fetchUrlString += Constant.URL.Id               // id
        fetchUrlString += Constant.Divider.Equal        // =
        fetchUrlString += Constant.URL.Ingredients      // ingredients_
        fetchUrlString += languageCode                  // en
        
        fetchUrlString += Constant.URL.Postfix          // &process_image=1&ocr_engine=tesseract
        return fetchUrlString
    }
    
// MARK: - public variables
        
    // The barcode of the product for which the questions must be retrieved
    public var barcode: BarcodeType?
    
    public var ocrFetchStatus: OFFOCRFetchStatus = .initialized

// MARK: - intialisers
    
/** Initialise the questions to retrieve
- parameters:
     - barcode: the barcode of the product to do ingredients OCR on
     - productType: the productType to do ingredients OCR on (selects the correct server)
     - languageCode: the languageCode of the product to do ingredients OCR on
*/
    init(barcode: BarcodeType, productType: ProductType, languageCode: String) {
        self.barcode = barcode
        self.productType = productType
        self.languageCode = languageCode
    }
        
// MARK: - public functions
           
    /// Peform an ocr
    public func performOCR() {
        switch ocrFetchStatus {
        // start the fetch if it is not yet loading
        case .initialized, .success:
            guard let validBarcode = barcode else {
                ocrFetchStatus = .failed("barcode is nil")
                return
            }
            // reset the status
            ocrFetchStatus = .loading("\(validBarcode.asString)")
            fetch(barcode: validBarcode, productType: productType, languageCode: languageCode)
        default:
            break
        }
    }

// MARK: - private variables
    
    // The productType to do ingredients OCR on (selects the correct server)
    private var productType: ProductType = .food
    
    // The languageCode of the ingredients to work on
    private var languageCode = "en"
               
    private var recognitionText: String {
        switch ocrFetchStatus {
        // start the fetch
        case .initialized:
            guard let validBarcode = barcode else {
                ocrFetchStatus = .failed("barcode is nil")
                return "Nothing"
            }
            fetch(barcode: validBarcode, productType: productType, languageCode: languageCode)
            ocrFetchStatus = .loading("\(validBarcode.asString)")
        case .success(let recognition):
            return recognition
        default:
            break
        }
        return "Nothing"
    }
    
    private let pendingOperations = PendingOperations()

    /// Fetch the questions for a specific barcode
    private func fetch(barcode: BarcodeType, productType: ProductType, languageCode: String) {
        fetchOCRJson(barcode: barcode, productType: productType, languageCode: languageCode) { (completion: OFFOCRFetchStatus) in
            switch completion {
            case .success(let ocrResult):
                self.ocrFetchStatus = .success(ocrResult)
            case .failed(let error):
                self.ocrFetchStatus = .failed(error)
            case .loading:
                self.ocrFetchStatus = .loading("")
            default:
                self.ocrFetchStatus = .failed("What was the error?")
            }
            DispatchQueue.main.async(execute: { () -> Void in
                NotificationCenter.default.post(name: .OCRFetchStatusChanged, object: nil, userInfo: nil)
            })
        }
    }
    
    private func fetchOCRJson(barcode: BarcodeType, productType: ProductType, languageCode: String, completion: @escaping (OFFOCRFetchStatus) -> ()) {
        
        DispatchQueue.main.async(execute: { () -> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        })
        let string = OFFOCRRequestAPI.fetchOCRString(barcode: barcode, productType: productType, languageCode: languageCode)
        let fetchUrl = URL(string: string )
        if let validURL = fetchUrl {
            let cache = Shared.dataCache
            cache.remove(URL:validURL)
            cache.fetch(URL: validURL).onSuccess { data in
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                do {
                    let ocrJson = try decoder.decode(OFFOCRJson.self, from: data)
                    if let ocrText = ocrJson.ingredients_text_from_image {
                        completion(.success(ocrText))
                    } else {
                        if ocrJson.status == 1 {
                            completion(.failed(barcode.asString))
                        }
                    }
                } catch let error {
                    print("fetchOCRJson: ", error.localizedDescription)
                    completion(.failed(error.localizedDescription))
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                })
                return
            }
            cache.fetch(URL: validURL).onFailure { error in
                print("fetchOCRJson: ", error!.localizedDescription)
                completion(.failed(error?.localizedDescription ?? "No error description provided"))
            }
            DispatchQueue.main.async(execute: { () -> Void in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
        } else {
            completion(.failed(barcode.asString))
            DispatchQueue.main.async(execute: { () -> Void in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
            return
        }
    }
}
// Definition:
extension Notification.Name {
    static let OCRFetchStatusChanged = Notification.Name("OFFOCRRequestAPI.Notification.OCRFetchStatusChanged")
}
