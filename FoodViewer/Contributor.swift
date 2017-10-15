//
//  Contributor.swift
//  FoodViewer
//
//  Created by arnaud on 12/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation


class Contributor : Equatable {
    var name: String = ""
    var roles: [ContributorRole] = []
    
    init(_ name: String, role: ContributorRole) {
        self.name = name
        self.roles.append(role)
    }
    
    // use the name string to return a hashValue for equatable
    var hashValue: Int {
        return name.hashValue
    }

    // Mark: Equatable
    static func ==(lhs: Contributor, rhs: Contributor) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public func add(_ role: ContributorRole) {
        self.roles.append(role)
    }
    
    public var isPhotographer: Bool {
        for role in roles {
            switch role {
            case .photographer:
                return true
            default:
                break
            }
        }
        return false
    }
    
    public var isCreator: Bool {
        for role in roles {
            switch role {
            case .creator:
                return true
            default:
                break
            }
        }
        return false
    }

    public var isChecker: Bool {
        for role in roles {
            switch role {
            case .checker:
                return true
            default:
                break
            }
        }
        return false
    }

    public var isCorrector: Bool {
        for role in roles {
            switch role {
            case .corrector:
                return true
            default:
                break
            }
        }
        return false
    }
    
    public var isEditor: Bool {
        for role in roles {
            switch role {
            case .editor:
                return true
            default:
                break
            }
        }
        return false
    }
    
    public var isInformer: Bool {
        for role in roles {
            switch role {
            case .informer:
                return true
            default:
                break
            }
        }
        return false
    }
}
