//
//  PendingOperations.swift
//  FoodViewer
//
//  Created by arnaud on 25/07/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

class PendingOperations {
    lazy var uploadsInProgress: [String: Operation] = [:]
    lazy var uploadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Upload queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

}
