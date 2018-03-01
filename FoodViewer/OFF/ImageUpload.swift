//
//  ImageUpload.swift
//  FoodViewer
//
//  Created by arnaud on 28/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

class ImageUpload : OFFImageUploadAPI {
    
    func upload(image: UIImage, languageCode: String, productType: ProductType, imageTypeCategory: ImageTypeCategory, barcodeString: String, completionHandler: @escaping (ProductUpdateStatus?) -> () ) {
        
        super.upload(image: image, languageCode: languageCode, offServer: productType.rawValue, imageTypeString: imageTypeCategory.description, barcodeString: barcodeString ) {
            ( json: OFFImageUploadResultJson? ) in
            if let validStatus = json?.status {
                if validStatus == "status ok" {
                    return completionHandler(ProductUpdateStatus.success(barcodeString, "\(validStatus)"))
                } else {
                    return completionHandler(ProductUpdateStatus.failure(barcodeString, "OFFImageUploadResultJson \(validStatus)"))
                }
            }
            return completionHandler(nil)
        }
    }
    
}
