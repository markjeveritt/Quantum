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
}

//  Created by  M J Everitt on 17/01/2022.

