//
//  OFFSearchResultJson.swift
//  FoodViewer
//
//  Created by arnaud on 16/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

class OFFSearchResultJson : Codable {
    
    // total number of search results
    var count: Int? = nil
    // page number. Starts at 1 !!!
    var page: Int? = nil
    // what is this?
    var page_count: Int? = nil
    // the number of products per json
    var page_size: Int? = nil
    // 1 - if product found
    // an array with the products
    var products: [OFFProductDetailed]? = nil
    // what is this?
    var skip: Int? = nil
    
    enum CodingKeys: String, CodingKey {
        case count
        case page
        case page_size
        case products
        case skip
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.count = try container.decode(Int.self, forKey: .count)
        do {
            self.page = try container.decode(Int.self, forKey: .page)
        } catch {
            do {
                let asString = try container.decode(String.self, forKey: .page)
                self.page = Int(asString)
               } catch {
                self.page = nil
            }
        }
        
        do {
            self.page_size = try container.decode(Int.self, forKey: .count)
        } catch {
            let page_sizeAsString = try container.decode(String.self, forKey: .count)
            print("pageSize as string", page_sizeAsString)
        }
        self.products = try container.decode(Array.self, forKey: .products)
        self.skip = try container.decode(Int.self, forKey: .skip)

    }
}
