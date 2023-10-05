//
//  File.swift
//  
//
//  Created by George Tait on 05/10/2023.
//

import Foundation


public func getElapsedTimeData<T: VectorType>(dims: [Int], operation: (T,T) -> T) -> [Double]{
    
    var times = [Double](repeating: 0, count: dims.count)
    
    for i in 0..<dims.count {
        
        let currentSpace = VectorSpace<T.ScalarField>(dimension: dims[i], label: "Operation Time Complexity Space for dim = \(dims[i])")
        
        let lhs = T(elements: [T.ScalarField](repeating: T.ScalarField(Int.random(in: 1...10)), count: dims[i]), in: currentSpace)
        let rhs = T(elements: [T.ScalarField](repeating: T.ScalarField(Int.random(in: 1...10)), count: dims[i]), in: currentSpace)
        
        
        let startTime = clock()
        
        let res = operation(lhs, rhs)
        
        let endTime = clock()
        let elapsedTime = Double((endTime - startTime)/(CLOCKS_PER_SEC*1_000))
        
        times[i] = elapsedTime
    }
    
    return times
}
