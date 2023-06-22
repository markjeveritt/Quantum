/*
 Decides the precision of much of the generic code in one place
 to save the end user from having to do this.

 The intention for introducing these, especially StateVector and
 MatrixOperator, was to make the code more readable. On reflection,
 this may not have been a wise choice and will be considered again
 as the code evolves.

 We could have either stuck with generics or a fixed precision.
 Need to revaluate the need for this code if e.g. migrating to the
 use of Numerics package.

 A deviation from the content of the book is that we are not using
 UTF characters such as ℝ for real.
*/
import Foundation

public typealias Real = Double
public typealias ComplexReal = Complex<Real>
public typealias StateVector = Vector<Complex<Real>>
public typealias MatrixOperator = Matrix<Complex<Real>>



//  Created by DOCTOR M J Everitt on 21/01/2022.

