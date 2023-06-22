/*
 See notes in Spaces file
 
 Note that a matrix must live in a vector space.
 
 TODO: Optimise
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

        var output = Self(in: lhs.space)
        let dim = lhs.space.dimension
        // there are much more efficient ways to do this - coding for clarity
        for i in 0 ..< dim {
            for j in 0 ..< dim {
                for k in 0 ..< dim {
                    output[i, j] = output[i, j] + lhs[i, k] * rhs[k, j]
                }
            }
        }
        return output
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
