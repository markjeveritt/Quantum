// Ad hoc "Unit Tests" note that this style is not a good example of TDD and a result of
// trying to code a library in only one week (please excuse any unfixed spelling mistakes).

// Too many of the tests focus on implementation and not behaviours.
// One might consider the code that is used to generate the images for each chapter are better tests of the library than those presented here.

import Foundation
import XCTest
@testable import Quantum

final class CoreTests: XCTestCase {
    typealias C = Complex<Double>
    typealias V = Vector<C>
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_Complex_Basic() throws {
        
        let i = C(real: 0.0, imag: 1.0)
        let zero = C(0)
        let three = C(3)
        let threeDbl = C(3.0)
        let threeI = C(real: 0.0, imag: 3.0)
        let threeplusthreei = C(real: 3.0, imag: 3.0)
        XCTAssertEqual( three - threeDbl , zero )
        XCTAssertEqual( i * three , threeI )
        XCTAssertEqual( i * i * i, -i )
        XCTAssertEqual( three - threeDbl , zero )
        XCTAssertEqual(threeplusthreei / three , C(real: 1.0, imag: 1.0) )
        XCTAssertEqual(threeplusthreei / 3.0 , C(real: 1.0, imag: 1.0) )
        XCTAssertEqual( 3 + 3.0 * i , threeplusthreei )
        XCTAssertEqual( i * 3.0 + 3.0 , threeplusthreei )
        XCTAssertEqual( -3.0 - 3.0 * i + threeplusthreei, zero )
        XCTAssertEqual( i * -3.0 - 3.0 + threeplusthreei, zero )
        XCTAssertEqual( (3.0 + 4.0 * i).norm, 25.0 )
        XCTAssertEqual( (3.0 + 4.0 * i).modulus, 5.0 )
        
    }
    
    func test_Has_protocolForFunctions() throws {
        let a = C(real: 0.0, imag: 2.0)
        let b = C(modulus: 2.0, argument: Double.pi/2.0)
        XCTAssertEqual( (( a * b ) - C(real: -4.0, imag: 0.0)).modulus , 0.0 , accuracy: 1.0e-14 )
        XCTAssertEqual(a.argument, Double.pi/2.0, accuracy: 1.0e-14)
        XCTAssertEqual((-a).argument, -Double.pi/2.0, accuracy: 1.0e-14)
        
        XCTAssertEqual(b.modulus, 2.0, accuracy: 1.0e-14)
    }
    
    func test_VectorBasics() throws {
        let i = C( real: 0.0, imag: 1.0 )
        
        let space1 = VectorSpace<C>(dimension: 2, label: "test space 1")
        let u1 = V( elements: [ 3.0 + 2.0 * i , -1.0 + 4.0 * i ] , in: space1)
        let v1 = V( elements: [ -3.0 - 2.0 * i , 1.0 - 4.0 * i ] , in: space1)
        let zero1 = V(elements: [ C.zero, C.zero ] , in: space1)
        
        let space2 = VectorSpace<C>(dimension: 2, label: "test space 2")
        let u2 = V( elements: [ 3.0 + 2.0 * i , -1.0 + 4.0 * i ] , in: space2)
        
        XCTAssertEqual( u1 + v1 , zero1 )
        XCTAssertTrue( u1.space == v1.space )
        XCTAssertFalse( u1.space == u2.space )
        XCTAssertEqual( (u1 + v1)[1] , zero1[1] )
        XCTAssertNotEqual( u1[1] , v1[1])
        XCTAssertEqual( -u1 , v1 )
        XCTAssertNotEqual( -u1 , -v1 )
        XCTAssertEqual( u1 - v1 , u1 + u1 )
        XCTAssertEqual( u1 - u1 , zero1 )
        XCTAssertNotEqual( u1 - v1 , u1 - u1 )
        
        XCTAssertEqual( sum(u1,v1) , zero1 )
        XCTAssertEqual( sum(u1,v1,u1) , u1 )
        XCTAssertEqual( u1 + u1 , ( C(4.0) * u1 ) / C(2.0) )
        XCTAssertEqual( u1 + u1 , ( u1 * C(4.0) ) / C(2.0) )
        XCTAssertNotEqual( u1 + u1 , ( u1 * C(4.0) ) / C(3.0) )
        XCTAssertEqual( u1 + u1 , ( 4.0 * u1 ) / 2 ) // also sching int and double
        XCTAssertEqual( u1 + u1 , ( u1 * 4 ) / 2 )
        XCTAssertNotEqual( u1 + u1 , ( u1 * 4 ) / 3.0 )
        XCTAssertEqual( u1 + u1 , ( 4 * u1 ) / 2 )
        XCTAssertEqual( u1 + u1 , ( u1 * 4 ) / 2 )
        XCTAssertNotEqual( u1 + u1 , ( u1 * 4 ) / 3 )
        
    }
    
