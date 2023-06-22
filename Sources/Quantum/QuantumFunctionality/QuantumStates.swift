/*
 Contains code for generating the states needed to test and produce production
 figures for Jaynes Cummings model.
 
 In a production library would expand to contain a catalogue of standard states.
*/
 import Foundation

extension StateSpace {
    public func makeCoherentState(alpha: ScalarField) -> StateVector {
        
        var output = Vector(in: self)
        
        typealias R = ScalarField.ScalarField
        
        let prefactor = R.exp( -(alpha.modulus * alpha.modulus / R(2)) )

        output[0] = ScalarField(prefactor)
        for n in 1 ..< self.dimension {
            // avoid computing n! as this can get problematic
            output[n] = output[n-1] * alpha / R.sqrt(R(n))
        }
        return output
    }
    
    public func makeNumberState(_ n: Int) -> StateVector {
        var output = Vector(in: self)
        output[n] = ComplexReal(1)
        return output
    }
    
    public func makeVector(from input: [Real]) -> StateVector {
        let output = input.map( { ComplexReal($0) } )
        return Vector(elements: output, in: self)
    }
    
    public func makeVector(from input: [ComplexReal]) -> StateVector {
        return Vector(elements: input, in: self)
    }

}
//  Created by M J Everitt on 21/01/2022.

