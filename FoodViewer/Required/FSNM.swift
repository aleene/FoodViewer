//
//  FSNMAPI.swift
//  OFFFolksonomy
//
//  Created by Arnaud Leene on 21/10/2022.
//

import Foundation

struct FSNM {

/** all possible FSNM API's
 */
    enum APIs {
        case auth
        case delete
        case hello
        case keys
        case ping
        case post
        case products
        case productsStats
        case productTagVersions
        case put
        case tags
        
        var path: String {
            switch self {
            case .auth: return "/auth"
            case .delete: return "/product"  // needs to be extended with /<barcode> /<key> ?version=<version>
            case .hello: return "/"
            case .keys: return "/key"
            case .ping: return "/ping"
            case .post: return "/product"
            case .products: return "/products"
            case .productsStats: return "/products/stats"
            case .productTagVersions: return "/product" // needs to be extended with /<barcode>/<key>/versions
            case .put: return "/product" // needs to be extended with body and headers
            case .tags: return "/product" // needs to be extended with /<barcode>
            }
        }
    }

/**
    Some API's (ProductStats) can return a validation error with response code 401.
*/
    public struct Error401: Codable {
        var detail: String?
    }
    
    public struct Detail: Codable {
        var detail: String?
    }

/**
 Some API's (ProductStats) can return a validation error with response code 422.
 */
    public struct ValidationError: Codable {
        var detail: [ValidationErrorDetail] = []
    }
    
    public struct ValidationErrorDetail: Codable {
        var loc: [String] = []
        var msg: String?
        var type: String?
    }
}