    func test_identity_operator() throws {
        let space = VectorSpace<Double>(dimension: 3, label: "test Space")
        XCTAssert(
            space.identityOperator.elements == [1.0,0.0,0.0,
                                                0.0,1.0,0.0,
                                                0.0,0.0,1.0]
        )
    }
    
    func test_matrixSubscript() throws {
        let space = VectorSpace<Double>(dimension: 2, label: "test Space")
        var matrix = Matrix(in: space)
        matrix[0,0] = 1.0
        matrix[0,1] = 2.0
        matrix[1,0] = 3.0
        matrix[1,1] = 4.0
        XCTAssertTrue( matrix.elements == [1.0,2.0,3.0,4.0])
    }
    
    func test_matrixTimesVector() throws {
        let space = VectorSpace<Double>(dimension: 2, label: "test Space")
        var matrix = Matrix(in: space)
        matrix[0,0] = 1.0
        matrix[0,1] = 2.0
        matrix[1,0] = 3.0
        matrix[1,1] = 4.0
        var vector = Vector(in: space)
        vector[0] = 5.0
        vector[1] = 6.0
        
        XCTAssertTrue( (matrix * vector).elements == [17.0,39.0] )
    }
    
    
    func test_square_matrix_multiplication() throws {
        
        let space = VectorSpace<Double>(dimension: 2, label: "MatMult test space")
        
        let A = Matrix(elements: [1,2,3,4], in: space)
        let B = Matrix(elements: [5,6,7,8], in: space)
        
        let C = A*B
        
        XCTAssertEqual(C.elements, [19,22,43,50])
        
        
        
        
    }
    
    func test_matrix_approximateEquals() throws {
        let i = C( real: 0.0, imag: 1.0 )
        let space = VectorSpace<Double>(dimension: 2, label: "test")
        let TINY = 1e-6
        let A = Matrix(elements: [1.0,2.0,3.0,-4.0], in: space)
        let B = Matrix(elements: [1.0,2.0+0.5 * TINY,3.0,-4.0], in: space)
        let C = Matrix(elements: [1.0,2.0 + 2.0 * TINY,3.0,-4.0], in: space)
        XCTAssert( (A =~= B) == true)
        XCTAssert( (A =~= C) == false)
        
        let spaceC = VectorSpace<Complex<Double>>(dimension: 2, label: "test")
        let Ac = Matrix(elements: [i,Complex.one,Complex.zero,Complex.one],
                        in: spaceC)
        let Bc = Matrix(elements: [i,Complex.one + 0.5 * TINY,Complex.zero,Complex.one],
                        in: spaceC)
        let Cc = Matrix(elements: [i,Complex.one + 2.0 * TINY,Complex.zero,Complex.one],
                        in: spaceC)
        XCTAssert( (Ac =~= Bc) == true)
        XCTAssert( (Ac =~= Cc) == false)
    }
    
    func test_matrix_TransposeAndAdjoint() throws {
        let i = C( real: 0.0, imag: 1.0 )
        let spaceC = VectorSpace<Complex<Double>>(dimension: 2, label: "test")
        let A = Matrix(elements: [1 + i, 2 + 2 * i,
                                  3 - i, i ],
                       in: spaceC)
        let AT = Matrix(elements: [1 + i, 3 - i,
                                   2 + 2 * i, i ],
                        in: spaceC)
        let AD = Matrix(elements: [1 - i, 3 + i,
                                   2 - 2 * i, -i ],
                        in: spaceC)
        XCTAssertEqual(A.transpose(), AT)
        XCTAssertEqual(A.hermitianAdjoint(), AD)
    }
    
