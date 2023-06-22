/*
 For guaranteeing a struct has a standard functions available to it.
 
 The main intention was to use this with number types but matrices
 can also take advantage of many of these.
*/


import Foundation
public protocol Has_Sqrt {
    static func sqrt(_ x: Self) -> Self
}
public protocol Has_Sin {
    static func sin(_ x: Self) -> Self
}
public protocol Has_Cos {
    static func cos(_ x: Self) -> Self
}
public protocol Has_Exp {
    static func exp(_ x: Self) -> Self
}

public protocol Has_Abs: definedOverScalarField {
    static func abs(_ x: Self) -> ScalarField
}
public protocol Has_Pow {
    static func pow(_ x: Self, _ y: Self) -> Self
}

public protocol Has_Atan {
    static func atan(_ x: Self) -> Self
    static func atan2(_ x: Self,_ y: Self) -> Self
}


//  Created by M J Everitt on 17/01/2022.
