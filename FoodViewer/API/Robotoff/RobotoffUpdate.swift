//
//  RobotoffUpdate.swift
//  FoodViewer
//
//  Created by arnaud on 20/10/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation

class RobotoffUpdate: OFFRobotoffAnswerAPI {
    
    private var question: RobotoffQuestion? = nil
    private var productUpdateCompletion: ((ResultType<OFFRobotoffUploadResultJson>) -> () ) = { _ in }
    
    init(question: RobotoffQuestion, completion: @escaping (ResultType<OFFRobotoffUploadResultJson>) -> () ) {
        self.question = question
        super.init(URLString: nil, completion: {
            ( myCompletionHandler: ResultType<OFFRobotoffUploadResultJson> ) in
            switch myCompletionHandler {
            case .success(let json):
                if let validStatus = json.status {
                    if validStatus == "updated"
                    || validStatus == "saved" {
                        return completion (.success(json))
                    } else if validStatus == "error_already_annotated" {
                        let error = NSError.init(domain: "FoodViewer",
                                                    code: 13,
                                                    userInfo:["Class": "RobotoffUpdate",
                                                            "Function": "update(question: RobotoffQuestion, completion: @escaping (ResultType<OFFRobotoffUploadResultJson>) -> () )",
                                                            "Reason": "statusCode: Was already notated"])
                            return completion(.failure(error))
                    } else {
                        let error = NSError.init(domain: "FoodViewer",
                                                 code: 14,
                                                 userInfo:["Class": "RobotoffUpdate",
                                                           "Function": "update(question: RobotoffQuestion, completion: @escaping (ResultType<OFFRobotoffUploadResultJson>) -> () )",
                                                           "Reason": "Unrecognized status_code received"])
                        return completion(.failure(error))
                    }
                }
                let error = NSError.init(domain: "FoodViewer",
                                         code: 15,
                                         userInfo:["Class": "RobotoffUpdate",
                                                   "Function": "update(question: RobotoffQuestion, completion: @escaping (ResultType<OFFRobotoffUploadResultJson>) -> () )",
                                                   "Reason": "no valid status_code received"])
                return completion(.failure(error))
                
            case .failure(let error):
                return completion (.failure(error))
            }
        })
    }
    
    /*
    Taken from the openfoodfacts ios app:
    
    func postRobotoffAnswer(forInsightId insightId: String, withAnnotation: Int, onDone: @escaping () -> Void) {
        let url = Endpoint.robotoff + "/api/v1/insights/annotate"

        guard let credentials = CredentialsController.shared.getCredentials() else { return }

        let credentialData = "\(credentials.username):\(credentials.password)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
        let base64Credentials = credentialData.base64EncodedString()

        Alamofire.request(url, method: .post, parameters: [
            "insight_id": insightId,
            "annotation": withAnnotation,
            "update": 1
        ], headers: ["Authorization": "Basic \(base64Credentials)"]).response { (response: DefaultDataResponse) in
            log.debug("Answer from post to robotoff: \(response)")
            onDone()
        }
    }

    */

    override func main() {
        guard let validQuestion = question else { return }
        guard let validInsight = validQuestion.id else { return }
        guard let validResponse = validQuestion.response else { return }
        
        var urlString = OFFWriteAPI.SecureHttp
        urlString += OFFWriteAPI.Robotoff.Robotoff
        urlString += OFFWriteAPI.Robotoff.Annotate
        urlString += OFFWriteAPI.Questionmark

        urlString += OFFWriteAPI.Robotoff.Insight
        urlString += OFFWriteAPI.Equal
        urlString += validInsight

        urlString += OFFWriteAPI.Delimiter
        urlString += OFFWriteAPI.Robotoff.Annotation
        urlString += OFFWriteAPI.Equal
        urlString += "\(validResponse.rawValue)"

        urlString += OFFWriteAPI.Delimiter
        urlString += OFFWriteAPI.Robotoff.Update
        urlString += OFFWriteAPI.Equal
        urlString += "1"
        
        self.URLString = urlString
        super.main()
        return
    }

}
