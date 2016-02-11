//
//  IdentificationViewController.swift
//  FoodViewer
//
//  Created by arnaud on 07/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import TagListView

class IdentificationViewController: UIViewController {

    var product: FoodProduct? = nil {
        didSet {
            refresh()
        }
    }
    
    func refresh() {
        if let newProduct = product {
            barcodeLabel?.text = newProduct.barcode.asString()
            nameLabel?.text = newProduct.name != nil ? newProduct.name! : "undefined"
            commonNameLabel?.text = newProduct.commonName != nil ? newProduct.commonName! : "undefined"
            if let brandsArray = newProduct.brandsArray {
                brandsTagListView?.removeAllTags()
                for brand in brandsArray {
                    brandsTagListView?.addTag(brand)
                }
            }
            quantityLabel?.text = newProduct.quantity != nil ? newProduct.quantity! : "undefined"
            if let packagingArray = newProduct.packagingArray {
                packagingTagListView?.removeAllTags()
                for packaging in packagingArray {
                    packagingTagListView?.addTag(packaging)
                }
            }
            if let imageURL = product?.mainUrl {
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                    do {
                        // This only works if you add a line to your Info.plist
                        // See http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
                        //
                        let imageData = try NSData(contentsOfURL: imageURL, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                        if imageData.length > 0 {
                            // if we have the image data we can go back to the main thread
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                if imageURL == self.product!.mainUrl! {
                                    // set the received image
                                    self.productImageView.image = UIImage(data: imageData)
                                }
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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var barcodeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commonNameLabel: UILabel!
    @IBOutlet weak var brandsTagListView: TagListView! {
        didSet {
            brandsTagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle2)
            brandsTagListView.alignment = .Center
        }
    }

    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var packagingTagListView: TagListView! {
        didSet {
            packagingTagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle2)
            packagingTagListView.alignment = .Center
        }
    }
    
    @IBOutlet weak var productImageView: UIImageView! {
        didSet {
            productImageView.addGestureRecognizer(singleTapGestureRecognizer)
            productImageView.userInteractionEnabled = true
        }
    }

    
    @IBOutlet var singleTapGestureRecognizer: UITapGestureRecognizer! {
        didSet {
            singleTapGestureRecognizer.addTarget(self, action: "imageTapped")
        }
    }
    
    func imageTapped() {
        performSegueWithIdentifier(Storyboard.ImageSegueIdentifier, sender: self)
    }
    
    struct Storyboard {
        static let ImageSegueIdentifier = "Show Product Image"
        static let ViewControllerTitle = "Identification"
        static let ImageViewControllerTitle = "Control"
        static let IngredientsTextDefault = "none"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.ImageSegueIdentifier:
                if let vc = segue.destinationViewController as? imageViewController {
                    vc.image = self.productImageView.image
                    vc.imageTitle = Storyboard.ImageViewControllerTitle
                }
            default: break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        title = "Identification"
    }
}
