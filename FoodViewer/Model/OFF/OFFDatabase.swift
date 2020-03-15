//
//  OFFDatabase.swift
//  FoodViewer
//
//  Created by arnaud on 13/04/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

struct OFFDatabase {
    
    private struct Constants {
        struct Database {
            static let Beauty = "BeautyProductsDB"
            static let Food = "FoodProductsDB"
            static let PetFood = "PetFoodProductsDB"
            static let Product = "ProductsDB"
        }
        static let CSVExtension = "csv"
    }
    
    static let manager = OFFDatabase()

    private var csv: CSVReader? = nil
    
    private let currentProductType = Preferences.manager.showProductType
    
    private var filenameForType: String {
        switch currentProductType {
        case .food:
            return Constants.Database.Food
        case .beauty:
            return Constants.Database.Beauty
        case .petFood:
            return Constants.Database.PetFood
        case .product:
            return Constants.Database.Product
        }
    }
    
    init() {
        guard let filePath = Bundle.main.path(forResource: filenameForType, ofType: Constants.CSVExtension) else { return }
        guard let stream = InputStream(fileAtPath: filePath) else { return }
        do {
            csv = try CSVReader.init(stream: stream, hasHeaderRow: true, trimFields: false, delimiter: ";", whitespaces: .whitespaces)
        } catch {
            print("OFFDatabase: error")
        }
    }

    func contains(barcodeString: String) -> Bool {
        if let validCSV = csv {
            while validCSV.next() != nil {
                if validCSV[OFFWriteAPI.Barcode] == barcodeString {
                    return true
                }
            }
        }
        return false
    }
    
    func product(for barcodeString: String, completionHandler: @escaping (FoodProduct?) -> ()) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
            if let validCSV = self.csv {
                while validCSV.next() != nil {
                    if validCSV[OFFWriteAPI.Barcode] == barcodeString {
                        let product = FoodProduct(with: BarcodeType(barcodeString: barcodeString, type: self.currentProductType))
                        product.nameLanguage[Locale.interfaceLanguageCode] = validCSV[OFFWriteAPI.Name]
                        DispatchQueue.main.async(execute: { () -> Void in
                            completionHandler(product)
                        })
                    }
                }
            }
            DispatchQueue.main.async(execute: { () -> Void in
                completionHandler(nil)
            })
        })
    }

}