    // MARK: - Sparse Tests (adding spartse to make integration faster)
    func test_sparse_creation_and_equals() throws {
        let cs1 = CoordinateStorage<Double>(value: 3.0, row: 1, col: 2)
        let cs2 = CoordinateStorage<Double>(value: 6.0, row: 1, col: 2)
        XCTAssert(cs1 != cs2)
        let cs3 = CoordinateStorage<Double>(value: 3.0, row: 2, col: 2)
        XCTAssert(cs1 != cs3)
        let cs4 = CoordinateStorage<Double>(value: 3.0, row: 1, col: 1)
        XCTAssert(cs1 != cs4)
        let cs5 = CoordinateStorage<Double>(value: 3.0, row: 1, col: 2)
        XCTAssert(cs1 == cs5)
        XCTAssert( (cs1 * 2.0 == cs2), "not ClosedUnderScalarFieldMultiplication" )
        XCTAssert(cs1 < cs3)
        XCTAssert(cs3 > cs1)
    }
    
    func test_makingSparseMatrix() throws {
        let space = VectorSpace<Double>(dimension: 3, label: "test Space")
        let n = Matrix(elements: [0.0, 0.0, 0.0,
                                  0.0, 1.0, 0.0,
                                  0.0, 0.0, 2.0], in: space)
        let sparse_n = SparseMatrix(from: n)
        
        XCTAssert(sparse_n.values.count == 2)
        XCTAssert(sparse_n.values[0] == CoordinateStorage(value: 1.0, row: 1, col: 1))
        XCTAssert(sparse_n.values[1] == CoordinateStorage(value: 2.0, row: 2, col: 2))
        XCTAssert(Matrix(fromSparse: sparse_n) == n)
        let a = Matrix<Double>(elements: [0.0, 1.0,  0.0,
                                          0.0 , 0.0, sqrt(2.0),
                                          0.0 , 0.0, 0.0], in: space)
        let sparse_a = SparseMatrix<Double>(from: a)
        
        let apn = a + n
        
        let sparse_apn = sparse_a + sparse_n
        
        XCTAssert(Matrix(fromSparse: sparse_apn) == apn)
        
        let v = Vector(elements: [1.0,2.0,3.0], in: space)
        
        XCTAssert( apn * v == sparse_apn * v )
        XCTAssert( Matrix(fromSparse: 2.0 * sparse_apn) == 2.0 * apn)
        XCTAssert( Matrix(fromSparse: sparse_apn * 2.0) == 2.0 * apn)
        XCTAssert( Matrix(fromSparse: sparse_apn * 2.0) == apn * 2.0)
        XCTAssert( Matrix(fromSparse: 2.0 * sparse_apn) == apn * 2.0)
        
        
        let spaceC = StateSpace(dimension: 3, label: "test complex Space")
        let nC = spaceC.numberOperator
        let sparse_nC = SparseMatrix(from: nC)
        let aC = spaceC.annihilationOperator
        let sparse_aC = SparseMatrix(from: aC)
        
        let apnC = aC + nC
        let sparse_apnC = sparse_aC + sparse_nC
        XCTAssert(MatrixOperator(fromSparse: sparse_apnC) == apnC)
        
        // check correct inner product is used if Has_Conjugate
        XCTAssert(v.innerProduct(dualVector: v) == 14.0)
        let vC = Vector(elements: makeAComplexArray([1.0,2.0,3.0]), in: spaceC)
        XCTAssert(Complex(real: 14.0, imag: 0.0) == vC.innerProduct(dualVector: vC) )
    }
    
    func test_tensorProduct() throws {
        let space1 = VectorSpace<Double>(dimension: 2, label: "test Space 1")
        let matrix1 = Matrix(elements: [1.0,2.0,3.0,4.0], in: space1)
        let space2 = VectorSpace<Double>(dimension: 2, label: "test Space 2")
        let matrix2 = Matrix(elements: [0.0,5.0,6.0,7.0], in: space2)
        let totalSpace = VectorSpace(tensorProductOf: space1, space2, label: "TP space")
        let bigMatrix = totalSpace.tensorProduct(of: matrix1, with: matrix2)
        
        XCTAssertTrue(bigMatrix.elements == [ 0.0, 5.0 , 0.0  , 10.0 ,
                                              6.0, 7.0 , 12.0 , 14.0,
                                              0.0, 15.0, 0.0  , 20.0,
                                              18.0, 21.0,24.0  , 28.0] )
    }
    
    func test_makingDiagonalSparseMatrix() throws {
        
        let testSpace = VectorSpace<Double>(dimension: 4, label: "")
        
        let denseMatrix = Matrix<Double>(elements: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16], in: testSpace)
        
