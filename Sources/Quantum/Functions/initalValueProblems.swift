/*
 The idea for this approach is that the same integrators can be used for very many
 different types. This might include collections of Doubles, Complex<Double> or any
 type that is a Scalar but also more exotic types as well such as quaternions over
 a rational number type, arbitrary precision arithmetic or even business model types
 in e.g. stock market modelling.
 
 This is an example of applying The Dependency Inversion Principle to scientific coding.
 
 This leads to a bit of a coding overhead at this stage but each algorithm should
 only need to be written once.
 
 Type safety is used here to make sure that the independent variable is of the right
 kind (we would not want to accidentally cast e.g. time to a complex type but as some do
 look at complex time we should still allow the possibility).
 
 Some of the material is based off Numerical Recipes in C versions of algorithms
 written by others. Numerical recipes state:
 
    If you analyse the ideas contained in a program, and then express those ideas
    in your own completely different implementation, then that new program implementation
    belongs to you. That is what we have done for those programs in this book
    that are not entirely of our own devising. When programs in this book are said to be
    “based” on programs published in copyright sources, we mean that the ideas are the
    same. The expression of these ideas as source code is our own. We believe that no
    material in this book infringes on an existing copyright.
 
 Re-expressing that code in terms of generics but preserving the traceability by using
 standard labels found in the literature is in the spirit of the above statement and
 so I believe that this code does not infringe on any existing copyright. This is because
 my implementation using generics to satisfy the The Dependency Inversion Principle makes this
 work as fundamentally different from that of Numerical Recipes as theirs was from the sources
 they used as a basis for their code. I also hope our use encourages sales of the Numerical
 Recipes books which I believe are a rather useful resource coving aspects of scientific
 coding that we have not covered.
 
 Also note that there is some odd behaviour in my implementation of odeint for non-linear
 systems. In the one week time frame it was not possible to determine if this was simply
 due to numerical instability or my implementation of the algorithm itself.

 TODO: Add more advanced integrators.
 TODO: Much more testing.
*/

import Foundation
import CoreLocation
public protocol OdeAddable {
    static func odeAdd(lhs: Self, rhs: Self) -> Self
}

public protocol DefinedOverOdeScalar {
    associatedtype OdeScalar
}

public protocol OdeScalarMultipliable: DefinedOverOdeScalar {
    static func odeMultiply(scalar: OdeScalar,integrand: Self)
              -> Self
}

public protocol OdeIntegrable:
                  OdeAddable & OdeScalarMultipliable {}

public protocol OdeMultStepIntegrable: Collection, OdeIntegrable  {
        static func ode_abs(of: Self.Element ) -> OdeScalar
}

// MARK: - Euler Step

/* Note dydx is an optional as only want to pass this in in adaptive setpsize
   context. Otherwise we might as well calculate it in the function

   Also note that we are avoiding using inout as a) they dont work with default
   values in arguments and b) it is copy in and copy out in swift so not the same
   as pointers and we do not get an efficiency boost.
*/
public func doEulerStep <IndependentVariable,
                         IntegrandType> (
    t: IndependentVariable,
    h: IndependentVariable,
    y: IntegrandType,
    derivative_function return_derivatives:
          (IndependentVariable, IntegrandType) -> IntegrandType,
    add:  (IntegrandType, IntegrandType) -> IntegrandType,
    times: (IndependentVariable, IntegrandType) -> IntegrandType,
    dydx inputdydx: IntegrandType! = nil)
-> IntegrandType
{
    let dydx: IntegrandType
    if inputdydx != nil {
        dydx = inputdydx
    } else {
        dydx = return_derivatives( t , y )
    }
    return add(y, times(h, dydx))
}

