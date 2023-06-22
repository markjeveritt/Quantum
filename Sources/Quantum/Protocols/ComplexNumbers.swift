/*
 A protocol for complex numbers.
 
 On reflection, this is not quite granular enough to to allow
 flexible use. If we wanted to define e.g. complex numbers over just
 the integers, then we would need a protocol that did not allow
 dividable.
 
 This protocol, however, is fit for purpose, just not the initial
 ambition of making it as flexible/extensible as possible.
 
 Maybe there could even be a compound number protocol - something
 to consider at a later date.
 
 Note doing more with protocols on re-write of library as this should mean
 that it is easier to change from our Complex Structure to other
 implementations such as in the Swift numerics package.
*/

import Foundation
// MARK: - Complex number protocols


public protocol ComplexNumber: Scalar & definedOverScalarField {
    
    var real: ScalarField { get set }
    var imag: ScalarField { get set }
    
    init(real: ScalarField, imag: ScalarField)
    init(real: ScalarField)
}

extension ComplexNumber {
    // Could get rid of the need to cast to ScalarField by making its Scalar & ExpressibleByIntegerLiteral
    public init(_ realValue: Int) { self.init(real: ScalarField(realValue), imag: ScalarField(0) ) }
    public init(_ realValue: Double) { self.init(real: ScalarField(realValue), imag: ScalarField(0) ) }

    public var conjugate: Self { return Self(real: self.real, imag: -self.imag ) }

    // Conform to Scalar protcol
    public static func + (lhs: Self, rhs: Self) -> Self {
        return Self(real: lhs.real + rhs.real , imag: lhs.imag + rhs.imag )
    }
    public static func - (lhs: Self, rhs: Self) -> Self {
        return Self(real: lhs.real - rhs.real , imag: lhs.imag - rhs.imag )
    }
    public static prefix func - (value: Self) -> Self {
        return Self(real: -value.real, imag: -value.imag)
    }
    public static func * (lhs: Self, rhs: Self) -> Self {
        return Self(real: lhs.real * rhs.real - lhs.imag * rhs.imag,
                    imag: lhs.real * rhs.imag + lhs.imag * rhs.real)
    }
    public static func / (lhs: Self, rhs: Self) -> Self {
        let denominator = rhs.real * rhs.real + rhs.imag * rhs.imag
            
        return Self(real: (lhs.real * rhs.real + lhs.imag * rhs.imag) / denominator,
                    imag: (lhs.imag * rhs.real - lhs.real * rhs.imag) / denominator)
    }
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return (lhs.real == rhs.real) && (lhs.imag == rhs.imag)
    }

    public static func + (lhs: Self, rhs: Self.ScalarField) -> Self {
        return Self(real: lhs.real + rhs , imag: lhs.imag)
    }
    public static func + (lhs: Self.ScalarField, rhs: Self) -> Self {
        return Self(real: lhs + rhs.real , imag: rhs.imag )
    }

    public static func - (lhs: Self, rhs: Self.ScalarField) -> Self {
        return Self(real: lhs.real - rhs , imag: lhs.imag )
    }
    public static func - (lhs: Self.ScalarField, rhs: Self) -> Self {
        return Self(real: lhs - rhs.real , imag: -rhs.imag )
    }

    public static func * (lhs: Self, rhs: Self.ScalarField) -> Self {
        return Self(real: lhs.real * rhs, imag: lhs.imag * rhs)
    }
    public static func * (lhs: Self.ScalarField, rhs: Self) -> Self {
        return Self(real: lhs * rhs.real, imag: lhs * rhs.imag )
    }

    public static func / (lhs: Self, rhs: Self.ScalarField) -> Self {
        return Self(real: lhs.real / rhs, imag: lhs.imag / rhs)
    }
}

extension ComplexNumber {
    public var norm: ScalarField { return self.real * self.real + self.imag * self.imag }
}

extension ComplexNumber where Self.ScalarField: Has_Sqrt {
    public var modulus: ScalarField { return ScalarField.sqrt(self.norm) }
}

extension ComplexNumber where Self.ScalarField: Has_Atan {
    public var argument: ScalarField {
        return ScalarField.atan2(imag,real) }
}

extension ComplexNumber where Self.ScalarField: Has_Exp {
    public static func exp(_ x: ScalarField) -> Self {
        return( Self(real: ScalarField.exp(x), imag: ScalarField(0) ) )
    }
}


//  Created by M J Everitt on 17/01/2022.

