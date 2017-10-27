//
//  SearchSortOrder.swift
//  FoodViewer
//
//  Created by arnaud on 25/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

/*
 
 # Output
 sort_by # sort_by
 unique_scans_n # Popularity
 product_name # Product name
 created_t # Add date
 last_modified_t # Edit date
 
 */
enum SearchSortOrder {
    case popularity
    case productName
    case addDate
    case editDate
    
    var description: String {
        switch self {
        case .popularity:
            return TranslatableStrings.Popularity
        case .productName:
            return TranslatableStrings.ProductName
        case .addDate:
            return TranslatableStrings.CreationDate
        case .editDate:
            return TranslatableStrings.EditDate
        }
    }
    
    static var all: [SearchSortOrder] {
        return [SearchSortOrder.popularity,
                SearchSortOrder.productName,
                SearchSortOrder.addDate,
                SearchSortOrder.editDate]
    }
}
