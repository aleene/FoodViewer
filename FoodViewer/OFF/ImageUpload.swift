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
    
    init(image: UIImage, languageCode: String, productType: ProductType, imageTypeCategory: ImageTypeCategory, barcodeString: String, completion: @escaping (ProductUpdateStatus?) -> () ) {
        
        super.init(image: image, languageCode: languageCode, OFFServer: productType.rawValue, imageTypeString: imageTypeCategory.description, barcodeString: barcodeString ) {
            ( json: OFFImageUploadResultJson? ) in
            if let validStatus = json?.status {
                if validStatus == "status ok" {
                    return completion(ProductUpdateStatus.success(barcodeString, "\(validStatus)"))
                } else {
                    return completion(ProductUpdateStatus.failure(barcodeString, "OFFImageUploadResultJson \(validStatus)"))
                }
            }
            return completion(nil)
        }
    }
    
    override func main() {
        super.main()
    }
}
