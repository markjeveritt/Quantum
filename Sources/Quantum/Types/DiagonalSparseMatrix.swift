//
//  DiagonalSparseMatrix.swift
//  
//
//  Created by George Tait on 14/02/2024.
//

import Foundation


public struct DiagonalSparseMatrix<T: Scalar>: OperatorType {
    
    public typealias ScalarField = T
    public var space: VectorSpace<T>
    var diagonals: [Int: MatrixDiagonal<T>]
     
    
    public subscript (diagIdx: Int) -> MatrixDiagonal<T>? {
        
        get {
            if let diag = self.diagonals[diagIdx] {
                return diag
            }
            return nil
        }
        
        set {
            self.diagonals[diagIdx] = newValue
        }
    }
    
    public subscript (row: Int, col: Int) -> T? {
        
        get {
            let diagIdx = col - row
            
            guard let diag = self.diagonals[diagIdx] else { return nil }
            guard let val = diag[row] else {return nil}
            
            return val
        }
        
        set {
            let diagIdx = col - row
            
            self.diagonals[diagIdx]?.elements[row] = newValue
        }
    }
    
    
    
    public init(in space: VectorSpace<T>, diagonals: [Int : MatrixDiagonal<T>]) {
        self.space = space
        self.diagonals = diagonals
    }
    
    public init(in space: VectorSpace<T>) {
        self.space = space
        self.diagonals = [:]
        
    }
    
    public init(from matrix: Matrix<T>) {
        
        self.space = matrix.space
        self.diagonals = [:]
        let dim = matrix.space.dimension
        
        for diagIdx in 1-dim...dim-1 {
            
            var currDiag: MatrixDiagonal<T>? = nil
            let (rowLowerLim, rowUpperLim) = getRowLimits(dim: dim, diagIdx: diagIdx)
            
            for row in rowLowerLim...rowUpperLim {
                
                if matrix[row, row+diagIdx] == T(0) {continue}
                
                if currDiag == nil {
                    currDiag = MatrixDiagonal(dimension: dim, diagIdx: diagIdx, elements: [row: matrix[row, row+diagIdx]])
                    continue
                }
                
                currDiag![row] = matrix[row, row+diagIdx]
                
            }
            
            if currDiag != nil {
                self.diagonals[diagIdx] = currDiag
            }
        }
        
        
    }
    
    
    public static func / (left: DiagonalSparseMatrix<T>, right: T) -> DiagonalSparseMatrix<T> {
        var output = Self(in: left.space)
        output.diagonals = left.diagonals.mapValues({$0 / right})
        return output
    }
    
    public static func * (left: T, right: DiagonalSparseMatrix<T>) -> DiagonalSparseMatrix<T> {
        var output = Self(in: right.space)
        output.diagonals = right.diagonals.mapValues({$0 * left})
        return output
    }
    
    public static func * (left: DiagonalSparseMatrix<T>, right: T) -> DiagonalSparseMatrix<T> {
        var output = Self(in: left.space)
        output.diagonals = left.diagonals.mapValues({$0 * right})
        return output
    }
    
    
    public static func * (lhs: DiagonalSparseMatrix<T>, rhs: Vector<T>) -> Vector<T> {
        
        var output = Vector(in: lhs.space)
        for i in 0..<output.count {
            for (lhsDiagIdx, lhsDiag) in lhs.diagonals {
                guard let lhsVal = lhsDiag[i] else {continue}
                
                let column = i + lhsDiagIdx
                if (column >= 0 && column < output.count) {
                    output[i] = output[i] + lhsVal * rhs[column]
                }
                
            }
        }
        
        return output
    }
    
    

    
    public static func + (lhs: DiagonalSparseMatrix<T>, rhs: DiagonalSparseMatrix<T>) -> DiagonalSparseMatrix<T> {
        assert(lhs.space == rhs.space,
               "Cannot add sparse matrices from different spaces")
        
        var output = DiagonalSparseMatrix(in: lhs.space, diagonals: lhs.diagonals)
        
        for (rhsDiagIdx, rhsDiag) in rhs.diagonals {
            guard let lhsDiag = output[rhsDiagIdx] else { output[rhsDiagIdx] = rhsDiag; continue}
            output[rhsDiagIdx] =  lhsDiag + rhsDiag
        }
        return output
    }
    
    
    
