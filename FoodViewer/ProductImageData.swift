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
    
    public static var  writableTypeIdentifiersForItemProvider: [String] {
        return [kUTTypePNG as NSString as String, kUTTypeJPEG as NSString as String]
    }
    
    @available(iOS 11.0, *)
    public func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {

        // Is there a local image available?
        if let validImage = self.image {
            switch typeIdentifier {
            case kUTTypeJPEG as NSString as String:
                completionHandler(UIImageJPEGRepresentation(validImage, 1.0), nil)
            case kUTTypePNG as NSString as String:
                completionHandler(UIImagePNGRepresentation(validImage), nil)
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
                    completionHandler(UIImageJPEGRepresentation(image, 1.0), nil)
                case kUTTypePNG as NSString as String:
                    completionHandler(UIImagePNGRepresentation(image), nil)
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
    
    public static var readableTypeIdentifiersForItemProvider: [String] {
        return [kUTTypeImage as String]
    }
    
    public static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> ProductImageData {
        return try ProductImageData(itemProviderData: data, typeIdentifier: typeIdentifier)
    }
    
    public struct Notification {
        static let ImageSizeCategoryKey = "ProductImageData.Notification.ImageSizeCategory.Key"
        static let ImageTypeCategoryKey = "ProductImageData.Notification.ImageTypeCategory.Key"
        static let BarcodeKey = "ProductImageData.Notification.Barcode.Key"
    }

    // This is available if the data has been retrieve from OFF, otherwise it is nil.
    // An image however can be set locally
    var url: URL? = nil
    
    var fetchResult: ImageFetchResult? = nil {
        didSet {
            // If an image has been retrieved fetchResult is set
            // and the image can be set as well
            if fetchResult != nil {
                // inform the user what is happening
                var userInfo: [String:Any] = [:]
                switch fetchResult! {
                case .success:
                    DispatchQueue.main.async(execute: { () -> Void in
                        userInfo[Notification.BarcodeKey] = self.barcode ?? "ProductImageData: no valid barcode"
                        userInfo[Notification.ImageTypeCategoryKey] = self.imageType().rawValue
                        if self.imageSize() != .unknown {
                            userInfo[Notification.ImageSizeCategoryKey] = self.imageSize().rawValue
                        }
                        NotificationCenter.default.post(name: .ImageSet, object: nil, userInfo: userInfo)
                    })
                default:
                    break
                }
            }
        }
    }

    // A local image can be set, then no url will be defined.
    private var image: UIImage? = nil {
        didSet {
            if image != nil {
                //fetchResult = .available
                // encode imageSize, imageType and barcode
                var userInfo: [String:Any] = [:]
                userInfo[Notification.ImageSizeCategoryKey] = imageSize().rawValue
                userInfo[Notification.ImageTypeCategoryKey] = imageType().rawValue
                userInfo[Notification.BarcodeKey] = barcode ?? "ProductImageData: no valid barcode"
                
                DispatchQueue.main.async(execute: { () -> Void in
                    NotificationCenter.default.post(name: .ImageSet, object: nil, userInfo: userInfo)
                })
            }
        }
    }
    
    var date: Date? = nil
    
    var hasBarcode: String? = nil
    
    private var downloadTask: DownloadTask? = nil

    var progress: Progress = Progress(totalUnitCount: 100)
    
    var response: URLResponse? = nil
    
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
        self.init(url: URL.init(string: OFF.imageURLFor(barcode, with:key, size:size)))
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
    
    func fetch() -> ImageFetchResult? {
        if fetchResult == nil {
            fetchResult = .loading
            // launch the image retrieval
            retrieveImage() { (fetchResult:ImageFetchResult?) in
                self.fetchResult = fetchResult
            }
        }
        return fetchResult
    }
    
    func reset() {
        fetchResult = nil
    }
    
    func type() -> ProductType? {
        if let validUrl = url {
            if validUrl.absoluteString.contains(ProductType.food.rawValue) {
                return .food
            } else if validUrl.absoluteString.contains(ProductType.petFood.rawValue) {
                return .petFood
            } else if validUrl.absoluteString.contains(ProductType.beauty.rawValue) {
                return .beauty
            }
        }
        return nil
    }
    
    func retrieveImage(completion: @escaping (ImageFetchResult) -> ()) {
        // Is there a local image?
        if let validImage = image {
            // The local image can no longer be present due to flushing
            completion(.success(validImage))
            return
        } else if let validURL = self.url {
            if validURL.isFileURL {
                
            } else {
                let fetcher = NetworkFetcher<UIImage>(URL: validURL)
                let cache = Shared.imageCache
                cache.fetch(fetcher: fetcher).onSuccess { image in
                    completion(.success(image))
                    return
                }
            }
        }
        /*
        // I could check the cache to see whether there is the corresponding image
        } else if let image = self.url?.cachedImage {
            completion(.success(image))
            return
        // if not is there something in the image cache?
        } else if let validUrlString = self.url?.absoluteString, ImageFileCache.manager.cache.checkInCache(key: validUrlString) {
            ImageFileCache.manager.cache.get(key: validUrlString) { image in
                guard let validImage = image else {
                    completion(.noImageAvailable)
                    return
                }
                completion(.success(validImage))
                return
            }
        // if not try the off-server
        } else {
        retrieveData(for: self.url, completionHandler: { (data, response, error)
            in
            guard error == nil else {
                print(error!.localizedDescription)
                completion(.loadingFailed(error!))
                return
            }
            
            //print(response?.description)
            //guard data != nil && data?.count != 0 else { completion (.noData); return }
            //completion(.success(data!))
            //return

             guard let httpResponse = response as? HTTPURLResponse else {
             completion(.noResponse)
             return
             }

            switch httpResponse.statusCode {
            case 200 :
                let dateString = httpResponse.allHeaderFields["Last-Modified"] as! String //EXAMPLE:  "Mon, 19 Oct 2015 05:57:12 GMT"
                if let shortDateString = dateString.substring(0, length: 16) {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "EEE, dd MMM yyyy"
                    // dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // This is essential as otherwise the language of the string is unknown?
                    self.date = dateFormatter.date(from: shortDateString)
                }
                guard let validData = data,
                    validData.count != 0,
                    let validUrlString = self.url?.absoluteString,
                    let validImage = UIImage(data: validData) else { completion (.noData); return }
                ImageCache.shared.setObject(
                        validImage,
                        forKey: validUrlString as NSString,
                        cost: validData.count)
                ImageFileCache.manager.cache.put(key: validUrlString, value: validImage)
                completion(.success(validImage))
                return
            default:
                print(httpResponse.description)
                completion(.response(httpResponse))
                return
            }
        })
        }
  */
    }
    
    func retrieveData(for url: URL?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) {
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
                print(error)
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
    
    private func imageType() -> ImageTypeCategory {
        guard url != nil else { return .general }
        
        if url!.absoluteString.contains(OFF.URL.ImageType.Front) {
            return .front
        } else if url!.absoluteString.contains(OFF.URL.ImageType.Ingredients) {
            return .ingredients
        } else if url!.absoluteString.contains(OFF.URL.ImageType.Nutrition) {
            return .nutrition
        }
        return .general
    }
    
    private func imageSize() -> ImageSizeCategory {
        guard url != nil else { return .unknown }
        
        if url!.absoluteString.contains(OFF.ImageSize.thumb.rawValue) {
            return .thumb
        } else if url!.absoluteString.contains(OFF.ImageSize.medium.rawValue) {
            return .small
        } else if url!.absoluteString.contains(OFF.ImageSize.large.rawValue) {
            return .display
        } else if url!.absoluteString.contains(OFF.ImageSize.original.rawValue) {
            return .original
        }
        return .unknown
    }

    private var barcode: String? {
        // decode the url to get the barcode
        guard url != nil else { return nil }
        // let separator = OFF.URL.Divider.Slash
        let elements = url!.absoluteString.split(separator:"/").map(String.init)
        // https://static.openfoodfacts.org/images/products/327/019/002/5337/ingredients_fr.27.100.jpg
        if elements.count >= 8 {
            return elements[4] + elements[5] + elements[6] + elements[7]
        } else if elements.count == 6 {
            return elements[4]
        } else {
            return "ProductImageData: No valid barcode"
        }
    }
}

// Definition:
extension Notification.Name {
    static let ImageSet = Notification.Name("ProductImageData.Notification.ImageSet")
}
