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

    }
    
    public var imgid: String? = nil
    public var uploaded_t: Double? = nil
    
    required init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: DetailedKeys.self)
        
        do {
            self.imgid = try container.decode(String.self, forKey: .imgid)
        } catch {
            do {
                let intCode = try container.decode(Int.self, forKey: .imgid)
                self.imgid = "\(intCode)"
            } catch {
                self.imgid = nil
            }
        }

        do {
            self.uploaded_t = try container.decode(Double.self, forKey: .uploaded_t)
        } catch {
            do {
                let intCode = try container.decode(Int.self, forKey: .uploaded_t)
                self.uploaded_t = Double(intCode)
            } catch {
                do {
                    let intCode = try container.decode(String.self, forKey: .uploaded_t)
                    self.uploaded_t = Double(intCode)
                } catch {
                    self.uploaded_t = nil
                }
            }
        }

        try super.init(from: decoder)
    }
    
}
