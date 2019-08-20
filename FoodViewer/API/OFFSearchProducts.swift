//
//  OFFSearchProducts.swift
//  FoodViewer
//
//  Created by arnaud on 05/02/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import Foundation

class OFFSearchProducts {
    
    // This class is implemented as a singleton
    // The productsArray is only needed by the ProductsViewController
    // Unfortunately moving to another VC deletes the products, so it must be stored somewhere more permanently.
    // The use of a singleton limits thus the number of file loads
    
    
    static let manager = OFFSearchProducts()
    
    // all search queries that the user has performed
    var allSearchQueries: [Search] = []
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }
    
    func addAndSearch(query:SearchTemplate) {
        let newSearch = Search.init(query: query)
        allSearchQueries.append(newSearch)
        newSearch.startSearch()
    }
    
    // create a new search based on a long press
    func search(_ string: String?, in category: SearchComponent) {
        let newSearch = Search(for: string, in: category)
        allSearchQueries.append(newSearch)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func flush() {
        print("OFFSearchProducts.flush - flush all products for all searchQueries")
        self.allSearchQueries.forEach({ $0.flush() })
    }
    
}
