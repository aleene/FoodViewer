//
//  NameTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 06/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NameTableViewCell: UITableViewCell {

    var product: FoodProduct? = nil {
        didSet {
            productNameLabel.text = product?.name != nil ? product!.name : "No product name"
            brandLabel.text = product?.brandsArray?[0] != nil ? product!.brandsArray![0] : "No brand"
            if let imageURL = product?.mainUrlThumb {
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                    do {
                        // This only works if you add a line to your Info.plist
                        // See http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
                        //
                        let imageData = try NSData(contentsOfURL: imageURL, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                        if imageData.length > 0 {
                            // if we have the image data we can go back to the main thread
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                if imageURL == self.product!.mainUrlThumb! {
                                    // set the received image
                                    self.productImageView.image = UIImage(data: imageData)
                                    // Note the image is set to Aspect Fit in the storyboard, so one can see the entire image
                                    // print("image bounds \(self.productImageView.image?.size)")
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


    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!

}