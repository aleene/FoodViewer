//
//  GKImageCropViewController.swift
//  GKImagePickerSwift
//
//  Created by Georg Kitz on 6/1/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//
//  Translated in Swift by arnaud on 12/02/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

open class GKImageCropViewController: UIViewController {
    
    var imageCropView: GKImageCropView? = nil
    var toolbar: UIToolbar? = nil
    var cancelButton: UIButton? = nil
    var useButton: UIButton? = nil
    
    // MARK: - Getter/Setter
    
    var sourceImage: UIImage? = nil {
        didSet {
            self.imageCropView?.imageToCrop = sourceImage
        }
    }
    
    var cropSize: CGSize = CGSize.zero {
        didSet {
            self.imageCropView?.cropSize = self.cropSize
        }
    }
    
    var delegate: GKImageCropControllerDelegate? = nil
    var hasResizableCropArea = false {
        didSet {
            self.imageCropView?.hasResizableCropArea = self.hasResizableCropArea
        }
    }
    
    func _actionCancel() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func _actionUse() {
        let _croppedImage = imageCropView!.croppedImage()
        delegate?.imageCropController(self, didFinishWith: _croppedImage )
    }
    
    // MARK: - Private Methods
    
    private func _setupNavigationBar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(GKImageCropViewController._actionCancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Use", comment: "GKIuse"), style: .plain, target: self, action: #selector(GKImageCropViewController._actionUse))
    }
    
    
    private func _setupCropView() {
        self.imageCropView = GKImageCropView.init(frame: self.view.bounds)
        if self.imageCropView != nil {
            self.imageCropView!.imageToCrop = sourceImage
            self.imageCropView!.hasResizableCropArea = self.hasResizableCropArea
            self.imageCropView!.cropSize = cropSize
            self.view.addSubview(self.imageCropView!)
        }
    }
    
    private func _setupCancelButton() {
        self.cancelButton = UIButton.init(type: .custom)
        self.cancelButton?.addTarget(self, action: #selector(GKImageCropViewController._actionCancel), for: .touchUpInside)
        self.cancelButton?.frame = CGRect.init(x: 0, y: 0, width: 58, height: 30)
        self.cancelButton?.titleLabel?.shadowOffset = CGSize.init(width: 0, height: -1)
        self.cancelButton?.setTitle(NSLocalizedString("Cancel", comment: "GKIcancel"), for: .normal)
        self.cancelButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        self.cancelButton?.setTitleShadowColor(UIColor.init(red: 0.118, green: 0.247, blue: 0.455, alpha: 1), for: .normal)
    }
    
    private func _setupUseButton() {
    
        self.useButton = UIButton.init(type: .custom)
        self.useButton?.setTitle(NSLocalizedString("Use", comment: "GKIuse"), for: .normal)
        self.useButton?.titleLabel?.shadowOffset = CGSize.init(width: 0, height: -1)
        self.useButton?.frame = CGRect.init(x: 0, y: 0, width: 58, height: 30)
        self.useButton?.addTarget(self, action: #selector(GKImageCropViewController._actionUse), for: .touchUpInside)
        self.useButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        self.useButton?.setTitleShadowColor(UIColor.init(red: 0.118, green: 0.247, blue: 0.455, alpha: 1), for: .normal)
    }
    
    private func _toolbarBackgroundImage() -> UIImage? {
        let components: [CGFloat] = [1, 1, 1, 1, 123/255, 125/255, 132/255, 1]
        
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: 320, height: 54), true, 0.0);

        let ctx = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: nil, count: 2)

        ctx!.drawLinearGradient(gradient!, start: CGPoint.init(x: 0, y: 0), end: CGPoint.init(x: 0, y: 54), options: .drawsAfterEndLocation);

        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return viewImage
    }

    private func _setupToolbar() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.toolbar = UIToolbar.init(frame: CGRect.zero)
            if self.toolbar != nil {
                self.toolbar!.isTranslucent = true
                self.toolbar!.barStyle = .blackOpaque
                self.view.addSubview(self.toolbar!)
            }
            self._setupCancelButton()
            self._setupUseButton()
        
            
            let info = UILabel.init(frame: CGRect.zero)
            info.text = NSLocalizedString("Move/Scale", comment: "GKImoveAndScale")
            info.textColor = UIColor.white
            info.backgroundColor = UIColor.clear
            info.shadowColor = UIColor.init(red: 0.827, green: 0.831, blue: 0.839, alpha: 1)
            info.shadowOffset = CGSize.init(width: 0, height: 1)
            info.font = UIFont.boldSystemFont(ofSize: 18)
            info.sizeToFit()
        
            let cancel = UIBarButtonItem.init(customView: self.cancelButton!)
            let flex = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let lbl = UIBarButtonItem.init(customView: info)
            let use = UIBarButtonItem.init(customView: self.useButton!)
            self.toolbar?.setItems([cancel, flex, lbl, flex, use], animated: false)
        }
    }
    
    // MARK: - ViewController Lifecycle
    
    override open func viewDidLoad() {

        super.viewDidLoad()
    
        self.title = NSLocalizedString("Move/Scale", comment: "GKResizePhoto")
    
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.navigationController?.isNavigationBarHidden = true
        } else {
            self.navigationController?.isNavigationBarHidden = false
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // setup the interface here, as only now the right sizes are known.
        self._setupNavigationBar()
        self._setupCropView()
        self._setupToolbar()
    }

    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.imageCropView?.frame = self.view.bounds;
        self.toolbar?.frame = CGRect.init(x:0, y:self.view.frame.height, width:320, height:54)
    }

}
