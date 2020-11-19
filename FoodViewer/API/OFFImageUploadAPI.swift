//
//  OFFImageUploadAPI.swift
//  FoodViewer
//
//  Created by arnaud on 28/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

class OFFImageUploadAPI: Operation {
    
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
    
    internal struct Notification {
        static let BarcodeKey = "OFFImageUploadAPI.Notification.Barcode.Key"
        static let ProgressKey = "OFFImageUploadAPI.Notification.Progress.Key"
        static let ImageTypeCategoryKey = "OFFImageUploadAPI.Notification.ImageTypeCategory.Key"
        static let ImageIDKey = "OFFImageUploadAPI.Notification.ImageID.Key"
    }

    private var image: UIImage? = nil
    private var languageCode: String? = nil
    private var OFFServer: String? = nil
    private var imageTypeString: String? = nil
    private var barcodeString: String? = nil
    private var myCompletion: ( (OFFImageUploadResultJson?) -> () ) = { _ in  }
    
    // The dict specifies which language must be deselected
    // the image category is .identification, .nutrition or .ingredients
    // And naturally the product
    /**
Setup the image uploading
- parameters:
     - image: the image to be uploaded
     - languageCode: the languageCode of the image. This is ignored if the image is not assigned to front/ingredients/ nutrition/ packaging.
     - OFFServer: the product type as defined by the server string (openfoodfacts/ openpetfoodfacts/ openbeautyfacts/ openproductfacts).
     - imageTypeString: the assigned imagettype (front/ingredients/ nutrition/ packaging)
     - imageID: the id of the image as taken from the localProduct, used to distinghuish between uploaded images
     - barcodeString: the barcode string of the product
     - completion: the write result json
     */
    init(image: UIImage, languageCode: String, OFFServer: String, imageTypeCategory: ImageTypeCategory, barcodeString: String, completion: @escaping (OFFImageUploadResultJson?) -> ()) {
        self.image = image
        self.languageCode = languageCode
        self.OFFServer = OFFServer
        self.imageTypeString = imageTypeCategory.description
        self.imageID = imageTypeCategory.associatedString
        self.barcodeString = barcodeString
        self.myCompletion = completion
    }
    
    override func main() {
        super.main()
        
        // check if the required data has been setup.
        guard let validImage = image,
            let validImageTypeString = imageTypeString,
            let validBarCodeString = barcodeString,
            let validLanguageCode = languageCode,
            let validOFFServer = OFFServer else { return }
        
        // start the upload
        post(image: validImage,
             parameters: [OFFHttpPost.AddParameter.BarcodeKey: validBarCodeString,
                              OFFHttpPost.AddParameter.ImageField.Key:OFFHttpPost.idValue(for:validImageTypeString, in:validLanguageCode),
                              OFFHttpPost.AddParameter.UserId: OFFAccount().userId,
                              OFFHttpPost.AddParameter.Password: OFFAccount().password],
             imageType: validImageTypeString,
             url: OFFHttpPost.URL.SecurePrefix +
                    validOFFServer +
                    OFFHttpPost.URL.Domain +
                    OFFHttpPost.URL.AddPostFix,
             languageCode: validLanguageCode,
             completionHandler: myCompletion )
    }
    
    private var progress: Double? = nil {
        didSet {
            if let validProgress = progress,
                let validBarcodeString = barcodeString,
                let validImageTypeString = imageTypeString {
                DispatchQueue.main.async(execute: { () -> Void in
                let userInfo = [Notification.BarcodeKey: validBarcodeString as String,
                                Notification.ImageTypeCategoryKey: validImageTypeString as String,
                                Notification.ImageIDKey: self.imageID as String,
                                Notification.ProgressKey: "\(validProgress)" as String]
                NotificationCenter.default.post(name: .ImageUploadProgress, object: nil, userInfo: userInfo)
            })
            }
        }
    }
    
    // The id string of a generic image
    private var imageID: String = "not assigned"
    
