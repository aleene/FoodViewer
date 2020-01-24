//
//  StoryboardString.swift
//  FoodViewer
//
//  Created by arnaud on 21/01/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation

struct StoryboardString {
    struct SegueIdentifier {
        struct FromAddFavoriteShopTableVC {
            static let UnwindVC = "Unwind Add Favorite Shop Segue"
        }
        struct FromSupplyChainTableVC {
            static let ToSelectPairVC = "Select Country"
            static let ToFavoriteShopsTableVC = "Show Favorite Shops Segue"
            static let ToExpirationDateVC = "Show ExpirationDate ViewController"
        }
        struct FromProductImagesCollectionVC {
            static let ToImageVC = "Show Image"
            static let ToSelectLanguageAndImageTypeVC = "Show Language And ImageType Segue Identifier"
        }
        struct FromSelectCompareVC {
            static let Unwind = "Unwind Set Comparison Operator For Done Segue Identifier"
        }
        struct SelectCompletionStateVC {
            static let Unwind = "Unwind Select Completion State"
        }
        struct SelectContributorRoleVC {
            static let Unwind = "Unwind Set Contributor Role For Done"
        }
        struct SelectLanguageVC {
            static let ToAddLanguageVC = "Add Language ViewController Segue"
        }
    }
}