extension URLSession {
   
/// An alternative name URLSession to make clear all usage must be related to FSNM
    typealias FSNMSession = URLSession

/**
Generic function for multiple FSNM API's. Most of these API's can return two succesfull response codes. It is assumed that all successful calls that return the data have response code 200 and the successful calls that return an error have response code 422.
*/
    func fetchFSNMArray<T:Decodable> (request: HTTPRequest, response: T.Type, completion: @escaping (_ result: ( Result<[T], FSNMError> ) ) -> Void) {
        
        load(request: request) { result in
            switch result {
            case .success(let response):
                //print("fetchArray: response: \(response.status.rawValue)")

                if response.status.rawValue == 200 {
                    OFFAPI.decodeArray(data: response.body, type: T.self) { result in
                        switch result {
                        case .success(let array):
                            completion( .success(array) )
                            return
                        case .failure:
                            if let data = response.body {
                                if let validString = String(data: data, encoding: .utf8) {
                                    if !validString.isEmpty {
                                        if validString == "null" {
                                            completion( (.failure(FSNMError.null) ))
                                        } else {
                                            completion( (.failure(FSNMError.dataType)) )
                                        }
                                    } else {
                                        completion( (.failure(FSNMError.dataType) ))
                                    }
                                }
                            }
                        }
                    }
                } else if response.status.rawValue == 422 {
                    OFFAPI.decode(data: response.body, type: FSNM.ValidationError.self) { result in
                        switch result {
                        case .success(let validationError):
                            if let validValidationError = validationError as? T {
                                completion( .failure(FSNMError.validationError(validValidationError)) )
                                return
                            } else {
                                completion( .failure(FSNMError.dataType) )
                                return
                            }
                        case .failure:
                            if let data = response.body {
                                if let validString = String(data: data, encoding: .utf8) {
                                    if !validString.isEmpty {
                                        if validString == "null" {
                                            completion( .failure(FSNMError.null) )
                                        } else {
                                            completion( .failure(FSNMError.dataType) )
                                        }
                                    } else {
                                        completion( (.failure(FSNMError.dataType) ))
                                    }
                                }
                            }
                        }
                    }
                } else if response.status.rawValue == 404 {
                    // the expected one dit not work, so try another
                    OFFAPI.decode(data: response.body, type: FSNM.Detail.self) { result in
                        switch result {
                        case .success(let detail):
                            completion( .failure(FSNMError.detail(detail)) )
                            return
                        default:
                            completion( .failure(FSNMError.dataType) )
                            return
                        }
                    }
                } else {
                    //print(response.status.rawValue)

                    if let data = response.body {
                        if let str = String(data: data, encoding: .utf8) {
                            completion( .failure(FSNMError.analyse(str)) )
                            return
                        } else {
                            completion( .failure(FSNMError.dataNil) )
                            return
                        }
                    }
                }
            case .failure(_):
                // the original response failed
                print (result.response.debugDescription)
                completion( .failure(FSNMError.connectionFailure) )
                return
            }
        }

    }

/**
Generic function for multiple FSNM API's. Most of these API's can return two succesfull response codes. It is assumed that all successful calls that return the data have response code 200 with a string as response and the successful calls that return an error have response code 422.
*/
    func fetchFSNMString (request: HTTPRequest, completion: @escaping (_ result: (Result<String, FSNMError>) ) -> Void) {
                    
        load(request: request) { result in
            switch result {
            case .success(let response):
                if response.status.rawValue == 200 {
                    //print("fetchString: response: \(response.status.rawValue)")
                    if let data = response.body {
                        let str = String(data: data, encoding: .utf8)
                        // should check what T1 is
                        if let validString = str {
                            if !validString.isEmpty {
                                if validString == "null" {
                                    completion( (.failure(FSNMError.null) ))
                                } else {
                                    completion( (Result.success(validString)) )
                                }
                            } else {
                                completion( (.failure(FSNMError.dataType) ))
                            }
                        }
                    }
                } else if response.status.rawValue == 422 {
                    //print("fetchString: response: \(response.status.rawValue)")
                    OFFAPI.decode(data: response.body, type: FSNM.ValidationError.self) { result in
                        switch result {
                        case .success(let validationError):
                            completion( (.failure(FSNMError.validationError(validationError))) )
                            return
                        case .failure:
                            // the expected one did not work, so try another
                            OFFAPI.decode(data: response.body, type: FSNM.Detail.self) { result in
                                switch result {
                                case .success(let detail):
                                    completion( .failure(FSNMError.detail(detail)) )
                                    return
                                case .failure:
                                    if let data = response.body {
                                        if let validString = String(data: data, encoding: .utf8) {
                                            if !validString.isEmpty {
                                                if validString == "null" {
                                                    completion( (.failure(FSNMError.null) ))
                                                } else {
                                                    completion( (Result.success(validString)) )
                                                }
                                            } else {
                                                completion( (.failure(FSNMError.dataType) ))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    if let data = response.body {
                        //print("fetchString: response: \(response.status.rawValue)")
                        if let str = String(data: data, encoding: .utf8) {
                            completion( (.failure(FSNMError.analyse(str))) )
                            return
                        } else {
                            completion( (.failure(FSNMError.dataNil)) )
                            return
                        }
                    }
                }
            case .failure(_):
                // the original response failed
                print (result.response.debugDescription)
                completion( (.failure(FSNMError.connectionFailure)) )
                return
            }
        }

    }
    
/// Used for responses FSNM.Hello and FSNM.Ping
    public func fetch<T>(request: HTTPRequest, responses: [Int : T.Type], completion: @escaping (Result<T, FSNMError>) -> Void) where T : Decodable {
        
        load(request: request) { result in
            switch result {
            case .success(let response):
                if let responsetype = responses[response.status.rawValue] {
                    OFFAPI.decode(data: response.body, type: responsetype) { result in
                        completion(result)
                        return
                    }
                } else if response.status.rawValue == 404 {
                    // the expected one did not work, so try another
                    OFFAPI.decode(data: response.body, type: FSNM.Detail.self) { result in
                        switch result {
                        case .success(let detail):
                            completion( .failure(FSNMError.detail(detail)) )
                            return
                        default:
                            completion( .failure(FSNMError.dataType) )
                            return
                        }
                    }
                } else {
                    if let data = response.body {
                        if let str = String(data: data, encoding: .utf8) {
                            completion( .failure(FSNMError.analyse(str)) )
                            return
                        } else {
                            completion(.failure( FSNMError.dataType) )
                            return
                        }
                    } else {
                        completion(.failure( FSNMError.noBody) )
                        return
                    // unsupported response type
                    }
                }
            case .failure(_):
                // the original response failed
                //print (result.response.debugDescription)
                completion( .failure( FSNMError.connectionFailure) )
                return
            }
        }
    }

}

extension HTTPRequest {
    
/**
Init for all producttypes supported by OFF. This will setup the correct host and path of the API URL
 
 - Parameters:
    - productType: one of the productTypes (.food, .beauty, .petFood, .product);
    - api: the api required (i.e. .auth, .ping, etc)
*/
    init(for productType: OFFProductType, for api: FSNM.APIs) {
        self.init()
        self.host = "api.folksonomy." + productType.host + ".org"
        self.path = api.path
    }
    
/**
 Init for the food folksonomy API. This will setup the correct host and path of the API URL
  
- Parameters:
 - api: the api required (i.e. .auth, .ping, etc)
 */
    init(api: FSNM.APIs) {
        self.init(for: .food, for: api)
        self.path = api.path
    }
    
/**
Init for the food folksonomy API. This will setup the correct host and path of the API URL and  a  query
- Parameters:
 - api: the api required (i.e. .auth, .ping, etc).
 - key: the key part of the query, i.e. the tag that must be searched for.
*/
    init(api: FSNM.APIs, for product: String?, with key: String?, and value: String?, by owner: String?, having token: String?) {
        self.init(api: api)
        switch api {
        case .keys:
            if owner != nil {
                var queryItems: [URLQueryItem] = []
                if owner != nil {
                    queryItems.append(URLQueryItem(name: "owner", value: owner))
                }
                self.queryItems = queryItems
            }
        // https://api.folksonomy.openfoodfacts.org/products/stats?k=ANEXISTINGKEY&value=ANEXISTINGVALUE
        case .products, .productsStats:
            // also add the Authorization token header
            if owner != nil,
               let validToken = token {
                self.headers["Authorization"] = "Bearer \(validToken)"
            }
            // Check if any query element is there. Otherwise an empty ? will be added.
            if key != nil || value != nil || owner != nil {
                var queryItems: [URLQueryItem] = []
               if key != nil {
                   queryItems.append(URLQueryItem(name: "k", value: key))
               }
                if value != nil {
                    queryItems.append(URLQueryItem(name: "v", value: value))
                }
                if owner != nil {
                    queryItems.append(URLQueryItem(name: "owner", value: owner))
                }
                self.queryItems = queryItems
            }
        case .productTagVersions:
            if let validProduct = product,
               let validKey = key {
                self.path = api.path + "/" + "\(validProduct)" + "/" + "\(validKey)" + "/versions"
                // Check if any query element is there. Otherwise an empty ? will be added.
                if owner != nil {
                    var queryItems: [URLQueryItem] = []
                    if owner != nil {
                        queryItems.append(URLQueryItem(name: "owner", value: owner))
                    }
                    self.queryItems = queryItems
                }
            }
        case .tags:
            if let validProduct = product  {
                self.path = api.path + "/" + "\(validProduct)"
                // Check if any query element is there. Otherwise an empty ? will be added.
                if owner != nil {
                    var queryItems: [URLQueryItem] = []
                    if owner != nil {
                        queryItems.append(URLQueryItem(name: "owner", value: owner))
                    }
                    self.queryItems = queryItems
                }
            }

        default:
            print("HTTPRequest: this API does not support a query.")
        }
    }
    
    init(api: FSNM.APIs, for tag: FSNM.Tag, having token: String?) {
        self.init(api: api)
        switch api {
        case .delete:
            if let validProduct = tag.product,
               let validTag = tag.k,
               let validVersion = tag.version {
                self.method = .delete
                self.path = api.path + "/" + "\(validProduct)" + "/" + "\(validTag)"
                var queryItems: [URLQueryItem] = []
                queryItems.append(URLQueryItem(name: "version", value: "\(validVersion)" ) )
                self.queryItems = queryItems

                // add the Authorization token header
                if tag.editor != nil,
                   let validToken = token {
                    self.headers["Authorization"] = "Bearer \(validToken)"
                }
                self.headers["Accept"] = "application/json"
            } else {
                print("No valid product")
            }
        case .post:
            self.method = .post
            // add the Authorization token header
            if tag.editor != nil,
               let validToken = token {
                self.headers["Authorization"] = "Bearer \(validToken)"
            }
            self.headers["accept"] = "application/json"
            self.body = JSONBody(tag)
        case .put:
            self.method = .put
            // add the Authorization token header
            if tag.editor != nil,
               let validToken = token {
                self.headers["Authorization"] = "Bearer \(validToken)"
            }
            self.headers["accept"] = "application/json"
            self.body = JSONBody(tag)

        default:
            print("HTTPRequest:init(api:for:having:) - not a correct api)")
        }

    }
    
}

// The specific errors that can be produced by the server
public enum FSNMError: Error {
    case network
    case parsing
    case request
    case connectionFailure
    case dataNil
    case dataType
    case detail(Any) // if a 404 Detail struct is received
    case authenticationRequired
    case methodNotAllowed
    case noBody
    case notFound
    case null
    case unsupportedSuccessResponseType
    case validationError(Any)
    
    
    static func analyse(_ message: String) -> FSNMError {
        if message.contains("Not Found") {
            return .connectionFailure
        } else if message.contains("Method Not Allowed") {
            return .methodNotAllowed
        } else if message.contains("Authentication required") {
            return .authenticationRequired
        } else {
            return .unsupportedSuccessResponseType
        }
    }
    public var description: String {
        switch self {
        case .network:
            return ""
        case .parsing:
            return ""
        case .request:
            return ""
        case .authenticationRequired:
            return "FSNMError: Authentication Required. Log in before using this function"
        case .connectionFailure:
            return "FSNMError: Not able to connect to the Folksonomy server"
        case .dataNil:
            return ""
        case .dataType:
            return "FSNMError: unexpected datatype"
        case .detail(let detail):
            if let validDetail = detail as? FSNM.Detail,
               let valid = validDetail.detail {
                    return valid
            } else {
                return "FSNMError: Wrong detail struct or nil value"
            }
        case .methodNotAllowed:
            return "Error: Method Not Allowed, probably a missing parameter"
        case .noBody:
            return ""
        case .notFound:
            return "Error: API not found, probably a typo in the path"
        case .null:
            return" FSNMError: null - probably a non-existing key"
        case .unsupportedSuccessResponseType:
            return ""
        case .validationError(let detail):
            if let validationError = detail as? FSNM.ValidationError {
                if !validationError.detail.isEmpty {
                    var errorMessage = ""
                    for item in validationError.detail {
                        errorMessage += item.msg ?? "FSNMError: message nil"
                        errorMessage += "; "
                    }
                    return errorMessage
                } else {
                    return "FSNMError: No error received"
                }
            } else {
                return "FSNMError: Not a validation error"
            }
        }
    }
}
