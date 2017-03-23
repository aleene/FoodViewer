//
//  MetricPrefix.swift
//  FoodViewer
//
//  Created by arnaud on 16/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

public struct MetricPrefix {
    
    public struct Giga {
        static let Symbol = "G"
        static let Factor = 1000000000.0
        static let Description = "Giga"
    }
    
    public struct Mega {
        static let Symbol = "M"
        static let Factor = 1000000.0
        static let Description = "Giga"
    }
    
    public struct Kilo {
        static let Symbol = "k"
        static let Factor = 1000.0
        static let Description = "Giga"
    }
    
    public struct None {
        static let Symbol = ""
        static let Factor = 1.0
        static let Description = "None"
    }
    
    public struct Milli {
        static let Symbol = "m"
        static let Factor = 0.001
        static let Description = "Milli"
    }
    
    public struct Micro {
        static let Symbol = "µ"
        static let Factor = 0.000001
        static let Description = "Micro"
    }
    
    public struct Nano {
        static let Symbol = "n"
        static let Factor = 0.000000001
        static let Description = "Nano"
    }
    
}
