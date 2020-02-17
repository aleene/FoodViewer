//
//  OFFProductUpdateAPI.swift
//  FoodViewer
//
//  Created by arnaud on 28/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

class OFFProductUpdateAPI: Operation {
    
    var URLString: String? = nil
    private var myCompletion: ( (ResultType<OFFProductUploadResultJson>) -> () ) = { _ in  }
    
    init(URLString: String?, completion: @escaping ((ResultType<OFFProductUploadResultJson>) -> () )) {
        self.URLString = URLString
        self.myCompletion = completion
    }
    
    override func main() {
        super.main()
        if let validURLString = self.URLString,
            let url = URL(string: validURLString) {
            do {
                let data = try Data( contentsOf: url, options: NSData.ReadingOptions.mappedIfSafe )
                if let validData = data.resultForProductUpload() {
                    myCompletion(.success(validData))
                } else {
                    let error = NSError.init(domain: "FoodViewer",
                                           code: 11,
                                           userInfo:["Class": "OFFProductUpdateAPI",
                                                     "Function": "update(urlString: String, completionHandler: @escaping (ResultType<OFFProductUploadResultJson>) -> () )",
                                                     "Reason": "No validData received"])
                    myCompletion(.failure(error))
                }
            } catch let error as NSError {
                print(error);
                // NSCocoaErrorDomain Code=256 if the server can not be reached
                myCompletion(.failure(error))
            }
        } else {
            let error = NSError.init(domain: "FoodViewer",
                                     code: 12,
                                     userInfo:["Class": "OFFProductUpdateAPI",
                                               "Function": "update(urlString: String, completionHandler: @escaping (ResultType<OFFProductUploadResultJson>) -> () )",
                                               "Reason": "No valid url provided"])
            myCompletion(.failure(error))
        }
    }
}

extension Data {
    
    fileprivate func resultForProductUpload() -> OFFProductUploadResultJson? {
        do {
            let result = try JSONDecoder().decode(OFFProductUploadResultJson.self, from:self)
            return result
        } catch(let error) {
            print("OFFProductUpdateAPI: ", error)
            return nil
        }
    }

}
