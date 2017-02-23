//
//  NoNutrientsImageTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 13/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//


import UIKit

class NoNutrientsImageTableViewCell: UITableViewCell {
    
    internal struct Notification {
        static let NoNutrientsImageChangeLanguageButtonTappedKey = "NoNutrientsImageTableViewCell.Notification.ChangeLanguageButtonTapped.Key"
    }

    fileprivate struct Constants {
        static let NoLanguage = NSLocalizedString("no", comment: "Text for language of product, when there is no language defined.")
        // Correct width for language button width (32) and trailing margin (8)
        static let Margin = CGFloat( 44.0 )
    }

    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            tagListView.alignment = .center
            tagListView.cornerRadius = 10
            tagListView.datasource = datasource
        }
    }
    
    @IBOutlet weak var languageButton: UIButton! {
        didSet {
            setLanguageButton()
        }
    }

    
    @IBAction func languageButtonTapped(_ sender: UIButton) {
        let userInfo = [Notification.NoNutrientsImageChangeLanguageButtonTappedKey:sender]
        NotificationCenter.default.post(name: .NoNutritionImageLanguageTapped, object: nil, userInfo: userInfo)
    }
    
    private func setLanguageButton() {
        languageButton?.isEnabled = editMode ? true : ( numberOfLanguages > 1 ? true : false )
        let verboseLanguage = languageCode != nil ? OFFplists.manager.translateLanguage(languageCode!, language:Locale.preferredLanguages[0]) : Constants.NoLanguage
        languageButton.setTitle(verboseLanguage, for: UIControlState())
    }
    
    var datasource: TagListViewDataSource? = nil {
        didSet {
            tagListView?.datasource = datasource
        }
    }
    
    var delegate: TagListViewDelegate? = nil {
        didSet {
            tagListView?.delegate = delegate
        }
    }
    

    var editMode: Bool = false {
        didSet {
            setLanguageButton()
        }
    }

    var width: CGFloat = CGFloat(320.0) {
        didSet {
            tagListView?.frame.size.width = width - Constants.Margin
        }
    }
    
    var scheme = ColorSchemes.normal {
        didSet {
            tagListView?.normalColorScheme = scheme
        }
    }
    
    var languageCode: String? = nil {
        didSet {
            setLanguageButton()
        }
    }
    
    var numberOfLanguages: Int = 0 {
        didSet {
            setLanguageButton()
        }
    }
    
    override var tag: Int {
        didSet {
            tagListView?.tag = tag
        }
    }
    
    func reloadData() {
        tagListView.reloadData(clearAll: true)
    }
    
}

// Definition:
extension Notification.Name {
    static let NoNutritionImageLanguageTapped = Notification.Name("NoNutrientsImageTableViewCell.Notification.ChangeLanguageButtonTapped")
}


