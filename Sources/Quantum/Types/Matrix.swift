/*
 See notes in Spaces file
 
 Note that a matrix must live in a vector space.
 
 TODO: Optimise
 KEY:
 DCMM - divide and conquer matrix multiplication
 BFMM - brute force matrix multiplication
 SMM - strassen's matrix multiplication
 */
import Foundation
// Importantly (Liskov) Matrix can be a VectorType but it should not extend Vector.
public struct Matrix<T: Scalar>: VectorType, OperatorType {
    // to satisfy collection for use with integrators.
    public subscript(position: Int) -> ScalarField {
        return elements[position]
    }
    
    public typealias ScalarField = T
    public var space: VectorSpace<ScalarField>
    public var elements: [ScalarField]
    
    public init(elements: [T], in space: VectorSpace<T>) {
        assert(elements.count == (space.dimension * space.dimension), "Matrix is not the same dimension as the space")
        self.elements = elements
        self.space = space
    }
    init(in space: VectorSpace<T>) {
        self.elements = Array(repeating: ScalarField.zero, count: space.dimension * space.dimension)
        self.space = space
    }


    public subscript(row: Int, col: Int) -> ScalarField {
        
        get {
            let index = atIndex(row: row, column: col, nColumns: space.dimension )
            assert(index < elements.count, "Index out of range getting vector value")
            return elements[index]
        }
        set {
            let index = atIndex(row: row, column: col, nColumns: space.dimension )
            assert(index < elements.count, "Index out of range setting vector value")
            elements[index] = newValue
        }
    }
    
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < space.dimension && column >= 0 && column < space.dimension
    }
    
    public static func * (lhs: Self, rhs: Self) -> Self {

        return lhs.bruteForceMatrixMultiplication(rhs)
    }
    
    
    public func divideAndConquerMultiplication(_ rhs: Matrix<T>) -> Matrix<T> {
        assert(rhs.space == self.space)
        
        let dim = self.space.dimension
        if dim == 2 {return self.bruteForceMatrixMultiplication(rhs)}
        
        if dim % 2 != 0 {
            let paddedSpace = VectorSpace<T>(dimension: dim + 1, label: "padded space")
            let paddedlhs = self.addPaddingToGetEvenDimensions(paddedSpace: paddedSpace)
            let paddedrhs = rhs.addPaddingToGetEvenDimensions(paddedSpace: paddedSpace)
            
            return paddedlhs.divideAndConquerMultiplication(paddedrhs).removePadding(unpaddedSpace: self.space)
            
        }
        
        let quartetSpace = VectorSpace<T>(dimension: dim/2, label: "quartet space")
        let (a,b,c,d) = self.getDivideAndConquerQuartets(quartetSpace)
        let (e,f,g,h) = rhs.getDivideAndConquerQuartets(quartetSpace)
        
        let topLeft = a.divideAndConquerMultiplication(e) + b.divideAndConquerMultiplication(g)
        let topRight = a.divideAndConquerMultiplication(f) + b.divideAndConquerMultiplication(h)
        let bottomLeft = c.divideAndConquerMultiplication(e) + d.divideAndConquerMultiplication(g)
        let bottomRight = c.divideAndConquerMultiplication(f) + d.divideAndConquerMultiplication(h)
        
        return self.assembleDivideAndConquerResult(previousSpace: self.space, topLeft, topRight, bottomLeft, bottomRight)
        
        
    }
    
    public func bruteForceMatrixMultiplication(_ rhs: Matrix<T>) -> Matrix<T> {
        
        assert(rhs.space == self.space, "Cannot multiply two matrices of different spaces")
        
        var output = Self(in: self.space)
        let dim = self.space.dimension

        for i in 0 ..< dim {
            for j in 0 ..< dim {
                for k in 0 ..< dim {
                    output[i, j] = output[i, j] + self[i, k] * rhs[k, j]
                }
            }
        }
        return output
    }
    
    public func assembleDivideAndConquerResult(previousSpace: VectorSpace<T>, _ topLeft: Matrix<T>, _ topRight: Matrix<T>, _ bottomLeft: Matrix<T>, _ bottomRight: Matrix<T>) -> Matrix<T> {
        
        assert(topLeft.space == topRight.space && topRight.space == bottomLeft.space && bottomLeft.space == bottomRight.space)
        assert(topLeft.space.dimension == self.space.dimension/2)
        
        let dim = self.space.dimension
        
        var elementsOfReturnMatrix: [T] = []
        
        for i in 0..<dim/2 {
            elementsOfReturnMatrix += topLeft.elements[i*dim/2 ..< (i+1)*dim/2] + topRight.elements[i*dim/2 ..< (i+1)*dim/2]
        }
        
        for i in 0 ..< dim/2 {
           
            elementsOfReturnMatrix += bottomLeft.elements[i*dim/2 ..< (i+1)*dim/2] + bottomRight.elements[i*dim/2 ..< (i+1)*dim/2]
        }
        
        return Matrix<T>(elements: elementsOfReturnMatrix, in: previousSpace)
        
        
        
    }
    
    public func getDivideAndConquerQuartets(_ quartetSpace: VectorSpace<T>) -> (Matrix<T>, Matrix<T>, Matrix<T>, Matrix<T>) {
        
        let dim = self.space.dimension
        assert(dim % 2 == 0, "Cannot get quartet matrices for a space of odd dimensions")
    
        
        var topLeftElem: [T] = []
        var topRightElem: [T] = []
        var bottomLeftElem: [T] = []
        var bottomRightElem: [T] = []
        
        //can do each of the for-loops in parallel
        for i in 0..<dim/2 {
            topLeftElem += self.elements[i*dim ..< i*dim + dim/2]
            topRightElem += self.elements[i*dim + dim/2 ..< (i+1)*dim]
        }
        
        for i in dim/2 ..< dim {
            bottomLeftElem += self.elements[i*dim ..< i*dim + dim/2]
            bottomRightElem += self.elements[i*dim + dim/2 ..< (i+1)*dim]
            
        }
            
        
        let topLeft = Matrix<T>(elements: topLeftElem, in: quartetSpace)
        let topRight = Matrix<T>(elements: topRightElem, in: quartetSpace)
        let bottomLeft = Matrix<T>(elements: bottomLeftElem, in: quartetSpace)
        let bottomRight = Matrix<T>(elements: bottomRightElem, in: quartetSpace)
        
        return (topLeft, topRight, bottomLeft, bottomRight)
        
    }
    
    
    public func addPaddingToGetEvenDimensions(paddedSpace: VectorSpace<T>) -> Matrix<T> {
        
        assert(self.space.dimension % 2 == 1, "Space already has even dimensions")
        
        var temp = Matrix<T>(in: paddedSpace)
        
        for i in 0..<self.space.dimension {
            for j in 0..<self.space.dimension {
                temp[i,j] = self[i,j]
            }
        }
        
        return temp
    }
    
    public func removePadding(unpaddedSpace: VectorSpace<T>) -> Matrix<T> {
        
        assert(unpaddedSpace.dimension == self.space.dimension - 1, "Previous space must have dimension one fewer than current space")
        
        var removedPadding = Matrix<T>(in: unpaddedSpace)
        
        for i in 0..<unpaddedSpace.dimension {
            for j in 0..<unpaddedSpace.dimension {
                removedPadding[i,j] = self[i,j]
            }
        }
        
        return removedPadding
    }
    
    
    public static func * (lhs: Matrix<T>, rhs: Vector<T>) -> Vector<T> {
        checkInSameSpace(lhs,rhs)

        var output = Vector<T>(in: lhs.space)
        // there are much more efficent ways to do this - coding for calrity
        for i in 0 ..< lhs.space.dimension {
            for j in 0 ..< lhs.space.dimension {
                output[i] = output[i] + lhs[i, j] * rhs[j]
            }
        }
        return output
    }
    // Closed under scalar mutliplication w.r.t the scalar field over which it is defined
    public static func * (left: Self, right: ScalarField) -> Self {
        return Self(elements: scalarBinaryOperation(array: left.elements, by: right,operation: *), in: left.space)
    }
    public static func * (left: ScalarField, right: Self) -> Self {
        return Self(elements: scalarBinaryOperation(array: right.elements, by: left,operation: *), in: right.space)
    }
    public static func / (left: Self, right: ScalarField) -> Self {
        return Self(elements: scalarBinaryOperation(array: left.elements, by: right,operation: /), in: left.space)
    }
}

