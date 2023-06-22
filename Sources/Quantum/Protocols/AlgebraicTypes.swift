
/*
 Defines a number of protocols for dealing with operators and vectors.
 
 Note: Protocols such as ClosedUnderScalarFieldMultiplication help ensure
 DRY code as the notion of closed under scalar multiplication holds
 equivalently for vectors and operators alike.
 
 A current failure of DRY coding is the ComplexNumber protocol does not
 take advantage of this (this was not fixed within one week of coding
 time).
 
 TODO: ComplexNumber to use ClosedUnderScalarFieldMultiplication
 */

import Foundation


// See the Spaces section of "Adding Quantum Structure to the Code" in the book.
// This exists for good housekeeping - we should not be able to compose elements
// of different spaces together even if we could do so without a runtime error.
// this protocol, which is inherited by operator and vector types insures that
// we are able to make the necessary checks.

public protocol livesInAVectorSpace: definedOverScalarField {
    var space: VectorSpace<ScalarField> { get set }
}

public protocol OperatorType: ClosedUnderScalarFieldMultiplication,
                              Addable,
                              Subtractable,
                              Multipliable,
                              livesInAVectorSpace {
    static func * (lhs: Self, rhs: Vector<ScalarField>) -> Vector<ScalarField>
}

extension OperatorType {
    func commutator(with other: Self) -> Self {
        return (self * other) - (other * self)
    }
}

extension OperatorType {
    public func expectationValue(of psi: Vector<ScalarField>) -> ScalarField {
            checkInSameSpace(self, psi)
            return (self * psi).innerProduct(dualVector: psi)
    }
}
// Annoying this is needed to select the right inner product
// - this overrides above when conjugate needed in inner product (but not explicitly needed here)
extension OperatorType where Self.ScalarField: ComplexNumber {
    public func expectationValue(of psi: Vector<ScalarField>) -> ScalarField {
            checkInSameSpace(self, psi)
            return (self * psi).innerProduct(dualVector: psi)
    }
}

public protocol VectorArithmetic:    Addable,
                                     Negatable,
                                     Subtractable,
                                     livesInAVectorSpace,
                                     Hashable,
                                     ClosedUnderScalarFieldMultiplication {
}

public protocol VectorType: VectorArithmetic, Collection {
    var elements: [ScalarField] { get set }
    init(elements: [ScalarField], in space: VectorSpace<ScalarField>)
}

// add to vector collection conformance

extension VectorType {
    public var startIndex: Int { return 0 }
    public var endIndex: Int { return elements.count }
    public func index(after i: Int) -> Int {
        return i + 1
    }
}


/*
 Avoids code duplication as a matrix is also a vector type.

 We assume a square matrix (more pedantically it assumes we can
 get all the info we need to run from the vector space, in this
 case dimension). Can not ever remember needing a non-square matrix
 so this is a low risk assumption.
 
 If the need arises will need to hack VectorSpace to accommodate
 the extra requirement.
 */

extension VectorType {    
    // closed under addition
    public static func + (lhs: Self, rhs: Self) -> Self {
        checkInSameSpace(lhs,rhs)
        let output = elementWiseBinaryOperation(thisArry: lhs.elements,
                                                thatArray: rhs.elements,
                                                operation: +
                                                )
        return Self(elements: output, in: lhs.space)
    }
    // closed under subtraction
    public static func - (lhs: Self, rhs: Self) -> Self {
        checkInSameSpace(lhs,rhs)
        let output = elementWiseBinaryOperation(thisArry: lhs.elements,
                                                thatArray: rhs.elements,
                                                operation: -
                                                )
        return Self(elements: output, in: lhs.space)
    }
    // negatable (has additive inverse)
    public static prefix func - (value: Self) -> Self {
        let output = elementWisePrefixOperation(array: value.elements, operation: - )
        return Self(elements: output, in: value.space)
    }
}

// MARK: - Enable double * and / For use with Complex Types
public protocol providesDoubleAndIntMultiplication: ClosedUnderScalarFieldMultiplication {
}

extension providesDoubleAndIntMultiplication  {
    public static func * (left: Self, right: Double) -> Self {
        return left * ScalarField(right)
    }
    public static func * (left: Double, right: Self) -> Self {
        return ScalarField(left) * right
    }
    public static func / (left: Self, right: Double) -> Self {
        return left / ScalarField(right)
    }
    public static func * (left: Self, right: Int) -> Self {
        return left * ScalarField(right)
    }
    public static func * (left: Int, right: Self) -> Self {
        return ScalarField(left) * right
    }
    public static func / (left: Self, right: Int) -> Self {
        return left / ScalarField(right)
    }
}
//  Created by M J Everitt on 17/01/2022.
