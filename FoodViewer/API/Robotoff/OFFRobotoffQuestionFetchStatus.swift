//
//  OFFRobotoffQuestionFetchStatus.swift
//  FoodViewer
//
//  Created by arnaud on 19/10/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation

/// The OFFRobotoffQuestionFetchStatus describes the  retrieval status  of a robotoff question retrieval call
enum OFFRobotoffQuestionFetchStatus {
    // nothing is known at the moment
    case initialized
    // the barcode is set, but no load is initialised
    case notLoaded(String) // (barcodeString)
    case failed(String)
    // loading indicates that it is trying to load the product
    case loading(String) // The string indicates the barcodeString
    // the product has been loaded successfully and can be set.
    case success([RobotoffQuestion])
    // the product is not available on the off servers
    case questionNotAvailable(String) // (barcodeString)
}