public func doEulerStep <T: OdeIntegrable> (
    t: T.OdeScalar,
    h: T.OdeScalar,
    y: T,
    derivative_function return_derivatives: (T.OdeScalar, T) -> T,
    dydx inputdydx: T! = nil
) -> T
{
    if inputdydx != nil {
        return doEulerStep(t: t,
                           h: h,
                           y: y,
                           derivative_function: return_derivatives,
                           add: T.odeAdd,
                           times: T.odeMultiply,
                           dydx: inputdydx)
    } else {
        return doEulerStep(t: t,
                           h: h,
                           y: y,
                           derivative_function: return_derivatives,
                           add: T.odeAdd,
                           times: T.odeMultiply)
    }
}

// MARK: - Runge Kutta order 4

// based on rk4 in numerical.recipes/book/book.html

public func doRungeKuttaStep
    < IndependentVariable: Has_IntegerInitializer &
                          Addable &
                          Dividable,
      IntegrandType > (
    t: IndependentVariable,
    h: IndependentVariable,
    y: IntegrandType,
    derivative_function derivs: (IndependentVariable,
                                 IntegrandType)
                                 -> IntegrandType,
    add: (IntegrandType, IntegrandType)
         -> IntegrandType,
    times: (IndependentVariable, IntegrandType)
           -> IntegrandType,
    dydx inputdydx: IntegrandType! = nil )
-> IntegrandType
{
    let dydx: IntegrandType
    if inputdydx != nil {
        dydx = inputdydx
    } else {
        dydx = derivs( t , y )
    }

    let hh = h / IndependentVariable(2)
    let h6 = h / IndependentVariable(6)
    let xh = t + hh
    var yt = add( y, times( hh, dydx ) )
    var dyt = derivs(xh,yt)
    yt = add( y, times( hh, dyt ) )
    var dym = derivs(xh, yt)
    yt = add( y, times( h, dym ) )
    dym = add( dym , dyt )
    dyt = derivs( t + h, yt )
    let sum1 = add( dydx , dyt )
    let sum2 = add( dym , dym )
    return add(y , times( h6, add( sum1, sum2 ) ) )
}
 
public func doRungeKuttaStep <T: OdeIntegrable> (
    t: T.OdeScalar,
    h: T.OdeScalar,
    y: T,
    derivative_function return_derivatives:
    (T.OdeScalar, T) -> T,
    dydx inputdydx: T! = nil
) -> T
where T.OdeScalar: Has_IntegerInitializer & Addable & Dividable
{
    if inputdydx != nil {
        return doRungeKuttaStep(t: t,
                                h: h,
                                y: y,
                                derivative_function: return_derivatives,
                                add: T.odeAdd,
                                times: T.odeMultiply,
                                dydx: inputdydx)
    } else {
        return doRungeKuttaStep(t: t,
                                h: h,
                                y: y,
                                derivative_function: return_derivatives,
                                add: T.odeAdd,
                                times: T.odeMultiply)
    }
}



// MARK: - Multistep method
// modified from odeint – does not store intermediate values (for simplified usage).
// TODO: Find out why this behaves as expected for Jyannes-Cummings but cannot integrate over long intervals for duffing oscillator (step size blows up)
public func multiStepIvpIntegrator< T: OdeMultStepIntegrable >
(
    from x1: T.OdeScalar,
    to x2: T.OdeScalar,
    first_try_of_stepsize h1: T.OdeScalar,
    smallest_allowed_value_of_stepsize hmin: T.OdeScalar,
    accuracy eps: T.OdeScalar,
    y ystart: inout T,
    derivative_function derivs: (T.OdeScalar, T) -> T
)

