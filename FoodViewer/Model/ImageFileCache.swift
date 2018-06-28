//
//  ImageFileCache.swift
//  FoodViewer
//
//  Created by arnaud on 25/06/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//
/*
import Foundation
import UIKit

class ImageFileCache {
    
    static var manager = ImageFileCache()

    var cache: LRUFileCache <String, UIImage>
    
    init() {
        cache = LRUFileCache <String, UIImage> (maxSize: Double(Int.max),
                                                   capacity: Int.max,
                                                   cacheDestination:FileCacheDestination.folder("Images"))
        { value in
            guard let data = value.toData() else { return 0 }
            //return size in bytes
            return Double(data.count)
        }
    }

}
 */
