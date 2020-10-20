//
//  OFFRobotoffAnswerAPI.swift
//  FoodViewer
//
//  Created by arnaud on 20/10/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation

class OFFRobotoffAnswerAPI: Operation {
    
    var URLString: String? = nil
    private var myCompletion: ( (ResultType<OFFRobotoffUploadResultJson>) -> () ) = { _ in  }
    
    init(URLString: String?, completion: @escaping ((ResultType<OFFRobotoffUploadResultJson>) -> () )) {
        self.URLString = URLString
        self.myCompletion = completion
    }
    
    override func main() {
        super.main()
        if let validURLString = self.URLString,
            let url = URL(string: validURLString) {
            do {
                let request = NSMutableURLRequest(url: url)
                request.httpMethod = "Post"
                let loginString = OFFAccount().userId
                    + ":"
                    + OFFAccount().password
                let loginData = loginString.data(using: String.Encoding.utf8)!
                let base64LoginString = loginData.base64EncodedString()
                request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
                let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
                    data, response, error in
                    if error != nil {
                        print(error as Any)
                        //self.myCompletion(.failure(error))
                    }
                    if let validData = data?.resultForRobotoffUpload() {
                        self.myCompletion(.success(validData))
                    } else {
                        let error = NSError.init(domain: "FoodViewer",
                                               code: 11,
                                               userInfo:["Class": "OFFRobotoffAnswerAPI",
                                                         "Function": "update(urlString: String, completionHandler: @escaping (ResultType<OFFRobotoffUploadResultJson>) -> () )",
                                                         "Reason": "No validData received"])
                        self.myCompletion(.failure(error))
                    }
                })
                task.resume()

            }
        } else {
            let error = NSError.init(domain: "FoodViewer",
                                     code: 12,
                                     userInfo:["Class": "OFFRobotoffAnswerAPI",
                                               "Function": "update(urlString: String, completionHandler: @escaping (ResultType<OFFRobotoffUploadResultJson>) -> () )",
                                               "Reason": "No valid url provided"])
            myCompletion(.failure(error))
        }
    }
}

extension Data {
    
    fileprivate func resultForRobotoffUpload() -> OFFRobotoffUploadResultJson? {
        do {
            let result = try JSONDecoder().decode(OFFRobotoffUploadResultJson.self, from:self)
            return result
        } catch(let error) {
            print("OFFRobotoffAnswerAPI: ", error)
            return nil
        }
    }

}
