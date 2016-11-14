//
//  ProductUpdatedProtocol.swift
//  FoodViewer
//
//  Created by arnaud on 26/10/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

// protocol used for sending data back
protocol ProductUpdatedProtocol: class {
    
    var updatedProduct: FoodProduct? { get set }

    func updated(name: String, languageCode: String)

    func updated(genericName: String, languageCode: String)
    
    func updated(ingredients: String, languageCode: String)
}