// Scalar that is defined over scalar field to allow for complex or real values
// independent variable has to be an ordered field so should conform to comparable
where T.OdeScalar: Scalar & Comparable & Has_Sqrt & Has_Pow & Has_Abs
{
    typealias Rx = T.OdeScalar
    let MAXSTP = 10000
    let TINY = Rx(1)/Rx(10).power(30) // 10^-30 Real
    var x = x1
    var h = h1
    var y = ystart
    
    var yscal = Array(repeating: Rx(0), count: y.count)
    let arrayTindicies = zip(yscal.indices, y.indices)

    for _ in 0 ..< MAXSTP {
        let dydx = derivs(x,y)
        for (iscal, iT) in arrayTindicies {
            yscal[iscal] = T.ode_abs(of: y[iT]) + ( T.ode_abs(of: dydx[iT]) * h ) + TINY
        }
        if ( (x + h - x2 )*( x + h - x1) > Rx(0) ) {
            h = x2  - x
        }
        var hdid = Rx(0)
        var hnext = Rx(0)
        rkqs(y: &y,
             dydx: dydx,
             x: &x,
             htry: h,
             eps: eps,
             yscal: yscal,
             hdid: &hdid,
             hnext: &hnext,
             derivative_function: derivs)
        if ( (x - x2) * (x2 - x1) >= Rx(0) ) {
            ystart = y
            return
        }
        if (hnext * hnext <= hmin * hmin) {
            errorStream.write("Step size too small in odeint")
        }
        h=hnext;
    }
    errorStream.write("Too many steps in routine odeint")
}

// MARK: internal rk45 step with error estimate based of NRC rkqs
func rkqs< T: OdeMultStepIntegrable >(y: inout T,
                                      dydx: T,
                                      x: inout T.OdeScalar,
                                      htry: T.OdeScalar,
                                      eps: T.OdeScalar,
                                      yscal: [T.OdeScalar],
                                      hdid: inout T.OdeScalar,
                                      hnext: inout T.OdeScalar,
                                      derivative_function derivs: (T.OdeScalar, T) -> T)
where   T.OdeScalar: Scalar & Comparable & Has_Pow & Has_Abs
{
    typealias Rx = T.OdeScalar
    
    let SAFETY = Rx(9) / Rx(10)
    let PGROW  = Rx(-2) / Rx(10)
    let PSHRNK = Rx(-25) / Rx(100)
    let ERRCON = Rx(189) / Rx(1000000)
    var ytemp = T.odeMultiply(scalar: Rx(0), integrand: y)
    var yerr = T.odeMultiply(scalar: Rx(0), integrand: y)
    var h = htry
    let arrayTindicies = zip(yscal.indices, yerr.indices)

    while (true) {
        fifthOrderCashKarpRungeKutta(t: x,
                                     h: h,
                                     y: y,
                                     yout: &ytemp,
                                     yerr: &yerr,
                                     derivative_function: derivs, dydx: dydx)
        
        var errmax = Rx(0)
        for (iscal, ierr) in arrayTindicies {
            errmax = max(errmax , T.ode_abs(of: yerr[ierr]) / yscal[iscal] )
        }
        errmax = errmax / eps
        if (errmax > Rx(1)) {
            let htemp = SAFETY * h * Rx.pow(errmax,PSHRNK)
            if (h >= Rx(0) ) {
                h = max(htemp, h / Rx(10) )
            } else {
                h = min(htemp, h / Rx(10) )
            }
            let xnew = (x) + h // only used here so bad name - maybe remove & change the if statement
            if (xnew == x) {
                errorStream.write("step-size underflow in rkqs")
            }
            continue
        } else {
            if (errmax > ERRCON) {
                hnext = SAFETY * h * Rx.pow(errmax, PGROW)
            } else {
                hnext = Rx(5) * h
            }
            hdid = h
            x = x + hdid
            y = ytemp
            break
        }
    }
}
// MARK: - Fifth Order Cash Karp Runge Kutta
public func fifthOrderCashKarpRungeKutta <T: OdeIntegrable> (
    t: T.OdeScalar,
    h: T.OdeScalar,
    y: T,
    yout: inout T,
    yerr: inout T,
    derivative_function return_derivatives:
    (T.OdeScalar, T) -> T,
    dydx inputdydx: T
)
where T.OdeScalar: Has_IntegerInitializer &
                   Addable &
                   Dividable &
                   Multipliable
{
    fifthOrderCashKarpRungeKutta(t: t,
                                 h: h,
                                 y: y,
                                 yout: &yout,
                                 yerr: &yerr,
                                 derivative_function: return_derivatives,
                                 add: T.odeAdd,
                                 times: T.odeMultiply,
                                 dydx: inputdydx)
}


