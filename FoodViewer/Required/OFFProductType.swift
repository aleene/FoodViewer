//
//  ProductType.swift
//  OFFFolksonomy
//
//  Created by Arnaud Leene on 13/10/2022.
//

import Foundation

/**
An enumerator type describing all possible OpenFoodFacts product types that are supported
 
Values:
 - food - for food pzroducts
    - petFood - for petfood products
    - beauty - for beauty products
    - product - for any other product (not food, petfood, beauty)
*/
public enum OFFProductType: String {
    case food
    case petFood
    case beauty
    case product
    
    /// A a human readable description of the current value for Product Type.
    var description: String {
        switch self {
        case .food:
            return "Food product"
        case .petFood:
            return "Petfood product"
        case .beauty:
            return "Beauty product"
        case .product:
            return "General product"
        }
    }
}

/// Extension required for specifics of the different product types of OFF
extension OFFProductType {
    
    /// The host part of an URL for a producttype
    var host: String {
        switch self {
        case .food: return "openfoodfacts"
        case .petFood: return "openpetfoodfacts"
        case .beauty: return "openbeautyfacts"
        case .product: return "openproductfacts"
        }
    }
}

