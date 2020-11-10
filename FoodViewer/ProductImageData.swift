 //
//  ProductImageData.swift
//  FoodViewer
//
//  Created by arnaud on 06/02/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

 public final class ProductImageData: NSObject, NSItemProviderReading, NSItemProviderWriting  {
    
// MARK: - static variables and functions
    
    public static var  writableTypeIdentifiersForItemProvider: [String] {
        return [kUTTypePNG as NSString as String, kUTTypeJPEG as NSString as String]
    }
    
    public static var readableTypeIdentifiersForItemProvider: [String] {
        return [kUTTypeImage as String]
    }
    
    public static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> ProductImageData {
        return try ProductImageData(itemProviderData: data, typeIdentifier: typeIdentifier)
    }
    
    public struct Notification {
        static let ImageSizeCategoryKey = "ProductImageData.Notification.ImageSizeCategory.Key"
        static let ImageTypeCategoryKey = "ProductImageData.Notification.ImageTypeCategory.Key"
        static let ImageIDKey = "ProductImageData.Notification.ImageID.Key"
        static let BarcodeKey = "ProductImageData.Notification.Barcode.Key"
    }
    
    @available(iOS 11.0, *)
    public func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {

        // Is there a local image available?
        if let validImage = self.image {
            switch typeIdentifier {
            case kUTTypeJPEG as NSString as String:
                completionHandler(validImage.jpegData(compressionQuality: 1.0), nil)
                // completionHandler(UIImageJPEGRepresentation(validImage, 1.0), nil)
            case kUTTypePNG as NSString as String:
                completionHandler(validImage.pngData(), nil)
            default:
                completionHandler(nil, ImageLoadError.unsupportedTypeIdentifier(typeIdentifier))
            }
        // is there a cached image?
        } else if let validURL = self.url {
            let fetcher = NetworkFetcher<UIImage>(URL: validURL)
            let cache = Shared.imageCache
            cache.fetch(fetcher: fetcher).onSuccess { image in
                switch typeIdentifier {
                case kUTTypeJPEG as NSString as String:
                    completionHandler(image.jpegData(compressionQuality: 1.0), nil)
                    // completionHandler(UIImageJPEGRepresentation(image, 1.0), nil)
                case kUTTypePNG as NSString as String:
                    completionHandler(image.pngData(), nil)
                default:
                    completionHandler(nil, ImageLoadError.unsupportedTypeIdentifier(typeIdentifier))
                }
            }
        } else {
            self.fetchResult = .noData
            // No image can be retrieved
            completionHandler(nil, ImageLoadError.noValidUrl)
        }
        return self.progress
    }
    

    /// The URL of the image as can be found remotely.
    /// If the value is nil, the image is already available (from camera or photo library).
    public var url: URL? = nil
    
    public var fetchResult: ImageFetchResult? = nil {
        didSet {
            // If an image has been retrieved fetchResult is set
            // and the image can be set as well
            if fetchResult != nil {
                // inform the user what is happening
                var userInfo: [String:Any] = [:]
                switch fetchResult! {
                case .success:
                    DispatchQueue.main.async(execute: { () -> Void in
                        if let validBarcode = self.url?.OFFbarcode {
                            userInfo[Notification.BarcodeKey] = validBarcode
                        }
                        if let validImageType = self.url?.OFFimageType {
                            userInfo[Notification.ImageTypeCategoryKey] = validImageType.rawValue
                        }
                        if let validImageSize = self.url?.OFFimageSize {
                            userInfo[Notification.ImageSizeCategoryKey] = validImageSize.rawValue
                        }
                        if let validImageID = self.url?.OFFimageID {
                            userInfo[Notification.ImageIDKey] = validImageID
                        }
                        NotificationCenter.default.post(name: .ImageSet, object: nil, userInfo: userInfo)
                    })
                default:
                    break
                }
            }
        }
    }
    
    public var hasBarcode: String? = nil

    private var progress: Progress = Progress(totalUnitCount: 100)
 
    private var response: URLResponse? = nil
 
// MARK: - private variables
    
    /// A local image can be set, then no url will be defined.
    private var image: UIImage? = nil {
        didSet {
            if image != nil {
                var userInfo: [String:Any] = [:]
                if let validBarcode = url?.OFFbarcode {
                    userInfo[Notification.BarcodeKey] = validBarcode
                }
                if let validImageType = url?.OFFimageType {
                    userInfo[Notification.ImageTypeCategoryKey] = validImageType.rawValue
                }
                if let validImageSize = url?.OFFimageSize {
                    userInfo[Notification.ImageSizeCategoryKey] = validImageSize.rawValue
                }
                if let validImageID = url?.OFFimageID {
                    userInfo[Notification.ImageIDKey] = validImageID
                }

                DispatchQueue.main.async(execute: { () -> Void in
                    NotificationCenter.default.post(name: .ImageSet, object: nil, userInfo: userInfo)
                })
            }
        }
    }
    
    private var downloadTask: DownloadTask? = nil

// MARK: - Initialisers

    override init() {
        super.init()
        url = nil
        fetchResult = nil
    }
    
    init(url: URL?) {
        super.init()
        self.url = url
        fetchResult = nil
    }
    
    init(image: UIImage) {
        super.init()
        self.url = nil
        self.image = image
        self.fetchResult = .success(image)
    }
    
    init(image: UIImage, url: URL) {
        super.init()
        self.url = url
        self.image = image
        self.fetchResult = .success(image)
    }

    convenience init(barcode: BarcodeType, key: String, size: ImageSizeCategory) {
        self.init(url: URL.init(string: OFF.imageURLFor(barcode, with:key, size: size)))
    }
    
    convenience init(itemProviderData data: Data, typeIdentifier: String) throws {
        
        switch typeIdentifier {
        case kUTTypeImage as NSString as String:
            if let validImage = UIImage.init(data: data) {
                self.init(image:validImage)
            }
        default:
            break
        }
        throw NSError.init(domain: "FoodViewer.ProductImageData", code: 1, userInfo: [:])
    }
    
// MARK: - public functions
    
    public func fetch() -> ImageFetchResult? {
        if fetchResult == nil {
            fetchResult = .loading
            // launch the image retrieval
            retrieveImage() { (fetchResult:ImageFetchResult?) in
                self.fetchResult = fetchResult
            }
        }
        return fetchResult
    }
    
    public func reset() {
        fetchResult = nil
    }
        
    private func retrieveImage(completion: @escaping (ImageFetchResult) -> ()) {
        // Is there a local image?
        if let validImage = image {
            // The local image can no longer be present due to flushing
            completion(.success(validImage))
            return
        } else if let validURL = self.url {
            if validURL.isFileURL {
                ProductStorage.manager.fetchImage(for: validURL) { compl in
                    switch compl {
                    case .success(let image):
                        completion( .success(image) )
                        return
                    case .failure:
                        completion( .noImageAvailable )
                        return
                    }
                }
            } else {
                let fetcher = NetworkFetcher<UIImage>(URL: validURL)
                let cache = Shared.imageCache
                cache.fetch(fetcher: fetcher).onSuccess { image in
                    
                    completion(.success(image))
                    return
                }
            }
        }
    }
    
    public func retrieveData(for url: URL?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) {
        guard let imageURL = url  else {
            completionHandler(nil, nil, nil)
            return
        }
        if downloadTask != nil {
            downloadTask!.cancel()
        }
        downloadTask = DownloadService.shared.download(request: URLRequest(url: imageURL))
        downloadTask?.resume()
        downloadTask?.completionHandler = { [weak self] in
            switch $0 {
            case .failure(let error):
                print("retrieveData(forUrl: ",error)
                completionHandler(nil, self?.response, error)
            case .success(let data):
                // print("Number of bytes: \(data.count)")
                completionHandler(data, self?.response, nil)
            }
            self?.downloadTask = nil
        }
        downloadTask?.progressHandler = { progress in
            // print("Task2: \(progress.fractionCompleted)")
            self.progress = progress
        }
        
        downloadTask?.responseHandler = { response in
            self.response = response
        }
    }
    
}

// MARK: - Notification
 
extension Notification.Name {
    static let ImageSet = Notification.Name("ProductImageData.Notification.ImageSet")
}
