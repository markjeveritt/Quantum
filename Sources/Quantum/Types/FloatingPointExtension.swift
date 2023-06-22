/*
 Extensions to make built in types work with my protocols.

 It would be nice to add high and maybe arbitrary precession arithmetic in future versions.
 */


import Foundation
// Consider migrating to Numerics once it is fully supported.

// Cant seem to do better than this - its roughly the same approach as used in Swift Numerics
// Dont like the fact that code needs to be duplicated (its not very DRY).

extension Double: Scalar, definedOverScalarField {
    public typealias ScalarField = Self 
}
extension Double: ClosedUnderScalarFieldMultiplication {
    
}

extension Double: Has_Exp & Has_Sin & Has_Cos & Has_Atan & Has_Sqrt & Has_Abs & Has_Pow {
    // It is annoying that Swift needs this for trig
    // but not for arithmetic functions.
    public static func pow(_ x: Self, _ y: Self) -> Self { return Foundation.pow(x,y) }

    public static func sin(_ x: Self) -> Self { return Foundation.sin(x) }
    
    public static func cos(_ x: Self) -> Self { return Foundation.cos(x) }
    
    public static func exp(_ x: Self) -> Self { return Foundation.exp(x) }
    
    public static func sqrt(_ x: Self) -> Self
     { return Foundation.sqrt(x) }

    public static func atan(_ x: Self) -> Self { return Foundation.atan(x) }

    public static func atan2(_ x: Self,_ y: Self) -> Self {
        return Foundation.atan2(x, y)
    }
    public static func abs(_ x: Self) -> Self { return x.magnitude }
}

extension Float32: Scalar, definedOverScalarField {
    public typealias ScalarField = Self
}

extension Float32: Has_Exp & Has_Sin & Has_Cos & Has_Atan & Has_Sqrt & Has_Abs & Has_Pow {
    // It is annoying that Swift needs this for trig
    // but not for arithmetic functions.
    public static func pow(_ x: Self, _ y: Self) -> Self { return Foundation.pow(x,y) }

    public static func sin(_ x: Self) -> Self { return Foundation.sin(x) }
    
    public static func cos(_ x: Self) -> Self { return Foundation.cos(x) }
    
    public static func exp(_ x: Self) -> Self { return Foundation.exp(x) }
    
    public static func sqrt(_ x: Self) -> Self
     { return Foundation.sqrt(x) }

    public static func atan(_ x: Self) -> Self { return Foundation.atan(x) }

    public static func atan2(_ x: Self,_ y: Self) -> Self {
        return Foundation.atan2(x, y)
    }
    public static func abs(_ x: Self) -> Self { return x.magnitude }
}

//  Created by M J Everitt on 17/01/2022.
