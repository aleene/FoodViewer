//
//  ProductsArray.swift
//  FoodViewer
//
//  Created by arnaud on 07/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

class ProductsArray {
    
    // This class is implemented as a singleton
    // The productsArray is only needed by the ProductsViewController
    // Unfortunately moving to another VC deletes the products, so it must be stored somewhere more permanently.
    // A singleton limits however the number of file loads
    
    struct Notification {
        static let ProductNotAvailable = "Product Not Available"
        static let ProductLoaded = "Product Loaded"
        static let FirstProductLoaded = "First Product Loaded"
    }
    static let instance = ProductsArray()
    
    var list: [FoodProduct] = []
    
    var storedHistory = History()
    
    init() {
        if list.isEmpty {
            // check if there is history available
            // and init products with History
            if !storedHistory.barcodes.isEmpty {
                historyHasBeenLoaded = 0
                for storedBarcode in storedHistory.barcodes {
                    // this fills the database of products
                    let newProduct = FoodProduct(withBarcode: BarcodeType(value: storedBarcode))
                    // create empty products for each barcode in history
                    list.append(newProduct)
                    // fetch the corresponding data from internet
                    fetchProduct(newProduct.barcode)
                }
            } else {
                historyHasBeenLoaded = nil
            }
            // performSegueWithIdentifier(Storyboard.ToPageViewControllerSegue, sender: self)
        }
    }

    // This variable is needed to keep track of the asynchrnous interet retrievals
    private var historyHasBeenLoaded: Int? = nil {
        didSet {
            if let currentLoadHistory = historyHasBeenLoaded {
                if currentLoadHistory == storedHistory.barcodes.count {
                    // all products have been loaded from history
                    historyHasBeenLoaded = nil
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.ProductLoaded, object:nil)
                    // This should happen only once?
                    // It is possible that at this stage the relevant product data has not been loaded yet
                    // performSegueWithIdentifier(Storyboard.ToPageViewControllerSegue, sender: self)
                    // scroll to the top product in the tableview
                }
            }
        }
    }

    func fetchProduct(barcode: BarcodeType?) {
        if barcode != nil {
            let request = OpenFoodFactsRequest()
            // loading the product from internet will be done off the main queue
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                let fetchResult = request.fetchProductForBarcode(barcode!)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    switch fetchResult {
                    case .Success(let newProduct):
                        self.updateProduct(newProduct)
                        NSNotificationCenter.defaultCenter().postNotificationName(Notification.ProductLoaded, object:nil)
                    case .Error(let error):
                        let userInfo = ["error":error]
                        NSNotificationCenter.defaultCenter().postNotificationName(Notification.ProductNotAvailable, object:nil, userInfo: userInfo)
                    }
                })
            })
        }
    }

    private func updateProduct(product: FoodProduct?) {
        if let productToUpdate = product {
            // should check if the product is not already available
            if !list.isEmpty {
                // look at all products
                var indexExistingProduct: Int? = nil
                for index in 0 ..< list.count {
                    // print("products \(products[index].barcode.asString()); update \(productToUpdate.barcode.asString())")
                    if list[index].barcode.asString() == productToUpdate.barcode.asString() {
                        indexExistingProduct = index
                    }
                }
                if indexExistingProduct == nil {
                    // new product not yet in products array
                    // print("ADD product \(productToUpdate.barcode.asString())")
                    self.list.insert(productToUpdate, atIndex: 0)
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.ProductLoaded, object:nil)
                    // add product barcode to history
                    self.storedHistory.addBarcode(barcode: productToUpdate.barcode.asString())
                } else {
                    // print("UPDATE product \(productToUpdate.barcode.asString())")
                    // reset product information to the retrieved one
                    self.list[indexExistingProduct!] = productToUpdate
                    if historyHasBeenLoaded != nil {
                        historyHasBeenLoaded! += 1
                    }
                }
            } else {
                // print("FIRST product \(productToUpdate.barcode.asString())")
                
                // this is the first product of the array
                list.append(productToUpdate)
                // add product barcode to history
                self.storedHistory.addBarcode(barcode: productToUpdate.barcode.asString())
            }
            // launch image retrieval if needed
            if (productToUpdate.mainUrl != nil) {
                if (productToUpdate.mainImageData == nil) {
                    // get image only if the data is not there yet
                    retrieveImage(productToUpdate.mainUrl!)
                }
            }
        }
    }
        
    private func retrieveImage(url: NSURL?) {
            if let imageURL = url {
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                    do {
                        // This only works if you add a line to your Info.plist
                        // See http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
                        //
                        let imageData = try NSData(contentsOfURL: imageURL, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                        if imageData.length > 0 {
                            // if we have the image data we can go back to the main thread
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                // set the received image data
                                // as we are on another thread I should find the product to add it to
                                if !self.list.isEmpty {
                                    // look at all products
                                    var indexExistingProduct: Int? = nil
                                    for index in 0 ..< self.list.count {
                                        if self.list[index].mainUrl == imageURL {
                                            indexExistingProduct = index
                                        }
                                    }
                                    if indexExistingProduct != nil {
                                        self.list[indexExistingProduct!].mainImageData = imageData
                                    }
                                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.ProductLoaded, object:nil)
                                } // else bad luck corresponding product is no longer there
                            })
                        }
                    }
                    catch {
                        print(error)
                    }
                })
            }
        }
        

}