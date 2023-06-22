/*
 See notes in Spaces file
 
 TODO: Optimise
 */

import Foundation

public struct Vector<T: Scalar>: VectorType {

    
    public typealias ScalarField = T
    public var space: VectorSpace<T>
    public var elements: [T]
    
    public init(elements: [T], in space: VectorSpace<T>) {
        assert(elements.count == space.dimension, "Array is not the same dimension as the space")
        self.elements = elements
        self.space = space
    }
    public init(in space: VectorSpace<T>) {
        self.elements = Array(repeating: ScalarField.zero, count: space.dimension)
        self.space = space
    }
    public subscript(index: Int) -> ScalarField {
        get {
            assert(index < elements.count, "Index out of range getting vector value")
            return elements[index]
        }
        set {
            assert(index < elements.count, "Index out of range setting vector value")
            elements[index] = newValue
        }
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

extension Vector: CustomStringConvertible {
    public var description: String {
        var output = "Vector in space \(space.description) with identifier: \(space.identifier)\n"
        for value in elements {
            output.append("\(value)\n")
        }
        return output
    }
}

extension Vector  {
    public func innerProduct(dualVector: Self) -> ScalarField {
        var sum = T.zero
        checkInSameSpace(self, dualVector)
        for i in 0 ..< elements.count {
            sum =  sum + elements[i] *  dualVector[i]
        }
        return sum
    }
}
// Anoying this is needed to select the right inner product
// - this overides above when congugate needed in inner product
extension Vector where T: ComplexNumber {
    public func innerProduct(dualVector: Self) -> T {
        var sum = T.zero
        checkInSameSpace(self, dualVector)
        for i in 0 ..< elements.count {
            sum =  sum + self[i] *  (dualVector[i].conjugate)
        }
        return sum
    }

}

extension Vector {
    public func outerProduct(with v: Self) -> Matrix<T> {
        assert (self.space == v.space)
        var output = Matrix(in: self.space)
        for i in 0 ..< elements.count {
            for j in 0 ..< elements.count {
                output[i,j] = self[i] * v[j]
            }
        }
        return output
    }
}
extension Vector where T: ComplexNumber {
    public func outerProduct(with v: Self) -> Matrix<T> {
        assert (self.space == v.space)
        var output = Matrix(in: self.space)
        for i in 0 ..< elements.count {
            for j in 0 ..< elements.count {
                output[i,j] = self[i] * v[j].conjugate
            }
        }
        return output
    }
}



extension Vector: providesDoubleAndIntMultiplication {}

//  Created by M J Everitt on 18/01/2022.
