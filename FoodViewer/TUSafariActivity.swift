//
//  TUSafariActivity.swift
//  FoodViewer
//
//  Created by arnaud on 09/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

class TUSafariActivity : UIActivity {
    
    private var openURL: NSURL? = nil
    
    override func activityType() -> String {
        return "FoodViewer.OpenInSafari"
    }
    
    override func activityTitle() -> String {
        return NSLocalizedString("Open in Safari", comment: "String for the Activity Action Screen")
    }
    
    override func activityImage() -> UIImage? {
        return UIImage(named: "Safari")
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        return true
    }

    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        // extract the url out of the activityItems
        for item in activityItems {
            if let url = item as? NSURL {
                openURL = url
            }
        }
    }
    
    override func activityViewController() -> UIViewController? {
        return nil
    }
    
    override func performActivity() {
        // Todo: handle action:
        if let requestUrl = openURL {
            UIApplication.sharedApplication().openURL(requestUrl)
        }
        
        self.activityDidFinish(true)
    }
    
}