//
//  OFFRobotoff.swift
//  FoodViewer
//
//  Created by arnaud on 31/10/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

/**
Functions to interface with the Robotoff API.
*/
class OFFRobotoff {
       
// MARK: - constants
    
    private struct Constant {
        
        struct Divider {
            static let Slash = "/"
            static let Dot = "."
            static let Equal = "="
            static let QuestionMark = "?"
            static let Ampersand = "&"
        }
        
        struct URL {
            static let Scheme = "https://"
            static let Prefix = "robotoff"
            static let TopDomain = "org"
            static let ApiVersion = "api/v1/"
            static let Questions = "questions"
            static let Lang = "lang"
            static let Count = "count"
        }
    }
    // https://robotoff.openfoodfacts.org/api/v1/questions/3033490004743?lang=en&count=6"
    /*
    Retrieve the robotoff questions for a product
     Parameters:
     - barcode:
    - productType: the type of product (food, petfood, beauty, rest)
         - languageCode: the required languageCode of the result (default en)
    */
    private static func fetchQuestionsString(for barcode: BarcodeType?, with productType: ProductType, languageCode: String, count: Int?) -> String {
        var fetchUrlString = Constant.URL.Scheme
        fetchUrlString += Constant.URL.Prefix
        fetchUrlString += Constant.Divider.Dot
        // add the right server (works only for food products)
        fetchUrlString += productType.rawValue
        fetchUrlString += Constant.Divider.Dot
        fetchUrlString += Constant.URL.TopDomain
        fetchUrlString += Constant.Divider.Slash
        fetchUrlString += Constant.URL.ApiVersion
        fetchUrlString += "questions"
        if let validBarcode = barcode {
            fetchUrlString += Constant.Divider.Slash
            fetchUrlString += validBarcode.asString
        } else {
            fetchUrlString += Constant.Divider.Slash
            fetchUrlString += "random"
            fetchUrlString += Constant.Divider.Slash
        }
        //fetchUrlString += Constant.Divider.QuestionMark
        //fetchUrlString += Constant.URL.Lang
        //fetchUrlString += Constant.Divider.Equal
        //fetchUrlString += languageCode
        //if let validCount = count,
        //    validCount > 0  {
        //    fetchUrlString += Constant.Divider.QuestionMark
        //    fetchUrlString += Constant.URL.Count
         //   fetchUrlString += Constant.Divider.Equal
        //    fetchUrlString += "\(validCount)"
        //}
        return fetchUrlString
    }
    
// MARK: - public variables
    
    // The number of questions that must be retrieved
    public var count: Int?
    
    // The barcode of the product for which the questions must be retrieved
    public var barcode: BarcodeType?
    
// MARK: - intialisers
    
/** Initialise the questions to retrieve
- parameters:
     - barcode: the questions hould be limited to this barcode
     - count: the number of questions to retreive
*/
    init(barcode: BarcodeType?, count: Int?) {
        self.barcode = barcode
        self.count = count
    }
        
// MARK: - public functions
           
    /// Retrieve a new set of questions
    public func refresh() {
        switch robotoffQuestionsFetchStatus {
        // start the fetch if it is not yet loading
        case .initialized, .success:
            // reset the status
            robotoffQuestionsFetchStatus = .loading("\(barcode?.asString ?? "random")")
            fetch(barcode: barcode, localLanguageCode: languageCode, count: count)
        default:
            break
        }
    }
    
    // Remove a question from the question list
    public func remove(_ question: RobotoffQuestion) {
        switch robotoffQuestionsFetchStatus {
        case .success(var questions):
            guard let index = questions.lastIndex(where: ({ $0 == question }) ) else { return }
            questions.remove(at: index)
            robotoffQuestionsFetchStatus = .success(questions)
        default:
            break
        }
        return
    }

    /// The robotoff questions filtered for a specific type
    public func questions(for questionType: RobotoffQuestionType) -> [RobotoffQuestion] {
        var filteredQuestions: [RobotoffQuestion] = []
        for question in questions {
            if question.field == questionType {
                filteredQuestions.append(question)
            }
        }
        return filteredQuestions
    }


    /// Upload the answer to a question
    public func uploadAnswer(for question: RobotoffQuestion) {
        // loop over all operations needed to upload a product
        for (key, operation) in uploadRobotoffAnswer(question: question) {
            
            //1 - if the operation already exists do not add it again and move to the next operation
            if pendingOperations.uploadsInProgress[key] == nil {
                operation.completionBlock = {
                    if operation.isCancelled {
                        return
                    }
                    // the operation is finished, it can be removed from the uploads in progress
                    self.pendingOperations.uploadsInProgress.removeValue(forKey: key)
                }
                pendingOperations.uploadsInProgress[key] = operation
                pendingOperations.uploadQueue.addOperation(operation)
            }
        }
    }

// MARK: - private variables
    