    public static func - (lhs: DiagonalSparseMatrix<T>, rhs: DiagonalSparseMatrix<T>) -> DiagonalSparseMatrix<T> {
        assert(lhs.space == rhs.space,
               "Cant multiply sparse matrices from different spaces")
        
        var output = DiagonalSparseMatrix(in: lhs.space, diagonals: lhs.diagonals)
        
        for (rhsDiagIdx, rhsDiag) in rhs.diagonals {
            guard let lhsDiag = output[rhsDiagIdx] else { output[rhsDiagIdx] = T(-1) * rhsDiag; continue}
            output[rhsDiagIdx] = lhsDiag - rhsDiag
        }
        return output
    }
    
    public static func * (lhs: DiagonalSparseMatrix<T>, rhs: DiagonalSparseMatrix<T>) -> DiagonalSparseMatrix<T> {
        assert(lhs.space == rhs.space,
               "Cant multiply sparse matrices from different spaces")
        
        var output = DiagonalSparseMatrix(in: lhs.space)
        let dim = lhs.space.dimension
        
        
        for (lhsDiagIdx, lhsDiag) in lhs.diagonals {
            for (rhsDiagIdx, rhsDiag) in rhs.diagonals {
                let currIdx = lhsDiagIdx + rhsDiagIdx
                
                if currIdx <= -dim || currIdx >= dim {continue}
                
                let currDiag = lhsDiag * rhsDiag
                
                if let _ = output[currIdx] {
                    output[currIdx]! += currDiag
                    continue
                }
                
                output[currIdx] = currDiag
                
            }
        }
        
        return output

    }
    
    
}

extension Matrix {
    public init (from diagonalSparseMatrix: DiagonalSparseMatrix<T>) {
        space = diagonalSparseMatrix.space
        
        elements = [T](repeating: T(0), count: space.dimension*space.dimension)
        
        for (diagIdx, diag) in diagonalSparseMatrix.diagonals {
            
            for (rowIdx, element) in diag.elements {
                elements[rowIdx*space.dimension + rowIdx + diagIdx] = element
            }
            
        }
        
    }
}


public struct MatrixDiagonal<T: Scalar> {
    
    
    public typealias ScalarField = T
    var dimension: Int
    var diagIdx: Int
    var rowLowerLim: Int
    var rowUpperLim: Int
    var elements: [Int: T]
    
    
    public init(dimension: Int, diagIdx: Int, elements: [Int : T]) {
        
        self.diagIdx = diagIdx
        self.elements = elements
        self.dimension = dimension
        
        if diagIdx <= -dimension || diagIdx >= dimension {
            self.rowLowerLim = 0
            self.rowUpperLim = 0
            self.elements = [:]
            return
        }
        if diagIdx <= 0 {
            self.rowLowerLim = -diagIdx
            self.rowUpperLim = dimension-1
            
            return
        }
        
        self.rowLowerLim = 0
        self.rowUpperLim = dimension-diagIdx-1
    }
    
    public subscript (row: Int) -> T? {
        
        get {
            
            if let val = self.elements[row] {
                return val
            }
            
            return nil
            
        }
        
        set {
            assert(row >= rowLowerLim && row <= rowUpperLim)
            self.elements[row] = newValue
        }
    }
    
      public static func += (lhs: inout MatrixDiagonal, rhs: MatrixDiagonal) {
        
        //assume lhs.diagIdx = rhs.DiagIdx.
        //want to change this to use += as a mutating operator
        
        for (row,val) in rhs.elements {
            
            
            if let lhsVal = lhs[row] {
                lhs[row] = lhsVal + val
                continue
            }
            
            lhs[row] = val
        }
        
        
    }
    
    public static func + (lhs: MatrixDiagonal, rhs: MatrixDiagonal) -> MatrixDiagonal {
        assert(lhs.diagIdx == rhs.diagIdx, "Cannot add matrix diagonals of different diagonal indices.")
        
        var output = lhs
        
        for (row,val) in rhs.elements {
            
            
            if let lhsVal = output[row] {
                output[row] = lhsVal + val
                continue
            }
            
            output[row] = val
        }
        
        return output
    
    }
    
