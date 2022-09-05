//
//  OFFProductImageDetailed.swift
//  FoodViewer
//
//  Created by arnaud on 11/02/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import Foundation

class OFFProductImageDetailed: OFFProductImage {
    
    struct DetailedKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        var intValue: Int? { return nil }
        init?(intValue: Int) { return nil }
        
        static let imgid = DetailedKeys(stringValue: "imgid")!
        static let uploaded_t = DetailedKeys(stringValue: "uploaded_t")!
        static let rev = DetailedKeys(stringValue: "rev")!
        
    }
    
    public var imgid: String? = nil
    public var uploaded_t: Double? = nil
    public var rev: String? = nil
    required init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: DetailedKeys.self)
        
        self.imgid = container.forceString(key: .imgid)
        self.uploaded_t = container.forceDouble(key: .uploaded_t)
        self.rev = container.forceString(key: .rev)
        
        try super.init(from: decoder)
    }
    
}
