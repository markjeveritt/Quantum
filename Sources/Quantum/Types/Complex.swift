/*
 See ComplexNumber protocol for much of the functionality.
 
 The idea of using protocols was to enable more future flexibility.
 This may have been unnecessary on reflection.
 
 Note: struct goes directly on the stack so as well as been data
 type (avoiding sharing of state issues) so it avoids the heap.
 */
import Foundation


public struct Complex<T: Scalar>: ComplexNumber, Has_ScalarInit {
    public init(_ r: T) {
        self.init(real: r)
    }
    
    public init(real: T) {
        self.real = real
        self.imag = T.zero
    }
    
    public typealias ScalarField = T

    public var real: T
    public var imag: T 
        
    public init(real: T, imag: T) {
        self.real = real
        self.imag = imag
    }
}

extension Complex where T: Has_Sin & Has_Cos {
    public init (modulus: Self.ScalarField, argument: Self.ScalarField) {
        self.init(real: modulus * Self.ScalarField.cos(argument),
                  imag: modulus * Self.ScalarField.sin(argument))
    }
}

extension Complex: CustomStringConvertible {
    public var description: String {
        return "\(real) + \(imag) i"
    }
}
extension Complex: Has_Exp where T: Has_Exp & Has_Cos & Has_Sin {
    public static func exp(_ x: Self) -> Self {
        let realExp = ScalarField.exp( x.real )
        return( Self(real: realExp * ScalarField.cos(x.imag),
                     imag: realExp * ScalarField.sin(x.imag)) )
    }
}
extension Complex: Has_Sqrt where T: Has_Exp & Has_Cos & Has_Sin & Has_Atan & Has_Sqrt {
    public static func sqrt(_ x: Self) -> Self {
        return Self(modulus: T.sqrt(x.modulus), argument: x.argument / T(2) )
    }
}
extension Complex: Has_Abs where T: Has_Sqrt {
    public static func abs(_ x: Complex<T>) -> T {
        return x.modulus
    }
}
//  Created by M J Everitt on 16/01/2022.
