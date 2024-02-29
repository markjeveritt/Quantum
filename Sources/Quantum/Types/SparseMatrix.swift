/*
 See notes in Spaces file
 
 TODO: Optimise
 TODO: Check if other storage options are better
 */

import Foundation

public struct SparseMatrix<T: Scalar>: OperatorType {

    
    public typealias ScalarField = T
    public var space: VectorSpace<ScalarField>
    
    let rows: Int
    let columns: Int
    public var values: [CoordinateStorage<T>]
    
    public init(from matrix: Matrix<ScalarField>) {
        rows = matrix.space.dimension
        columns = matrix.space.dimension
        space = matrix.space
        values = []
        for i in 0 ..< rows {
            for j in 0 ..< columns {
                if matrix[i,j] != T(0.0) {
                    values.append(CoordinateStorage(value: matrix[i,j], row: i, col: j))
                }
            }
        }
        values.sort()
    }
    public init (in space: VectorSpace<ScalarField>) {
        rows = space.dimension
        columns = space.dimension
        self.values = []
        self.space = space
    }
    
    public init (values: [CoordinateStorage<ScalarField>],
                 in space: VectorSpace<ScalarField>) {
        rows = space.dimension
        columns = space.dimension
        self.values = values.sorted()
        self.space = space
    }
    // MARK: Arithmatic
    public static func * (left: Self, right: ScalarField) -> Self {
        return Self(values: left.values.map( { $0 * right } ), in: left.space)
    }
    public static func / (left: Self, right: ScalarField) -> Self {
        return Self(values: left.values.map( { $0 / right } ), in: left.space)
    }
    public static func * (left: ScalarField, right: Self) -> Self {
        return Self(values: right.values.map( { $0 * left } ), in: right.space)
    }


    public static func scalarBinaryOperationAdditionLogic(
        lhs: SparseMatrix<ScalarField>,
        rhs: SparseMatrix<ScalarField>,
        operation: (ScalarField,ScalarField)->ScalarField)
    -> SparseMatrix<ScalarField> {
        assert (lhs.rows == rhs.rows)
        assert (lhs.columns == rhs.columns)
        assert (lhs.space == rhs.space)
        
        var out = SparseMatrix(in: lhs.space)
        var lhs_position = 0
        var rhs_position = 0
        
        while ( lhs_position < lhs.values.count && rhs_position < rhs.values.count ) {
            
            let right = rhs.values[rhs_position]
            let left = lhs.values[lhs_position]
            
            if ( right < left ) {
                out.values.append(right)
                rhs_position += 1
            } else if ( left < right ) {
                out.values.append(left)
                lhs_position += 1
            } else { // at the same position in matrix
                // if these add to zero its inefficient but unlikely to happen often
                out.values.append(CoordinateStorage(value: operation(left.value,  right.value), row: left.row, col: left.col))
                lhs_position += 1
                rhs_position += 1
            }
        }
        while (lhs_position < lhs.values.count) {
            out.values.append(lhs.values[lhs_position])
            lhs_position += 1
        }
        while (rhs_position < rhs.values.count) {
            out.values.append(rhs.values[rhs_position])
            rhs_position += 1
        }
        return out
    }
    
    public static func + (lhs: SparseMatrix<ScalarField>,
                          rhs: SparseMatrix<ScalarField>)
    -> SparseMatrix<ScalarField> {
        return Self.scalarBinaryOperationAdditionLogic(lhs: lhs, rhs: rhs, operation: +)
    }
    
    public static func - (lhs: SparseMatrix<ScalarField>,
                          rhs: SparseMatrix<ScalarField>)
    -> SparseMatrix<ScalarField> {
        return Self.scalarBinaryOperationAdditionLogic(lhs: lhs, rhs: rhs, operation: -)
    }
    