    public static func - (lhs: MatrixDiagonal,rhs: MatrixDiagonal) -> MatrixDiagonal {
        
    var output = lhs
    
    for (row,rhsVal) in rhs.elements {
        
        if let lhsVal = output[row] {
            output[row] = lhsVal - rhsVal
            continue
        }
        
        output[row] = -rhsVal
    }
    
    return output
        
    }
    
    public static func * (lhs: MatrixDiagonal,rhs: MatrixDiagonal) -> MatrixDiagonal {
        
        //assumed that the outputDiagIdx is always valid, that is, outputDiagIdx > -dim && outputDiagIdx < dim.
        //This condition will be checked in the multiplication of two DiagonalSparseMatrix types.
        
        let lhsDiagIdx = lhs.diagIdx
        let rhsDiagIdx = rhs.diagIdx
        let outputDiagIdx = lhsDiagIdx + rhsDiagIdx
        
        let dim = lhs.dimension

        var output = MatrixDiagonal(dimension: dim, diagIdx: outputDiagIdx, elements: [:])
        
        for (row, val) in lhs.elements {
            
            if let rhsVal = rhs[row + lhsDiagIdx] {
                output[row] = val*rhsVal
            }
        }
        
        return output
        
    }
    
    public static func * (lhs: MatrixDiagonal, rhs: T) -> Self {
        
        return Self(dimension: lhs.dimension, diagIdx: lhs.diagIdx, elements: lhs.elements.mapValues({$0 * rhs}))
    }
    
    public static func * (lhs: T, rhs: MatrixDiagonal) -> Self {
        
        return Self(dimension: rhs.dimension, diagIdx: rhs.diagIdx, elements: rhs.elements.mapValues({$0 * lhs}))
    }
    
    public static func / (lhs: MatrixDiagonal, rhs: T) -> Self {
        
        return Self(dimension: lhs.dimension, diagIdx: lhs.diagIdx, elements: lhs.elements.mapValues({$0 / rhs}))
    }
    
    
    public func tensorProductWithIdentityFromLeft(ofDimension dim: Int) -> MatrixDiagonal {
        
        let outputDim = self.dimension*dim
        let outputDiagIdx = diagIdx
        
        var output = MatrixDiagonal(dimension: outputDim, diagIdx: outputDiagIdx, elements: [:])
        
        var rowBlockIdx: Int
        var colBlockIdx: Int
        var rowInSelf: Int
        
        for row in output.rowLowerLim...output.rowUpperLim {
            
            rowBlockIdx = row/dim
            colBlockIdx = (row + outputDiagIdx)/dim
            
            if rowBlockIdx != colBlockIdx {continue}
            
            rowInSelf = row % dim
            if let val = self[rowInSelf] {
                output[row] = val
            }
            
        }
            
        return output
    }
    
    public func tensorProductWith(_ rhs: MatrixDiagonal) -> MatrixDiagonal<T> {
        
        let rhsDim = rhs.dimension
        let outputDim = self.dimension * rhsDim
        let outputDiagIdx = diagIdx*rhsDim + rhs.diagIdx
        var output = MatrixDiagonal(dimension: outputDim, diagIdx: outputDiagIdx, elements: [:])
        
        
        let (rowBlockLowerLim, rowBlockUpperLim) = getRowLimits(dim: self.dimension, diagIdx: diagIdx)
        
        for rowBlock in rowBlockLowerLim...rowBlockUpperLim {
            
            guard let lhsVal = self[rowBlock] else {continue}
            
            var rowInOutput: Int
            
            let (rowInBlockLowerLim, rowInBlockUpperLim) = getRowLimits(dim: rhsDim, diagIdx: rhs.diagIdx)
            
            for rowInBlock in rowInBlockLowerLim...rowInBlockUpperLim {
                
            
                guard let rhsVal = rhs[rowInBlock] else {continue}
                
                rowInOutput = rowBlock * rhsDim + rowInBlock
                
                output[rowInOutput] = lhsVal * rhsVal
            }
        }
        
        return output
    }
    
    
    
    
    
    
}

