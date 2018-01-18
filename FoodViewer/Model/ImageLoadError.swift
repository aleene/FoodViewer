//
//  ImageLoadError.swift
//  FoodViewer
//
//  Created by arnaud on 17/01/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//
//  https://stackoverflow.com/questions/47372054/using-enums-to-design-error-types-in-swift

import Foundation

enum ImageLoadError: Error {
    case unsupportedTypeIdentifier(String)
    case baseError(Error)
    case noValidImage
    case noDataReceived
    case noValidUrl
    case noValidHttpResponseReceived
    case response(HTTPURLResponse)
    
    var description: String {
        switch self {
        case .unsupportedTypeIdentifier(let identifier):
            return identifier + " not supported"
        case .baseError(let error):
            return "Response error: " + error.localizedDescription
        case .noValidImage:
            return "No valid image available"
        case .noDataReceived:
            return "No data for image received"
        case .noValidUrl:
            return "NO valid url to retrieve image available"
        case .noValidHttpResponseReceived:
            return "No valid http response received"
        case .response(let response):
            return "Http response: \(response.statusCode)"
        }
    }
}