        let diagonalSparse = DiagonalSparseMatrix(from: denseMatrix)
        
        XCTAssertEqual(diagonalSparse.space, testSpace)
        XCTAssertEqual(diagonalSparse.diagonals[-3]!.elements, [3:13])
        XCTAssertEqual(diagonalSparse.diagonals[-2]!.elements, [2:9, 3:14])
        XCTAssertEqual(diagonalSparse.diagonals[-1]!.elements, [1:5, 2:10, 3:15])
        XCTAssertEqual(diagonalSparse.diagonals[0]!.elements, [0:1, 1:6, 2:11, 3:16])
        XCTAssertEqual(diagonalSparse.diagonals[1]!.elements, [0:2, 1:7, 2:12])
        XCTAssertEqual(diagonalSparse.diagonals[2]!.elements, [0:3, 1:8])
        XCTAssertEqual(diagonalSparse.diagonals[3]!.elements, [0:4])
        
    }
    
    func test_diagonalSparseAdd() throws {
        
        let space = VectorSpace<Double>(dimension: 3, label: "test diag sparse add space")
        let lhs = DiagonalSparseMatrix(in: space, diagonals: [0:MatrixDiagonal(dimension: space.dimension, diagIdx: 0, elements: [0:1, 1:1, 2:1])])
        
        let rhs = DiagonalSparseMatrix(in: space, diagonals: [1:MatrixDiagonal(dimension: space.dimension, diagIdx: 1, elements: [0:1, 1:1])])
       
        XCTAssertEqual((lhs + rhs).diagonals[0]!.elements, [0:1, 1:1, 2:1])
        XCTAssertEqual((lhs + rhs).diagonals[1]!.elements, [0:1, 1:1])
    }
    
    func test_diagonalSparseSubtract() throws {
        
        let space = VectorSpace<Double>(dimension: 3, label: "test diag sparse add space")
        let lhs = DiagonalSparseMatrix(in: space, diagonals: [0:MatrixDiagonal(dimension: space.dimension, diagIdx: 0, elements: [0:1, 1:1, 2:1])])
        
        let rhs = DiagonalSparseMatrix(in: space, diagonals: [1:MatrixDiagonal(dimension: space.dimension, diagIdx: 1, elements: [0:1, 1:1])])
        
        XCTAssertEqual((lhs - rhs).diagonals[0]!.elements, [0:1, 1:1, 2:1])
        XCTAssertEqual((lhs - rhs).diagonals[1]!.elements, [0:-1, 1:-1])
    }
    
    func test_diagonalSparseVecMult() throws {
        
        let space = VectorSpace<Double>(dimension: 2, label: "test Space")
        
        let zeroDiag = MatrixDiagonal(dimension: 2, diagIdx: 0, elements: [0: 1, 1:4])
        let oneDiag = MatrixDiagonal(dimension: 2, diagIdx: 1, elements: [0:2])
        let minusOneDiag = MatrixDiagonal(dimension: 2, diagIdx: -1, elements: [1:3])
        
        let matrix = DiagonalSparseMatrix(in: space,
                                          diagonals: [0: zeroDiag, 1: oneDiag, -1: minusOneDiag])
        
        var vector = Vector(in: space)
        vector[0] = 5.0
        vector[1] = 6.0
        XCTAssertTrue( (matrix * vector).elements == [17.0,39.0] )
    }
    
    func test_diagonalSparseMatMult() throws {
        
        let testDiagMMSpace = VectorSpace<Double>(dimension: 4, label: "")
        
        /*
         A = 1 0 0 0
             2 3 0 0
             0 4 5 0
             0 0 6 7 , diagonals are 0,-1
         
         B = 0 1 0 0
             1 0 1 0
             0 1 0 1
             0 0 1 0 , diagonals are 1,-1
         
         C = A*B
           = 0 1 0 0
             3 2 3 0
             4 5 4 5
             0 6 7 6 , should have diagonals -1,-2,0,1.
         */
        let A = DiagonalSparseMatrix(in: testDiagMMSpace, diagonals:
                                        [0: MatrixDiagonal(dimension: 4, diagIdx: 0, elements: [0:1, 1:3, 2:5, 3:7]),
                                         -1: MatrixDiagonal(dimension: 4, diagIdx: -1, elements: [1: 2, 2:4, 3: 6])])
        
        
        let B = DiagonalSparseMatrix(in: testDiagMMSpace, diagonals:
                                        [-1: MatrixDiagonal(dimension: 4, diagIdx: -1, elements: [1: 1, 2:1, 3:1]),
                                          1: MatrixDiagonal(dimension: 4, diagIdx: 1, elements: [0:1, 1:1, 2:1])])
        
        let C = A*B
        
        XCTAssertEqual(C.diagonals[-2]!.elements, [2:4, 3:6])
        XCTAssertEqual(C.diagonals[-1]!.elements, [1:3, 2:5, 3:7])
        XCTAssertEqual(C.diagonals[0]!.elements, [1:2, 2:4, 3:6])
        XCTAssertEqual(C.diagonals[1]!.elements, [0:1, 1:3, 2:5])
        
        XCTAssertNil(C.diagonals[-3])
        XCTAssertNil(C.diagonals[2])
        XCTAssertNil(C.diagonals[3])
        
        
    }
    
    func test_diagonalSparseTensorProduct() throws {
        
        
        let leftSubSpace = VectorSpace<Double>(dimension: 2, label: "")
        let rightSubSpace = VectorSpace<Double>(dimension: 3, label: "")
        let fullSpace = VectorSpace<Double>(tensorProductOf: leftSubSpace, rightSubSpace,
                                            label: "")
        let A = DiagonalSparseMatrix(in: leftSubSpace, diagonals: [0: MatrixDiagonal(dimension: 2, diagIdx: 0, elements: [0:1]),
                                                                   1: MatrixDiagonal(dimension: 2, diagIdx: 1, elements: [0:1])])
        
        let B = DiagonalSparseMatrix(in: rightSubSpace, diagonals: [-1: MatrixDiagonal(dimension: 3, diagIdx: -1, elements: [1:1, 2:2]),
                                                                     2: MatrixDiagonal(dimension: 3, diagIdx: 2, elements: [0:1])])
        
        let C = fullSpace.tensorProduct(of: A, with: B)
        
        XCTAssertEqual(C.diagonals[2]!.elements, [0:1, 1:1, 2:2])
        XCTAssertEqual(C.diagonals[5]!.elements, [0:1])
        XCTAssertEqual(C.diagonals[-1]!.elements, [1:1, 2:2])
        
        for diagIdx in [-5,-4,-3,-2,0,1,3,4] {
            XCTAssertNil(C.diagonals[diagIdx])
        }
        
    }
    
    func test_matrixFromDiagonalSparse() throws {
        
        let testSpace = VectorSpace<Double>(dimension: 4, label: "")
        
        let denseMatrix = Matrix<Double>(elements: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16], in: testSpace)
        
        let diagonalSparse = DiagonalSparseMatrix(from: denseMatrix)
        
        let reproducedDenseMatrix = Matrix<Double>(from: diagonalSparse)
        
        XCTAssertEqual(reproducedDenseMatrix, denseMatrix)
        
        
    }
    
    func test_diagonalSparseIndexing() throws {
        
        let testSpace = VectorSpace<Double>(dimension: 4, label: "")
        
        let denseMatrix = Matrix<Double>(elements: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16], in: testSpace)
        
        let diagonalSparse = DiagonalSparseMatrix(from: denseMatrix)
        
        for row in 0..<4 {
            for col in 0..<4 {
                
                XCTAssertEqual(denseMatrix[row,col], diagonalSparse[row,col])
            }
        }
    }
    
    
    
    
    
    func testLinearFitting() throws {
        
        let x1Data = [0.0,1.0,2.0,3.0,4.0,5.0]
        let y1Data = x1Data.map{$0 * 2}
        
        
        let (slope1, intercept1) = getLinearFitCoefficientsFromLeastSquaresMethod(x1Data, y1Data)
        
        let y2Data = x1Data.map{$0 * 0.5 + 1}
        
        let (slope2, intercept2) = getLinearFitCoefficientsFromLeastSquaresMethod(x1Data, y2Data)
        
        XCTAssertEqual(slope1, 2.0)
        XCTAssertEqual(intercept1, 0.0)
        
        XCTAssertEqual(slope2, 0.5)
        XCTAssertEqual(intercept2, 1)
    }
   
    
}




//  Created by  M J Everitt on 17/01/2022.

