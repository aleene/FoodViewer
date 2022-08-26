//
//  OFFSearchRequest.swift
//  FoodViewer
//
//  Created by arnaud on 04/02/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import Foundation
import UIKit


class OFFSearchRequest {
    
    private var debug = false
    
    fileprivate struct OpenFoodFacts {
        static let APIURLPrefixForFoodProduct = "http://world.openfoodfacts.org/api/v0/product/"
        static let APIURLPrefixForBeautyProduct = "http://world.openbeautyfacts.org/api/v0/product/"
    }
    
    enum FetchJsonResult {
        case error(String)
        case success(Data)
    }
    
    var fetched: SearchFetchStatus = .initialized
    
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }
    
    func fetchProducts(for query: SearchTemplate, on page:Int) -> SearchFetchStatus {
        //DispatchQueue.main.async(execute: { () -> Void in
        //    UIApplication.shared.isNetworkActivityIndicatorVisible = true
        //})
        // encode the url-string
        let search = OFF.searchString(for: query, on: page)
        if let escapedSearch = search.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) {
            
            let fetchUrl = URL(string:escapedSearch)
            //DispatchQueue.main.async(execute: { () -> Void in
            //    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            //})
            if let url = fetchUrl {
                do {
                    let data = try Data(contentsOf: url, options: NSData.ReadingOptions.mappedIfSafe)
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .secondsSince1970
                        let searchResultJson = try decoder.decode(OFFSearchResultJson.self, from: data)
                        if let searchResultSize = searchResultJson.count {
                            let searchPage = searchResultJson.page ?? 0
                            let searchPageSize = searchResultJson.page_size ?? 1
                            // the products in the json
                            if let jsonProducts = searchResultJson.products {
                                var products: [FoodProduct] = []
                                for jsonProduct in jsonProducts {
                                    products.append(FoodProduct.init(json: jsonProduct))
                                }
                                return SearchFetchStatus.list((searchResultSize, searchPage, searchPageSize, products))
                            } else {
                                print("OpenFoodFactsRequest: Not a valid Search array")
                                return SearchFetchStatus.loadingFailed("Search loading failed")
                            }
                        } else {
                            print ("OpenFoodFactsRequest: Not a valid OFF JSON")
                            return SearchFetchStatus.loadingFailed("Search loading failed")
                        }
                    } catch let error {
                        print (error)
                        return .loadingFailed(url.absoluteString)
                        
                    }
                } catch let error as NSError {
                    print(error)
                    return SearchFetchStatus.loadingFailed(error.description)
                }
            } else {
                return SearchFetchStatus.loadingFailed("Retrieved a json file that is no longer relevant for the app.")
            }
            
        } else {
            return SearchFetchStatus.loadingFailed("Search URL could not be encoded.")
        }
    }
    
}
