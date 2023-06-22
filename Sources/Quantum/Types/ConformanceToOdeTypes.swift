/*
 My approach to solving ODE's seeks to take advantage of The Dependency
 Inversion Principle and describes in the Dynamics subsection of A Small
 Generic Quantum Library.
 
 This means there is quite a bit of work upfront, but that the integration
 routines should never need rewriting once they are complete.
 */


import Foundation

// MARK: - Array Conformance

extension Array: DefinedOverOdeScalar where Array.Element: definedOverScalarField {
    public typealias OdeScalar = Element.ScalarField
}

extension Array: OdeAddable where Array.Element: Addable {
    public static func odeAdd(lhs: Self, rhs: Self) -> Self {
        return zip(lhs,rhs).map(+)
    }
}
extension Array: OdeScalarMultipliable where Array.Element: ClosedUnderScalarFieldMultiplication {
    public static func odeMultiply(scalar lhs: OdeScalar,
                                   integrand rhs: Self) -> Self {
        return rhs.map { $0 * lhs }
    }
}

extension Array: OdeIntegrable where
                 Array.Element: Multipliable &
                                Addable &
                                ClosedUnderScalarFieldMultiplication {}

extension Array: OdeMultStepIntegrable  where
                    Array.Element:  Has_Abs &
                                    Addable &
                                    Multipliable &
                                    ClosedUnderScalarFieldMultiplication {
    public static func ode_abs(of value: Element) -> Element.ScalarField {
        return Self.Element.abs(value)
    }
}

// MARK: - Vector Conformance

extension Vector: OdeAddable  {
  public static func odeAdd(lhs: Self,
                            rhs: Self) -> Self {
    return lhs + rhs // already overloaded for this
  }
}

extension Vector: DefinedOverOdeScalar where T: definedOverScalarField {
    public typealias OdeScalar = T.ScalarField
}

extension Vector: OdeScalarMultipliable  where T: definedOverScalarField & Has_ScalarInit {
    // TODO: emove need to cast to T
    public static func odeMultiply(scalar lhs: OdeScalar, integrand rhs: Vector<T>) -> Vector<T> {
        return T(lhs) * rhs
    }
}

extension Vector: OdeIntegrable where T: definedOverScalarField & Has_ScalarInit {}

extension Vector: OdeMultStepIntegrable where T: Has_Abs & Has_ScalarInit{
    public static func ode_abs(of value: T) -> T.ScalarField {
        return T.abs(value)
    }
}
//  Created by M J Everitt on 21/01/2022.
