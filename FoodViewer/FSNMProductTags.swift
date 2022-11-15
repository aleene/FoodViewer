//
//  OFFFolksonomyGetProductJson.swift
//  OFFFolksonomy
//
//  Created by Arnaud Leene on 13/10/2022.
//
import Foundation

extension FSNM {

    public struct Tag: Codable, Identifiable {
        var product: String?
        var k: String?
        var v: String?
        var owner: String?
        var version: Int?
        var editor: String?
        var last_edit: String?
        var comment: String?
    
        // required for protocol Identifiable
        public var id: String { last_edit! }
    }

}

extension URLSession {
    
/**
Retrieves all tags for a product.
         
- parameters:
    - product: the barcode of the product
    - k: the key of the tag
    - v : the value of the tag
    - owner: the owner of the tag
    - version: the tag version
    - editor: the tag editor
    - last_edit: the last edit date
    - comment: the tag comment
         
- returns:
A completion block with a Result enum (success or failure). The associated value for success is an array of **FSNM.Tag** struct and for the failure an Error. The **FSNM.Tag** struct has the variables: **product** (String), the barcode of the product; **k**(String) the key of the tag; **v** (String) the value of the tag; **owner** (string) the owner of the tag; **version** (Int) the tag version; **editor** (String) the tag editor; **last_edit**: (String) the last edit date; **comment** (String) the tag comment.
*/
    func FSNMtags(with barcode: OFFBarcode, and key: String?, completion: @escaping (_ result: Result<[FSNM.Tag], FSNMError> ) -> Void) {
        let request = HTTPRequest(api: .tags, for: barcode.barcode, with: key, and: nil, by: nil, having: nil)
        
        fetchFSNMArray(request: request, response: FSNM.Tag.self) { result in
            completion(result)
            return
        }
    }
}
