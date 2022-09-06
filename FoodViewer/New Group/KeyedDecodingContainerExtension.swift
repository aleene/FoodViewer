//
//  KeyedDecodingContainerExtension.swift
//  FoodViewer
//
//  Created by Arnaud Leene on 06/09/2022.
//  Copyright © 2022 Hovering Above. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer {
    
    func forceDouble(key: K) -> Double? {
        do {
            return try decodeIfPresent(Double.self, forKey: key )
        } catch {
            do {
                let asInt = try decodeIfPresent(Int.self, forKey: key)
                if let validAsInt = asInt {
                    return Double(validAsInt)
                }
            } catch {
                do {
                    let asString = try decodeIfPresent(String.self, forKey: key)
                    if let validAsString = asString {
                        return Double(validAsString)
                    }
                } catch {
                    print("KeyedDecodingContainer:forceDouble: \(key) is not convertable")
                }
            }
        }
        return nil
    }

    func forceInt(key: K) -> Int? {
        do {
            return try decodeIfPresent(Int.self, forKey: key )
        } catch {
            do {
                let asDouble = try decodeIfPresent(Double.self, forKey: key)
                if let validAsDouble = asDouble {
                    return Int(validAsDouble)
                }
            } catch {
                do {
                    let asString = try decodeIfPresent(String.self, forKey: key)
                    if let validAsString = asString {
                        return Int(validAsString)
                    }
                } catch {
                    print("KeyedDecodingContainer:forceInt: \(key) is not convertable")
                }
            }
        }
        return nil
    }

    func forceString(key: K) -> String? {
        do {
            return try decode(String.self, forKey: key)
        } catch {
            do {
                if let name = try decodeIfPresent(Float.self, forKey: key) {
                    return "\(name)"
                }
            } catch {
                do {
                    if let name = try decodeIfPresent(Int.self, forKey: key) {
                        return "\(name)"
                    }
                } catch {
                    print("KeyedDecodingContainer:forceString: \(key) is not convertable")
                }
            }
        }
        return nil
    }

}
