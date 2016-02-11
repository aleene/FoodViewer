//
//  IngredientsViewController.swift
//  FoodViewer
//
//  Created by arnaud on 09/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import TagListView

class IngredientsViewController: UIViewController {

    var product: FoodProduct? = nil {
        didSet {
            refresh()
        }
    }

    private func refresh() {
        if let newProduct = product {
            ingredientsLabel?.text = newProduct.ingredients != nil ? newProduct.ingredients! : Storyboard.IngredientsTextDefault
            if let allergensArray = newProduct.allergens {
                allergensTagListView?.removeAllTags()
                for allergen in allergensArray {
                    allergensTagListView?.addTag(allergen)
                }
            }
            
            if let tracesArray = newProduct.traces {
                tracesTagListView?.removeAllTags()
                for trace in tracesArray {
                    tracesTagListView?.addTag(trace)
                }
            }

            if let imageURL = product?.imageIngredientsUrl {
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                    do {
                        // This only works if you add a line to your Info.plist
                        // See http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
                        //
                        let imageData = try NSData(contentsOfURL: imageURL, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                        if imageData.length > 0 {
                            // if we have the image data we can go back to the main thread
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                if imageURL == self.product!.imageIngredientsUrl! {
                                    // set the received image
                                    self.imageView.image = UIImage(data: imageData)
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
    
    
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var allergensTagListView: TagListView! {
        didSet {
            allergensTagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            allergensTagListView.alignment = .Center
        }
    }
    @IBOutlet weak var tracesTagListView: TagListView! {
        didSet {
            tracesTagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            tracesTagListView.alignment = .Center
        }
    }
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.addGestureRecognizer(singleTapGestureRecognizer)
            imageView.userInteractionEnabled = true
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
        static let ImageSegueIdentifier = "Show Ingredients Image"
        static let ViewControllerTitle = "Ingredients"
        static let ImageViewControllerTitle = "Control"
        static let IngredientsTextDefault = "none"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.ImageSegueIdentifier:
                if let vc = segue.destinationViewController as? imageViewController {
                    vc.image = self.imageView.image
                    vc.imageTitle = Storyboard.ImageViewControllerTitle
                }
            default: break
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refresh()
        title = Storyboard.ViewControllerTitle
    }

}
