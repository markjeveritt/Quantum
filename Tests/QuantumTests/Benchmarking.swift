//
//  Benchmarking.swift
//  
//
//  Created by George Tait on 09/10/2023.
//

import XCTest
@testable import Quantum

final class Benchmarking: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMatrixMultiplicationTimeComplexity() throws {
        
        let matMult: (_ A: Matrix<Double>, _ B: Matrix<Double>) -> Matrix<Double> = {A,B in return A * B}
        
        let dims = [32,64,100,200,400]
        let (omega, r_sq) = estimateTimeComplexity(dims: dims, operation: matMult)
    
        storeElapsedTimeDataToFile(dims: dims, operation: matMult, filename: "matMult.dat")
        
        
        print("\n")
        print("omega = \(String(format: "%.2f", omega))", "r_sq = \(String(format: "%.2f", r_sq))")
        print("\n")
        
    }

}
