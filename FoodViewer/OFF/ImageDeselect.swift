//
//  ImageDeselect.swift
//  FoodViewer
//
//  Created by arnaud on 27/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

class ImageDeselect: OFFImageDeselectAPI {
    
    func deselect(_ languageCode: String, imageTypeCategory: ImageTypeCategory, productType:ProductType, barcodeString: String, completionHandler: @escaping (ProductUpdateStatus?) -> ()) {
        // Translate all FoodViewer objects to OFF-strings:
        // - The ImageTypeCategory determines, which image will be deselected
        // - For each productType another OFF-server must be used. This is encoded as the rawValue of ProductType
        // The completionHandler of the parent contains a json and needs to be translated as well
        switch imageTypeCategory {
        case .front, .ingredients, .nutrition:
            super.deselect(languageCode, offServer: productType.rawValue, of: imageTypeCategory.description, for: barcodeString) { ( json: OFFImageDeselectResultJson? ) in
                if let validStatus = json?.status {
                    if let validStatus_code = json?.status_code {
                        if validStatus_code == 0 {
                            return completionHandler(ProductUpdateStatus.success(barcodeString, validStatus))
                        } else if validStatus_code == 1 {
                            return completionHandler(ProductUpdateStatus.failure(barcodeString, validStatus))
                        } else {
                            return completionHandler(ProductUpdateStatus.failure(barcodeString, "OFFUpdate:unexpected status_code: \(validStatus_code)"))
                        }
                    } else {
                        return completionHandler(ProductUpdateStatus.failure(barcodeString, validStatus))
                    }
                }
                return completionHandler(ProductUpdateStatus.failure(barcodeString, "OFFUpdate: no valid status"))
            }

        default:
            completionHandler(nil)
        }
    }
}

