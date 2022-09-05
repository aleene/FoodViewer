//
//  OFFHttpPost.swift
//  FoodViewer
//
//  Created by arnaud on 11/02/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

struct OFFHttpPost {
    
    struct URL {
        static let GetPostPrefix = "cgi/product_jqm2.pl?"
        static let Prefix = "https://world."
        static let Domain = ".org/"
        static let SecurePrefix = "https://ssl-api."
        static let AddPostFix = "cgi/product_image_upload.pl"
        static let UnselectPostFix = "cgi/product_image_unselect.pl"
    }
    
    static let ImgUpload = "imgupload_"
    
    struct AddParameter {
        static let BarcodeKey = "code"  // The barcode of the product
        struct ImageField {
            static let Key = "imagefield" // the type of image field
            struct Value {
                static let General = "general" // value for any image
                static let Front = "front" // value for front image
                static let Ingredients = "ingredients" // value for ingredients image
                static let Packaging = "packaging" // value for nutrition image
                static let Nutrition = "nutrition" // value for nutrition image
            }
        }
        static let UserId = "user_id"
        static let Password = "password"
    }
    
    struct UnselectParameter {
        static let CodeKey = "code"  // The barcode of the product
        static let IdKey = "id"
        static let UserId = "user_id"
        static let Password = "password"
    }
    
    struct ResultJson {
        struct Key {
            static let Status = "status"
            static let StatusVerbose = "status_verbose"
            static let StatusCode = "status_code"
            static let ImageField = "imagefield"
            static let ImageID = "imgid" // Int?
            static let Error = "error"
        }
        struct Value {
            static let StatusOK = "status ok"
            static let ImageToSmall = "-4"
        }
    }
        
    // returns the value for the imagefield key, based on the image type and languageCode
    static func imageFieldValue(for type: String, in languageCode: String) -> String {
        return type + "_" + languageCode
    }
    
    // returns the value for the id key, based on the image type and languageCode
    static func idValue(for type: String, in languageCode: String) -> String {
        return imageFieldValue(for: type, in: languageCode)
    }
    
    static func imageName(for type: String, in languageCode: String) -> String {
        return ImgUpload + imageFieldValue(for: type, in: languageCode)
    }

}