// based on rkck in numerical.recipes/book/book.html
// Cash, J.R., and Karp, A.H. 1990, ACM Transactions on Mathematical Software, vol. 16, pp. 201– 222. [2]
private func fifthOrderCashKarpRungeKutta
    < IndependentVariable: Has_IntegerInitializer &
                           Addable &
                           Dividable &
                           Multipliable,
      IntegrandType>
    (
    t x: IndependentVariable,
    h: IndependentVariable,
    y: IntegrandType,
    yout: inout IntegrandType,
    yerr: inout IntegrandType,
    derivative_function derivs: (IndependentVariable,
                                 IntegrandType)
                                 -> IntegrandType,
    add: (IntegrandType, IntegrandType)
         -> IntegrandType,
    times: (IndependentVariable, IntegrandType)
    -> IntegrandType ,
    dydx: IntegrandType
    )
{
    typealias R = IndependentVariable
    // capitalised to avoid confusion with Addable sum in utility functions
    
    func Sum(_ values: IntegrandType ...) -> IntegrandType {
        return repeatedly (apply: add , values)
    }
    
    let a2 = R(2)/R(10),       a3  = R(3)/R(10),        a4 = R(6)/R(10),
        a5 = R(1),             a6  = R(875)/R(1000),
        b21 = R(2)/R(10),      b31 = R(3)/R(40),         b32 = R(9)/R(40),
        b41 = R(3)/R(10),      b42 = R(-9)/R(10),        b43 = R(12)/R(10),
        b51 = R(-11) / R(54),  b52 = R(25)/R(10),        b53 = R(-70)/R(27),
        b54 = R(35)/R(27),     b61 = R(1631)/R(55296),   b62 = R(175)/R(512),
        b63 = R(575)/R(13824), b64 = R(44275)/R(110592), b65 = R(253) / R(4096),
        c1  = R(37)/R(378),    c3  = R(250)/R(621),      c4  = R(125)/R(594),
        c6  = R(512)/R(1771),
        dc5 = R(-277) / R(14336),
        dc1 = c1 + ( R(-2825)  / R(27648)),
        dc3 = c3 + ( R(-18575) / R(48384)),
        dc4 = c4 + ( R(-13525) / R(55296) ),
        dc6 = c6 + ( R( -25 )  / R(100) )

    var ytemp = add (y , times (b21 * h , dydx) )  // First Step

    let ak2 = derivs(x + a2 * h, ytemp) // Second Step

    ytemp =  Sum( y ,
                  times( h * b31, dydx) ,
                  times( h * b32, ak2) )

    let ak3 = derivs(x + a3 * h, ytemp) // Third Step

    ytemp = Sum( y ,
                 times( h*b41, dydx),
                 times( h*b42, ak2) ,
                 times( h*b43, ak3) )

    let ak4 = derivs(x + a4 * h, ytemp) // Fourth Step

    ytemp = Sum( y ,
                 times( h*b51, dydx),
                 times( h*b52, ak2) ,
                 times( h*b53, ak3) ,
                 times( h*b54, ak4) )

    let ak5 = derivs(x + a5 * h, ytemp) // Fifth step.

    ytemp = Sum( y ,
                 times( h*b61, dydx) ,
                 times( h*b62, ak2 ) ,
                 times( h*b63, ak3 ) ,
                 times( h*b64, ak4 ) ,
                 times( h*b65, ak5 ) )
    let ak6 = derivs(x+a6*h, ytemp)  // Sixth step.
    // Accumulate increments with proper weights.
    yout = Sum( y ,
                times( h*c1, dydx) ,
                times( h*c3, ak3 ) ,
                times( h*c4, ak4 ) ,
                times( h*c6, ak6 ))

    //Estimate error as difference between fourth and fifth order methods.
    yerr = Sum(times( h*dc1, dydx),
               times( h*dc3, ak3 ),
               times( h*dc4, ak4 ),
               times( h*dc5, ak5 ),
               times( h*dc6, ak6 ))
}


// Created by M J Everitt on 21/01/2022.

