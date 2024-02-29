/*
 Standard utility functions used by different structs and classes (to make code DRY).
 
 e.g. scalarBinaryOperation allows us to multiply, divide etc operators and vectors element wise by scalar
 
 TODO: Optimise
 It is not clear that map and zip are as fast as one might expect.
 Test performance against for loop and consider adding an automated way to switch
 depending on e.g. size of arrays or platform.
 
 TODO: Nested Kronecker products
 For
    1) tensor products of multiple spaces
    2) tensor products of tensor product spaces
 
 TODO: Consider if arrays could be replaced by Collection in `elementwise' funcs to make more general
 */
import Foundation

public func makeAComplexArray<T: Scalar>(_ values: [T]) -> [Complex<T>] {
    return values.map( { Complex(real: $0, imag: T(0) ) } )
}

public func scalarBinaryOperation<T>(array: [T],by value: T, operation: (T,T)->T) -> [T] {
    return array.map( { (element: T) -> T in return operation(element, value) } )
}

public func elementWisePrefixOperation<T>(array: [T], operation: (T)->T) -> [T] {
    return array.map( { (element: T) -> T in return operation(element) } )
}

public func elementWiseBinaryOperation<T>(thisArry: [T], thatArray: [T], operation: (T,T)->T ) -> [T] {
    assert(thisArry.count == thatArray.count)
    return zip(thisArry,thatArray).map(operation)
}

func checkInSameSpace<U: livesInAVectorSpace,V: livesInAVectorSpace>(_ lhs: U,_ rhs: V) {
    assert(lhs.space.identifier == rhs.space.identifier,
           """
              Incompatable spaces:
                  - \(lhs.space.description)
                  - \(rhs.space.description)
              """)
}
public func repeatedly<T>(apply binaryFunction: (T,T)->T, _ items: [T]) ->T {
    assert(items.count > 1, "need more than one item")
    var output = items[0]
    for i in 1 ..< items.count {
        output = binaryFunction( output , items[i] )
    }
    return output
}
public func repeatedly<T>(apply binaryFunction: (T,T)->T, _ items: T ...) ->T {
    return repeatedly(apply: binaryFunction, items)
}
public func sum<A: Addable>(_ vectors: A...) -> A {
    repeatedly(apply: +, vectors)
}

// For dereferencing a one-d arras as if its a matrix.
//      row * dim + col   is column major
//      row  + col * dim  is row major
// currently format is not made clear in self-documenting code.
// TODO: consider adding a boolean "column major" argument to make this explicit.
// (maybe with default value true)
func atIndex(row: Int, column: Int, nColumns: Int) -> Int { 
    return (row * nColumns) + column
} 

// kronecker delta
// TODO: Consider renaming
func delta(_ n: Int,_ m: Int) -> Int {
    var out = 0
    if n == m {
        out = 1
    }
    return out
}

// https://en.wikipedia.org/wiki/Kronecker_product
// [accessed: 12/01/2022 - see Definition]
public func kronekerProduct<T: Scalar>  (
    A: [T], rowsA: Int, colsA :Int,
    B: [T], rowsB: Int, colsB :Int)
-> [T]  {
    assert(A.count == rowsA * colsA, "dimension of A bad: dim(A) = \(A.count), rowsA = \(rowsA), colsB = \(colsA)")
  assert(B.count == rowsB * colsB, "dimension of A bad: dim(A) = \(B.count), rowsA = \(rowsB), colsB = \(colsB)")
  var C = Array(repeating: T.zero,
                count: rowsA*rowsB*colsA*colsB)
    
  let colsC = colsA * colsB
  let p = rowsB // so notation is same as wikipedia
  let q = colsB

  let index = { (_ R: Int,_ C: Int,_ N: Int) -> Int in
        return atIndex(row: R, column: C, nColumns: N) }

  for r in 0 ..< rowsA {
    for s in 0 ..< colsA {
      let A_rs = A[index(r,s, colsA)]
      for v in 0 ..< rowsB {
        for w in 0 ..< colsB {
          C[index(p * r + v, q * s + w, colsC)] =
                            A_rs * B[index(v,w, colsB)]
        }
      }
    }
  }
  return C
}


public func getRowLimits(dim: Int, diagIdx: Int) -> (Int, Int) {
    
    if diagIdx <= 0 {
        return (-diagIdx, dim - 1)
    }
    
    return (0, dim - diagIdx - 1)
    
}

//  Created by M J Everitt on 17/01/2022.

