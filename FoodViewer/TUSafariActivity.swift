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
    
    fileprivate var openURL: URL? = nil
    
    override var activityType : UIActivityType? {
        get {
            return UIActivityType(rawValue: "FoodViewer.OpenInSafari")
        }
    }
    
    override var activityTitle : String {
        return NSLocalizedString("Open in Safari", comment: "String for the Activity Action Screen")
    }
    
    override var activityImage : UIImage? {
        return UIImage(named: "Safari")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        // extract the url out of the activityItems
        for item in activityItems {
            if let url = item as? URL {
                openURL = url
            }
        }
    }
    
    override var activityViewController : UIViewController? {
        return nil
    }
    
    override func perform() {
        // Todo: handle action:
        if let requestUrl = openURL {
            UIApplication.shared.open(requestUrl, options: [:], completionHandler: nil)
        }
        
        self.activityDidFinish(true)
    }
    
}
