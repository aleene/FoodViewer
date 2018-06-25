//
//  ItemCacheProtocol.swift
//  cacheTest
//
//  Created by Maksim Kita on 12/28/17.
//  Copyright © 2017 Maksim Kita. All rights reserved.
//

import Foundation
import UIKit

public protocol ItemCacheProtocol {
    func toData() -> Data?
    init?(data:Data)
}


