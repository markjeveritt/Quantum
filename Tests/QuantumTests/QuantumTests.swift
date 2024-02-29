// Ad hoc "Unit Tests" note that this style is not a good example of TDD and a result of
// trying to code a library in only one week (please excuse any unfixed spelling mistakes).

// Too many of the tests focus on implementation and not behaviours.
// One might consider the code that is used to generate the images for each chapter are better tests of the library than those presented here.

import XCTest
@testable import Quantum

final class QuantumTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_number_operator() throws {
        let space = StateSpace(dimension: 3, label: "test Space")
        
        XCTAssert(
            space.numberOperator.elements ==
            makeAComplexArray([0.0, 0.0, 0.0,
                               0.0, 1.0, 0.0,
                               0.0, 0.0, 2.0])
        )
    }
    
    func test_creation_operator() throws {
        let space = StateSpace(dimension: 3, label: "test Space")
        XCTAssert(
            space.creationOperator.elements ==
            makeAComplexArray([0.0, 0.0,       0.0,
                              1.0 , 0.0,       0.0,
                              0.0 , sqrt(2.0), 0.0])
        )
    }
    
    func test_parity_operator() throws {
        let space = StateSpace(dimension: 3, label: "test Space")
        XCTAssert(
            space.parityOperator.elements ==
            makeAComplexArray([1.0,0.0,0.0,
                               0.0,-1.0,0.0,
                               0.0,0.0,1.0])
        )
    }
    
    func test_spin_operators() throws {
        let i = Complex<Real>(real: 0.0, imag: 1.0)
        let space = StateSpace(dimension: 2, label: "test spin")
        XCTAssert(
            space.sigmaZ.elements == [Complex.one,Complex.zero,
                                    Complex.zero,-Complex.one]
        )
        XCTAssert(
            space.sigmaX.elements == [Complex.zero,Complex.one,
                                    Complex.one,Complex.zero]
        )
        XCTAssert(
            space.sigmaY.elements == [Complex.zero,-i,
                                    i,Complex.zero]
        )
        XCTAssert(
            space.sigmaPlus.elements == [Complex.zero,Complex.one,
                                       Complex.zero,Complex.zero]
        )
        XCTAssert(
            space.sigmaMinus.elements == [Complex.zero,-Complex.zero,
                                        Complex.one,Complex.zero]
        )
    }
    
    func test_spin_algebra() throws {
        let i = Complex<Real>(real: 0.0, imag: 1.0)
        let space = StateSpace(dimension: 2, label: "test spin")

        let Sx = space.sigmaX * 0.5
        let Sy = space.sigmaY * 0.5
        let Sz = space.sigmaZ * 0.5
        let Splus = Sx + i * Sy
        let Sminus = Sx - i * Sy
        XCTAssert( Sx.commutator(with: Sy) == i * Sz  )
        XCTAssert( Sy.commutator(with: Sx) == -i * Sz )
        XCTAssert( Sy.commutator(with: Sz) == i * Sx  )
        XCTAssert( Sz.commutator(with: Sy) == -i * Sx )
        XCTAssert( Sz.commutator(with: Sx) == i * Sy  )
        XCTAssert( Sx.commutator(with: Sz) == -i * Sy )
        XCTAssert( Sz.commutator(with: Splus) == Splus        )
        XCTAssert( Sz.commutator(with: Sminus) == -Sminus     )
        XCTAssert( Splus.commutator(with: Sminus) == 2.0 * Sz )
    }
    
    func test_delta() throws {
        XCTAssert(
            delta(3,4) == 0
        )
        XCTAssert(
            delta(13,13) == 1
        )
    }
    
    func test_am_algebra() throws {
        let i = Complex<Real>(real: 0.0, imag: 1.0)
        let space = StateSpace(dimension: 5, label: "test spin")
        
        let Jx = space.Jx
        let Jy = space.Jy
        let Jz = space.Jz
        let Jplus = space.Jplus
        let Jminus = space.Jminus
        
        // check some non-zero elements
        XCTAssert(Jx[0,1] == Complex(real: 1.0, imag: 0.0 ))
        XCTAssert(Jy[0,1] == Complex(real: 0.0, imag: -1.0 ))
        XCTAssert(Jz[3,3] == Complex(real: -1.0, imag: 0.0 ))
        // needed to use an approx equal method due to rounding errors

        XCTAssert( Jx + i * Jy =~= Jplus )
        XCTAssert( Jx - i * Jy =~= Jminus )

        XCTAssert( Jx.commutator(with: Jy) =~= i * Jz  )
        XCTAssert( Jy.commutator(with: Jx) =~= -i * Jz )
        XCTAssert( Jy.commutator(with: Jz) =~= i * Jx  )
        XCTAssert( Jz.commutator(with: Jy) =~= -i * Jx )
        XCTAssert( Jz.commutator(with: Jx) =~= i * Jy  )
        XCTAssert( Jx.commutator(with: Jz) =~= -i * Jy )
        XCTAssert( Jz.commutator(with: Jplus) =~= Jplus        )
        XCTAssert( Jz.commutator(with: Jminus) =~= -Jminus     )
        XCTAssert( Jplus.commutator(with: Jminus) =~= 2.0 * Jz )
    }
    
    func test_referenceTypesForSpace() throws {
        let testSpace = StateSpace(dimension: 3, label: "first test space")
        // check reference and data types work as expected
        var A =  MatrixOperator(in: testSpace)
        let B =  A
        XCTAssert(A == B)
        
        XCTAssert( A[1,1] == B[1,1] )
        A[1,1] = Complex(real: 1.0, imag: 2.0) // should not change B
        XCTAssert( A[1,1] != B[1,1] )
    }
    
    func test_SpaceLabelling() throws {
        let testSHO_Space = StateSpace(dimension: 4, label: "SHO space")

        let sho_index = testSHO_Space.identifier
        let spinSpace = StateSpace(dimension: 2, label: "A spin")
        let spin_index = spinSpace.identifier
        let spaces = StateSpace(tensorProductOf:  testSHO_Space, spinSpace , label: "test TP")

        let product_index = spaces.identifier

        XCTAssert(spin_index == sho_index + 1)
        XCTAssert(product_index == spin_index + 1)

        XCTAssert(spinSpace.setofSpaces[0].identifier == spin_index)
        XCTAssert(spaces.setofSpaces[0].identifier == sho_index)
        XCTAssert(spaces.setofSpaces[1].identifier == spin_index)
    }
    
    func test_diagonalSpaceOperator() throws {
        let qubitSpace = StateSpace(dimension: 2, label: "qubit space")
        let denseSigmaY = qubitSpace.sigmaY
        let diagSparseSigmaY = DiagonalSparseMatrix(from: denseSigmaY)
        
        
        XCTAssertEqual(diagSparseSigmaY.space, qubitSpace)
        XCTAssertEqual(diagSparseSigmaY.diagonals[1]!.elements, [0:Complex(real: 0, imag: -1)])
        XCTAssertEqual(diagSparseSigmaY.diagonals[-1]!.elements, [1:Complex(real: 0, imag: 1)])
        XCTAssertNil(diagSparseSigmaY.diagonals[0])
    }
}
//  Created by  M J Everitt on 17/01/2022.
