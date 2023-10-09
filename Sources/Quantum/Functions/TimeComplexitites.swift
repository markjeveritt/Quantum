//
//  File.swift
//  
//
//  Created by George Tait on 05/10/2023.
//

import Foundation



public func estimateTimeComplexity<T:VectorType>(dims: [Int], operation: (T,T) -> T) -> (Double, Double) {
    
    let elapsedTimes = getElapsedTimeData(dims: dims, operation: operation)
    let logElapsedTimes = elapsedTimes.map{ log($0) }
    
    let logDims = dims.map{ log(Double($0)) }

    let (omega, _) = getLinearFitCoefficientsFromLeastSquaresMethod(logDims, logElapsedTimes)
    
    let r_sq = getRSquaredCoefficient(logDims, logElapsedTimes)
    return (omega, r_sq)
    
}


public func getElapsedTimeData<T: VectorType>(dims: [Int], operation: (T,T) -> T) -> [Double]{
    
    var times = [Double](repeating: 0, count: dims.count)
    for i in 0..<dims.count {
        
        let currentSpace = VectorSpace<T.ScalarField>(dimension: dims[i], label: "Operation Time Complexity Space for dim = \(dims[i])")
        
        let lhs = T(elements: [T.ScalarField](repeating: T.ScalarField(Int.random(in: 1...10)), count: dims[i]*dims[i]), in: currentSpace)
        let rhs = T(elements: [T.ScalarField](repeating: T.ScalarField(Int.random(in: 1...10)), count: dims[i]*dims[i]), in: currentSpace)
        
        
        let startTime = clock()
        
        let _ = operation(lhs, rhs)
        let endTime = clock()
        
        let elapsedTime = Double((endTime - startTime))/Double(CLOCKS_PER_SEC/1_000)
        
        times[i] = elapsedTime
    }
    
    
    return times
}



public func storeElapsedTimeDataToFile<T: VectorType>(dims: [Int], operation: (T,T) -> T, filename: String) {
    
    let outputText = convertElapsedTimeDataToWriteableFormat(dims: dims, operation: operation)
    
    let pathToFile = FileManager.default.homeDirectoryForCurrentUser.path + "/Desktop/rtData/"
    let writeFilename = pathToFile + "'\(filename)'"
    
    _ = FileManager.default.createFile(atPath: writeFilename, contents: nil, attributes: nil)
    
    do {
    
    try  outputText.write(toFile: writeFilename, atomically: false, encoding: .utf8) }
    
    catch { errorStream.write("Can not write to output \n")}
    
    
}

public func convertElapsedTimeDataToWriteableFormat<T: VectorType> (dims: [Int], operation: (T,T) -> T) -> String {
    
    let times = getElapsedTimeData(dims: dims, operation: operation)
    var outputText = ""
    
    for i in 0..<dims.count {
        
        outputText += "\(dims[i]) \t \(times[i]) \n"
        
    }
    
    return outputText
}


public func getRSquaredCoefficient(_ x: [Double], _ y: [Double]) -> Double {
    
//  Method from https://en.wikipedia.org/wiki/Coefficient_of_determination
    
    let (estimatingSlope, estimatingIntercept) = getLinearFitCoefficientsFromLeastSquaresMethod(x, y)
    let ybar = y.reduce(0.0, +)/Double(y.count)
    
    var sumOfResSquares = 0.0
    var totalSumOfSquares = 0.0
    
    for i in 0..<x.count {
        
        let f_i = x[i]*estimatingSlope + estimatingIntercept
        
        sumOfResSquares += (y[i] - f_i) * (y[i] - f_i)
        totalSumOfSquares += (y[i] - ybar) * (y[i] - ybar)
        
    }
    
    return 1.0 - sumOfResSquares/totalSumOfSquares
    
}

public func getLinearFitCoefficientsFromLeastSquaresMethod(_ x: [Double], _ y: [Double]) -> (Double, Double) {
    
//    Method from: https://www.varsitytutors.com/hotmath/hotmath_help/topics/line-of-best-fit

    
    let xbar = x.reduce(0.0, +)/Double(x.count)
    let ybar = y.reduce(0.0, +)/Double(y.count)
    
    var numerator = 0.0
    var denom = 0.0
    
    for i in 0..<x.count {
        
        numerator += (x[i] - xbar)*(y[i] - ybar)
        denom += (x[i] - xbar)*(x[i] - xbar)
    }
    
    let slope = numerator/denom
    let intercept = ybar - slope*xbar
    
    return (slope,intercept)
    
}


