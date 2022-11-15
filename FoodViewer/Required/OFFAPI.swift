 //
//  OpenFoodFactsRequest.swift
//  FoodViewer
//
//  Created by arnaud on 03/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

public class OFFAPI {
    
/// Generic function to decode a json struct
    public static func decode<T:Decodable>(data: Data?, type: T.Type, completion: @escaping (_ result: Result<T, FSNMError>) -> Void)  {
        do {
            if let responseData = data {
                if let validString = String(data: responseData, encoding: .utf8) {
                    print(validString)
                }

                let decoded = try JSONDecoder().decode(type.self, from: responseData)
                completion(Result.success(decoded))
                return
            } else {
                completion(Result.failure(FSNMError.dataNil))
                return
            }
        } catch {
            completion(Result.failure(FSNMError.parsing))
            return
        }
    }

/// Generic function to decode a json array
    public static func decodeArray<T:Decodable>(data: Data?, type: T.Type, completion: @escaping (_ result: Result<[T], FSNMError>) -> Void)  {
        do {
            if let responseData = data {
                let decoded = try JSONDecoder().decode([T].self, from: responseData)
                completion(Result.success(decoded))
                return
            } else {
                completion(Result.failure(FSNMError.dataNil))
                return
            }
        } catch {
            completion(Result.failure(FSNMError.parsing))
        }
    }

}
