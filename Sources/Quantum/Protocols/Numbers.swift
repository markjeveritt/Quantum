/*
 Code for dealing with scalar types. this was written before I became aware
 of Numerics and shares much in common. There are some differences between
 implementations.
 
 Consideration should be given as to weather or not to migrate to Numerics as it
 is now part of the standard packages.
 
 Consideration should also be given to making use of standard protocols such as
 AdditiveArithmetic where possible.
 
 This is an internal/vs external dependency issue and so the choice is not as
 clear as it may at first appear.
 */
import Foundation

// MARK: - Basic Definitions

// At the moment I prefer these over built-in types such as Numeric as
// I have control over interface segregation.

public protocol Addable     {
    static func + (lhs: Self, rhs: Self) -> Self
}

public protocol Multipliable  {
    static func * (lhs: Self, rhs: Self) -> Self
}

public protocol Subtractable {
    static func - (lhs: Self, rhs: Self) -> Self
}

public protocol Negatable {
    // +ve integers are subtractable but not negatable
    static prefix func - (value: Self) -> Self
}

public protocol Dividable    {
    static func / (lhs: Self, rhs: Self) -> Self
}

// MARK: - Protocols that enable functionality

public protocol Has_IntegerInitializer { init(_: Int) }
public protocol Has_DoubleInitializer { init(_: Double) }

public protocol Has_getMultiplicativeIdentity  {
    static func getMultiplicativeIdentity() -> Self
}

extension Has_getMultiplicativeIdentity {
    public static var one: Self { return Self.getMultiplicativeIdentity() }
}

extension Has_getMultiplicativeIdentity where Self: Has_IntegerInitializer {
    public static func getMultiplicativeIdentity() -> Self {
        return Self(1)
    }
}

public protocol Has_getAdditiveIdentity {
    static func getAdditiveIdentity() -> Self
}

extension Has_getAdditiveIdentity {
    public static var zero: Self { return Self.getAdditiveIdentity() }
}

extension Has_getAdditiveIdentity where Self: Has_IntegerInitializer {
    public static func getAdditiveIdentity() -> Self {
        return Self(0)
    }
}


// MARK: - Compound protcols

// Note Hashable implies Equitable
public protocol NaturalNumberLike: Addable,
                                   Multipliable,
                                   Subtractable,
                                   Has_IntegerInitializer,
                                   Has_getMultiplicativeIdentity,
                                   Hashable {}

public protocol PositiveIntegerLike: NaturalNumberLike,
                                     Has_getAdditiveIdentity {}

public protocol IntegerLike: PositiveIntegerLike,
                             Negatable {}

public protocol Scalar: IntegerLike, Has_DoubleInitializer,
                        Dividable {}


// MARK: - Number types with certain computed properties

public protocol definedOverScalarField {
    associatedtype ScalarField: Scalar
}

public protocol Has_ScalarInit: definedOverScalarField {
    init(_ : Self.ScalarField)
}

public protocol ClosedUnderScalarFieldMultiplication: definedOverScalarField {
    static func * (left: Self, right: ScalarField) -> Self
    static func * (left: ScalarField, right: Self) -> Self
    static func / (left: Self, right: ScalarField) -> Self
}

// MARK: - Extensions

public extension Multipliable {
    // https://en.wikipedia.org/wiki/Exponentiation_by_squaring#Basic_method
    func power(_ n: UInt, identity: Self) -> Self {
        // we dont know unit of Self but could use protocols
        //assert(n >= 1)
        func exp_by_squaring (_ x: Self,_ n: UInt) -> Self {
            if n == 0 {
                return identity
            } else if n == 1 {
                return x
            } else if n.isMultiple(of: 2) {
                return exp_by_squaring(x * x,  n / 2)
            } else {
                return x * exp_by_squaring(x * x, (n - 1) / 2)
            }
        }
        return exp_by_squaring(self, n)
    }
}

public extension Multipliable where Self: Has_getMultiplicativeIdentity {
    func power(_ n: UInt) -> Self {
        self.power(n,identity: Self.getMultiplicativeIdentity())
    }
}

//  Created by M J Everitt on 17/01/2022.



