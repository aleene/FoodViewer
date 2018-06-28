//
//  DownloadTask.swift
//  FoodViewer
//
//  Created by arnaud on 12/01/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

protocol DownloadTask {
    
    var completionHandler: ResultType<Data>.ImaginaryCompletion? { get set }
    var progressHandler: ((Progress) -> Void)? { get set }
    var responseHandler: ((URLResponse) -> Void)? { get set }

    func resume()
    func suspend()
    func cancel()
}
