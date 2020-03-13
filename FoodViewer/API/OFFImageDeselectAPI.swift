//
//  OFFImageDeselectAPI.swift
//  FoodViewer
//
//  Created by arnaud on 27/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

class OFFImageDeselectAPI: Operation {
    
    private struct Constants {
        static let TwoDash = "--"
        static let EscapedQuote = "\""
        static let RN = "\r\n"
        static let ColonSpace = ": "
        static let PNG = ".png"
        static let SemiColonSpace = "; "
        struct ImageType {
            static let Front = "front"
            static let Ingredients = "ingredients"
            static let Nutrition = "nutrition"
        }
    }
    
    private struct HTTP {
        static let BoundaryValue = "FoodViewer"
        static let ContentType = "Content-Type"
        static let ContentTypeImage = "Content-Type: image/png"
        static let ContentLength = "Content-Length"
        static let Post = "POST"
        static let FormData = "multipart/form-data; "
        static let ContentDisposition = "Content-Disposition: form-data; "
        static let PNG = "image/png"
        static let BoundaryKey = "boundary="
        static let FilenameKey = "filename="
        static let NameKey = "name="
    }
    
    private var languageCode: String? = nil
    private var OFFServer: String? = nil
    private var imageString: String? = nil
    private var barcodeString: String? = nil
    private var myCompletion: ( (OFFImageDeselectResultJson?) -> () ) = { _ in  }


    // The dict specifies which language must be deselected
    // the image category is .identification, .nutrition or .ingredients
    // And naturally the product
    init(_ languageCode: String, OFFServer: String, of imageString: String, for barcodeString: String, completion: @escaping (OFFImageDeselectResultJson?) -> ()) {
        self.languageCode = languageCode
        self.OFFServer = OFFServer
        self.imageString = imageString
        self.barcodeString = barcodeString
        self.myCompletion = completion
    }
    
    override func main() {
        super.main()
        guard let validLanguageCode = languageCode,
            let validImageString = imageString,
            let validOFFServer = OFFServer,
            let validBarcodeString = barcodeString else { return }
        
        switch validImageString {
        case Constants.ImageType.Front,
            Constants.ImageType.Ingredients,
            Constants.ImageType.Nutrition:
            postDeselect(parameters: [OFFHttpPost.UnselectParameter.CodeKey:validBarcodeString,
                                        OFFHttpPost.UnselectParameter.IdKey:OFFHttpPost.idValue(for:validImageString, in:validLanguageCode)],
                        url: OFFHttpPost.URL.SecurePrefix +
                            validOFFServer +
                            OFFHttpPost.URL.Domain +
                            OFFHttpPost.URL.UnselectPostFix,
                           completionHandler: myCompletion
            )
        default:
            break
        }
    }

    private func postDeselect(parameters : Dictionary<String, String>, url : String, completionHandler: @escaping (OFFImageDeselectResultJson?) -> ()) {
        let urlString = URL(string: url)
        guard urlString != nil else { return }
        
        let body:NSMutableString = NSMutableString();
        
        // parameters
        for (key, value) in parameters {
            body.appendFormat(Constants.TwoDash + HTTP.BoundaryValue + Constants.RN as NSString)
            body.appendFormat(
                HTTP.ContentDisposition +
                    HTTP.NameKey + Constants.EscapedQuote + "\(key)" + Constants.EscapedQuote +
                    Constants.RN + Constants.RN as NSString
            )
            body.appendFormat("\(value)" + Constants.RN as NSString)
        }
        
        let end:String = Constants.RN + Constants.TwoDash + HTTP.BoundaryValue + Constants.TwoDash
        
        let myRequestData:NSMutableData = NSMutableData();
        myRequestData.append(body.data(using: String.Encoding.utf8.rawValue)!)
        myRequestData.append(end.data(using: String.Encoding.utf8)!)
        
        let content = HTTP.FormData + HTTP.BoundaryKey + HTTP.BoundaryValue
        let request = NSMutableURLRequest(url: urlString!) //, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 10)
        request.httpMethod = HTTP.Post
        request.setValue(content, forHTTPHeaderField: HTTP.ContentType)
        request.setValue("\(myRequestData.length)", forHTTPHeaderField: HTTP.ContentLength)
        request.httpBody = myRequestData as Data
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            data, response, error in
            if error != nil {
                print(error as Any)
                return
            }
            guard let data = data else {
                completionHandler(nil)
                return
            }
            let result = data.resultForImageDeselect()
            completionHandler(result)
        })
        task.resume()
    }
    
    private func doNothing() {
    
    }

}

extension Data {
    fileprivate func resultForImageDeselect() -> OFFImageDeselectResultJson? {
        do {
            return try JSONDecoder().decode(OFFImageDeselectResultJson.self, from:self)
        } catch(let error) {
            print(error)
            return nil
        }
    }
}

