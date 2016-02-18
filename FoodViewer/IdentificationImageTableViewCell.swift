//
//  IdentificationImageTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 16/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class IdentificationImageTableViewCell: UITableViewCell {

    var cellUrl: NSURL? = nil {
        didSet {
            if let imageURL = cellUrl {
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                    do {
                        // This only works if you add a line to your Info.plist
                        // See http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
                        //
                        let imageData = try NSData(contentsOfURL: imageURL, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                        if imageData.length > 0 {
                            // if we have the image data we can go back to the main thread
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                if imageURL == self.cellUrl! {
                                    // set the received image
                                    self.identificationImageView.image = UIImage(data: imageData)
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

    @IBOutlet weak var identificationImageView: UIImageView!
    
}
