// An example of a class that can solve the time dependent Schrödinger equation for a time independent Hamiltonian (for sparse or dense cases).

import Foundation
open class TimeIndependentSchrodingerSystem {
    public var Psi: StateVector
    public var minus_i_H: MatrixOperator
    public var time: Real
    
    public init(initialstate: StateVector,
                hamiltonian: MatrixOperator) {
        let minusi = ComplexReal( real: 0.0, imag: -1.0 )
        time = 0.0
        Psi = initialstate
        minus_i_H = minusi * hamiltonian
    }
    
    open func schrodingerEquation(time: Real,
                                  psi: StateVector)
        -> StateVector {
            if(sparse) {
                return sparse_minus_i_H! * psi
            } else {
                return minus_i_H * psi
            }
    }
    
    public var sparse = false
    public var sparse_minus_i_H: SparseMatrix<ComplexReal>?
    open func useSparseAlgebra() {
        sparse = true
        sparse_minus_i_H = SparseMatrix(from: minus_i_H)
    }
    public func useNonSparseAlgebra() {
        sparse = false
    }

    public func evolve(by dt: Real) {
        multiStepIvpIntegrator(from: time,
                               to: time + dt,
                               first_try_of_stepsize: dt,
                               smallest_allowed_value_of_stepsize: 1.0e-8,
                               accuracy: 10e-6,
                               y: &Psi,
                               derivative_function: schrodingerEquation)
        /*
            More sophisticated versions of this class might allow one to choose which
            integrator to use as we could replace the above with e.g.
         
                  Psi = doRungeKuttaStep(t: time,
                                         h: dt,
                                         y: Psi,
                                         derivative_function: schrodingerEquation)
        */
        time += dt
    }
}
//  Created by M J Everitt on 21/01/2022.