    public var robotoffQuestionsFetchStatus: OFFRobotoffQuestionFetchStatus = .initialized

    private var productType: ProductType = .food
    
    // All question retrievals are linked to the current interface languageCode
    private let languageCode = Locale.interfaceLanguageCode
               
    private var questions: [RobotoffQuestion] {
        switch robotoffQuestionsFetchStatus {
        // start the fetch
        case .initialized:
            fetch(barcode: barcode, localLanguageCode: languageCode, count: count)
            robotoffQuestionsFetchStatus = .loading("\(barcode?.asString ?? "random")")
        case .success(let questions):
            return questions
        default:
            break
        }
        return []
    }
    
    private let pendingOperations = PendingOperations()

    private func uploadRobotoffAnswer(question: RobotoffQuestion) -> [String:Operation] {
        
        var operations: [String:Operation] = [:]

        operations[question.id!] = RobotoffUpdate(question: question) { (result: ResultType<OFFRobotoffUploadResultJson>) in
            switch result {
            case .success:
                DispatchQueue.main.async(execute: { () -> Void in

                })
                //self.remove(question)
            case .failure(let error as NSError):
                print("uploadRobotoffAnswer: ", error.localizedDescription)
                DispatchQueue.main.async(execute: { () -> Void in

                })
            }
        }
        
        return operations
    }
    /// Fetch the questions for a specific barcode
    private func fetch(barcode: BarcodeType?, localLanguageCode: String, count: Int?) {
        fetchRobotoffQuestionsJson(for: barcode, in: localLanguageCode, count: nil) { (completion: OFFRobotoffQuestionFetchStatus) in
            switch completion {
            case .success(let questions):
                var validQuestions: [RobotoffQuestion] = []
                for question in questions {
                    if let validBarcode = barcode,
                        question.barcode == validBarcode.asString {
                        validQuestions.append(question)
                    } else {
                        validQuestions.append(question)
                    }
                }
                self.robotoffQuestionsFetchStatus = .success(validQuestions)
            case .failed(let error):
                self.robotoffQuestionsFetchStatus = .failed(error)
            case .loading:
                self.robotoffQuestionsFetchStatus = .loading("")
            default:
                self.robotoffQuestionsFetchStatus = .failed("What was the error?")
            }
            DispatchQueue.main.async(execute: { () -> Void in
                NotificationCenter.default.post(name: .RobotoffQuestionsFetchStatusChanged, object: nil, userInfo: nil)
            })
        }
    }
    
    private func fetchRobotoffQuestionsJson(for barcode: BarcodeType?, in interfaceLanguageCode: String, count: Int?, completion: @escaping (OFFRobotoffQuestionFetchStatus) -> ()) {
        
        //DispatchQueue.main.async(execute: { () -> Void in
        //    UIApplication.shared.isNetworkActivityIndicatorVisible = true
        //})
        let string = OFFRobotoff.fetchQuestionsString(for: barcode, with: productType, languageCode: interfaceLanguageCode, count: count)
        let fetchUrl = URL(string: string )
        if let validURL = fetchUrl {
            let cache = Shared.dataCache
            cache.remove(URL:validURL)
            cache.fetch(URL: validURL).onSuccess { data in
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                do {
                    let questionsJson = try decoder.decode(OFFRobotoffQuestionJson.self, from: data)
                    if let questions = questionsJson.questions {
                        var newQuestions: [RobotoffQuestion] = []
                        for question in questions {
                            newQuestions.append(RobotoffQuestion.init(jsonQuestion: question))
                        }
                        completion(.success(newQuestions))
                    } else {
                        if questionsJson.status == "not found" {
                            completion(.questionNotAvailable(barcode?.asString ?? ""))
                        }
                    }
                } catch let error {
                    print("fetchRobotoffQuestionsJson: ", error.localizedDescription)
                    completion(.failed(barcode?.asString ?? error.localizedDescription))
                }
                //DispatchQueue.main.async(execute: { () -> Void in
                //    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                //})
                return
            }
            cache.fetch(URL: validURL).onFailure { error in
                print("fetchRobotoffQuestionsJson: ", error?.localizedDescription ?? "OFFRobotoff: no error in fetching json")
                completion(.failed(error?.localizedDescription ?? "No error description provided"))
            }
            //DispatchQueue.main.async(execute: { () -> Void in
            //    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            //})
        } else {
            completion(.failed(barcode?.asString ?? ""))
            //DispatchQueue.main.async(execute: { () -> Void in
            //    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            //})
            return
        }
    }
}
// Definition:
extension Notification.Name {
    static let RobotoffQuestionsFetchStatusChanged = Notification.Name("OFFRobotoff.Notification.RobotoffQuestionsFetchStatusChanged")
}
