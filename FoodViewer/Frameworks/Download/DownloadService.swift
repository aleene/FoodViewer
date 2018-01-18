//
//  DownloadService.swift
//  FoodViewer
//
//  Created by arnaud on 12/01/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//
// https://stackoverflow.com/questions/30543806/get-progress-from-datataskwithurl-in-swift

import Foundation

final class DownloadService: NSObject {
    
    private var session: URLSession!
    private var downloadTasks = [GenericDownloadTask]()
    
    public static let shared = DownloadService()
    
    private override init() {
        super.init()
        let configuration = URLSessionConfiguration.default
        session = URLSession(configuration: configuration,
                             delegate: self, delegateQueue: nil)
    }
    
    func download(request: URLRequest) -> DownloadTask {
        let task = session.dataTask(with: request)
        let downloadTask = GenericDownloadTask.init(task: task)
        downloadTasks.append(downloadTask)
        return downloadTask
    }
}


extension DownloadService: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        guard let task = downloadTasks.first(where: { $0.task == dataTask }) else {
            completionHandler(.cancel)
            return
        }
        task.responseHandler?(response)
        task.expectedContentLength = response.expectedContentLength
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let task = downloadTasks.first(where: { $0.task == dataTask }) else {
            return
        }
        task.buffer.append(data)
        let progress = Progress(totalUnitCount: task.expectedContentLength)
        progress.completedUnitCount = Int64(task.buffer.count)
        task.progressHandler?(progress)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let index = downloadTasks.index(where: { $0.task == task }) else {
            return
        }
        let task = downloadTasks.remove(at: index)
        DispatchQueue.main.async {
            if let validError = error {
                task.completionHandler?(.failure(validError))
            } else {
                task.completionHandler?(.success(task.buffer))
            }
        }
    }
}