    public static func * (lhs: SparseMatrix<T>, rhs: SparseMatrix<T>) -> SparseMatrix<T> {
        //        errorStream.write("""
        //                          Sparse Matrix Multiplication not yet properly implemented
        //                          Avoid using as only inlcuded to correctly satisfy Mutiplible
        //                          This routine is VERY slow.
        //                          """)
        //        let A = Matrix(fromSparse: lhs)
        //        let B = Matrix(fromSparse: rhs)
        //        return SparseMatrix(from: A * B )
        
        /*
         The code below was not added during the "week of coding" instead the above commented out
         code was used (it was needed only to conform to OperatorType and a proper sparse
         implementation was not needed for performance at that time).
         
         The below code was added to produce a figure Figure 10.4 after the week of coding and
         is based on some old java code of mine written with Peter Stiffell.
         
         It does not conform to my current view of clean code and needs to be re-written
         for clarity. This should only be done once a final sparse representation has been
         decided.
        */

        assert(lhs.space == rhs.space,
               "Cant multiply sparse matrices from different spaces")
        let dim = lhs.space.dimension

        var cntr = 0
        var kk = 0
        var k = 0

        var output = SparseMatrix(in: lhs.space)
        var B_el_t = rhs.transpose()
        
        var values = lhs.values
        values.sort()
        B_el_t.values.sort()
        
        for  i in 0 ..< dim {
            var l = 0
            for j in 0 ..< dim {
                var sum = T(0)
                var activePoint = false
                k = kk
                times2 : while ( k < values.count ) {
                    if (values[k].row == i) {
                        times1 : while( l < B_el_t.values.count ) {
                            if(B_el_t.values[l].row == j) {
                                if(values[k].col == B_el_t.values[l].col) {
                                    sum = sum + (values[k].value * B_el_t.values[l].value)
                                    activePoint = true
                                    break times1
                                } else if (B_el_t.values[l].col < values[k].col) {
                                    l += 1
                                } else {
                                    break times1
                                }
                            } else if (B_el_t.values[l].row < j) {
                                l += 1
                            } else {
                                break times1
                            }
                        }
                        k += 1
                    } else {
                        break times2
                    }
                }
                if(activePoint) {
                    output.values.append(CoordinateStorage(value: sum, row: i, col: j))
                    cntr += 1
                }
            }
            kk = k
        }
        output.values.sort()
        return output
    }

        
    public func transpose() -> SparseMatrix {
                var output = SparseMatrix(in: self.space)
                for element in self.values {
                    output.values.append(CoordinateStorage(value: element.value, row: element.col, col: element.row))
                }
                return output
    }
     
    
    public static func * (lhs: SparseMatrix<ScalarField>,
                          rhs: Vector<ScalarField>) -> Vector<ScalarField> {
        assert(lhs.columns == rhs.space.dimension, "Index out of range")
        assert(lhs.space == rhs.space, "Matrix operators and vector must be in same space")

        var output = Vector(in: lhs.space)
        
        for matrixElement in lhs.values {
            let col = matrixElement.col
            let row = matrixElement.row
            let temp = matrixElement.value * rhs[col]
            output[row] = output[row] + temp
        }
        return output
    }
}

extension Matrix {
    public init(fromSparse matrix: SparseMatrix<T>)  {
        space = matrix.space
        elements = Array.init(repeating: T(0.0), count: space.dimension * space.dimension)
        for element in matrix.values {
            self[element.row,element.col] = element.value
        }
    }
}
// MARK: - Coodinate Storage

public struct CoordinateStorage<T: Scalar> {
    public init(value: T, row: Int, col: Int) {
        self.value = value
        self.row = row
        self.col = col
    }
    
    public var value: T
    public var row: Int
    public var col: Int
    
    
    
}

extension CoordinateStorage: Equatable where T: Equatable {
    public static func == (lhs: CoordinateStorage<T>, rhs: CoordinateStorage<T>) -> Bool {
        let colsEqual   = lhs.col == rhs.col
        let rowsEqual   = lhs.row == rhs.row
        let valuesEqual = lhs.value == rhs.value
        
        return colsEqual && rowsEqual && valuesEqual
    }
}



extension CoordinateStorage: definedOverScalarField {
    public typealias ScalarField = T
}
extension CoordinateStorage: ClosedUnderScalarFieldMultiplication where T: Multipliable {
    public static func / (left: CoordinateStorage<T>, right: T) -> CoordinateStorage<T> {
        return CoordinateStorage(value: left.value / right , row: left.row, col: left.col)
    }
    
    public static func * (left: CoordinateStorage<T>, right: T) -> CoordinateStorage<T> {
        return CoordinateStorage(value: left.value * right , row: left.row, col: left.col)
    }
    
    public static func * (left: T, right: CoordinateStorage<T>) -> CoordinateStorage<T> {
        return CoordinateStorage(value: right.value * left , row: right.row, col: right.col)
    }
}
extension CoordinateStorage: Negatable {
    public static prefix func - (value: CoordinateStorage<T>) -> CoordinateStorage<T> {
        return CoordinateStorage(value: -value.value, row: value.row, col: value.col)
    }
    
    
}
extension CoordinateStorage: CustomStringConvertible {
    public var description: String {
        return "[\(row),\(col)] = \(value)"
    }
}
// need to be able to order stored values to add and equate arrays of CoordinateStorage
// note that the Value itself is not needed and may not even be meaningful if scalar is an unordered field
extension CoordinateStorage: Comparable where T: Equatable {
    public static func < (lhs: CoordinateStorage<T>, rhs: CoordinateStorage<T>) -> Bool {
        return ( lhs.row < rhs.row || ((lhs.row == rhs.row) ) && (lhs.col < rhs.col))
    }
}

extension SparseMatrix: providesDoubleAndIntMultiplication where T: ComplexNumber {}
//  Created by M J Everitt on 20/01/2022.
