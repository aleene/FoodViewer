//
//  ResultType.swift
//  FoodViewer
//
//  Created by arnaud on 12/01/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//
// https://stackoverflow.com/questions/30543806/get-progress-from-datataskwithurl-in-swift

public enum ResultType<T> {
    
    public typealias ImaginaryCompletion = (ResultType<T>) -> Void
    
    case success(T)
    case failure(Swift.Error)
    
}