    private func post(image: UIImage, parameters: Dictionary<String, String>, imageType: String, url: String, languageCode: String, completionHandler: @escaping (OFFImageUploadResultJson?) -> ()) {
        let urlString = URL(string: url)
        guard urlString != nil else { return }
        
        let ewImage = image.setOrientationToLeftUpCorner()
        
        guard let data = ewImage.pngData() else { return }
        
        let body:NSMutableString = NSMutableString();
        
        // parameters
        for (key, value) in parameters {
            body.appendFormat( Constants.TwoDash + HTTP.BoundaryValue + Constants.RN as NSString ) // "\(MPboundary)\r\n" as NSString)
            body.appendFormat( HTTP.ContentDisposition + HTTP.NameKey + Constants.EscapedQuote + key + Constants.EscapedQuote + Constants.RN + Constants.RN as NSString ) //"Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n" as NSString)
            body.appendFormat( value + Constants.RN  as NSString) // "\(value)\r\n" as NSString)
        }
        
        // image upload
        body.appendFormat( Constants.TwoDash + HTTP.BoundaryValue + Constants.RN as NSString ) //"%@\r\n",MPboundary)
        
        let string1 = HTTP.ContentDisposition
        let string2 = HTTP.NameKey + Constants.EscapedQuote + OFFHttpPost.imageName(for: imageType, in: languageCode) + Constants.EscapedQuote + Constants.SemiColonSpace
        let string3 = HTTP.FilenameKey + Constants.EscapedQuote + imageType + Constants.PNG + Constants.EscapedQuote + Constants.RN // "filename=\"\(imageType).png\"\r\n"
        // "Content-Disposition: form-data; name=\"imgupload_\(imageType)_\(languageCode)\"; filename=\"\(imageType).png\"\r\n"
        let string = string1 + string2 + string3 as NSString
        body.appendFormat(string)
        // print("string", string)
        
        body.appendFormat( HTTP.ContentTypeImage + Constants.RN + Constants.RN as NSString ) // "Content-Type: image/png\r\n\r\n")
        let end:String = Constants.RN + Constants.TwoDash + HTTP.BoundaryValue + Constants.TwoDash // "\r\n\(endMPboundary)"
        
        let myRequestData:NSMutableData = NSMutableData();
        myRequestData.append(body.data(using: String.Encoding.utf8.rawValue)!)
        myRequestData.append(data)
        myRequestData.append(end.data(using: String.Encoding.utf8)!)
        
        let content:String = HTTP.FormData + HTTP.BoundaryKey + HTTP.BoundaryValue // "multipart/form-data; boundary=\(TWITTERFON_FORM_BOUNDARY)"
        let request = NSMutableURLRequest(url: urlString!) //, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 10)
        request.httpMethod = HTTP.Post
        request.setValue(content, forHTTPHeaderField: HTTP.ContentType)
        request.setValue("\(myRequestData.length)", forHTTPHeaderField: HTTP.ContentLength)
        request.httpBody = myRequestData as Data
        DispatchQueue.main.async(execute: { () -> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        })
        
        let configuration = URLSessionConfiguration.default
        let mainQueue = OperationQueue.main
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: mainQueue)

        let task = session.uploadTask(with: request as URLRequest, from: myRequestData as Data, completionHandler: {
            data, response, error in
            if error != nil {
                print(error as Any)
                return
            }
            guard let data = data else {
                completionHandler(nil)
                return
            }
            completionHandler(data.resultForImageUpload())
        })
        task.resume()
    }

}

extension OFFImageUploadAPI: URLSessionTaskDelegate {
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // the task finished
        if let err = error {
            print("OFFImageUploadAPI.urlSession error: \(err.localizedDescription)")
        } else {
            print("OFFImageUploadAPI.urlSession: The upload was successful.")
            //self.session?.finishTasksAndInvalidate()
        }
    }

    private func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        //print("did receive response")
        //print(response)
        completionHandler(URLSession.ResponseDisposition.allow)
    }  // end func

     func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        self.progress = Double(Float(totalBytesSent) / Float(totalBytesExpectedToSend))
        //print("progress: ", progress)
    }  // end func


     func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }


}
extension Data {
    fileprivate func resultForImageUpload() -> OFFImageUploadResultJson? {
        do {
            return try JSONDecoder().decode(OFFImageUploadResultJson.self, from:self)
        } catch(let error) {
            print("resultForImageUpload ", error)
            return nil
        }
    }
}


extension Notification.Name {
    static let ImageUploadProgress = Notification.Name("OFFImageUploadAPI.Notification.ImageUploadProgress")
}