extension Matrix: CustomStringConvertible {
    public var description: String {
        var output = "Operator in space \(space.description) with identifier: \(space.identifier))\n"
        for i in 0 ..< self.space.dimension {
            for j in 0 ..< self.space.dimension {
                output.append("\(self[i, j])")
                if (j < self.space.dimension - 1) {
                    output.append(" , ")
                }
            }
            output.append("\n")
        }
        return output
    }
}
extension Matrix  {
    public func transpose () -> Matrix<ScalarField> {
        let dim = space.dimension
        var output = Self(in: self.space)
        for i in 0 ..< dim {
            for j in 0 ..< dim {
                output[j, i] = self[i, j]
            }
        }
        return output
    }
}


infix operator =~= : ComparisonPrecedence
extension Matrix where T: definedOverScalarField & Has_Abs, T.ScalarField: Comparable  {
    
    public static func =~= (lhs: Matrix<T>, rhs: Matrix<T>) -> Bool {
        return lhs.approximateEquals(rhs, testPrecision: 1.0e-6 )
    }
    public func approximateEquals(_ other: Matrix<T>, testPrecision: Double) -> Bool {
        let spacetest = self.space == other.space
        var valuestest = true
        for i in 0 ..< self.elements.count {
            let differnce = self.elements[i] - other.elements[i]
            let temptest = ScalarField.abs(differnce) < T.ScalarField(testPrecision)
            valuestest = valuestest && temptest
        }
        
        return spacetest && valuestest
    }
    
}

extension Matrix: providesDoubleAndIntMultiplication {}

extension Matrix where Self.ScalarField: ComplexNumber {
    public func hermitianAdjoint () -> Matrix<ScalarField> {
        let dim = space.dimension
        var output = Self(in: self.space)
        for i in 0 ..< dim {
            for j in 0 ..< dim {
                output[j, i] = self[i, j].conjugate
            }
        }
        return output
    }
}
//  Created by M J Everitt on 18/01/2022.

