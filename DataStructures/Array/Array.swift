//
//  Array.swift
//  Array
//
//  Created by Dmitry Polurezov on 22.09.2021.
//

import XCTest

/// Two-dimensional array with a fixed number of rows and columns.
/// This is mostly handy for games that are played on a grid, such as chess.
public struct Array2D<T> {
  public let columns: Int
  public let rows: Int
  private(set) var array: [T]

  public init(columns: Int, rows: Int, initialValue: T) {
    self.columns = columns
    self.rows = rows
    array = .init(repeating: initialValue, count: rows * columns)
  }

  public subscript(column: Int, row: Int) -> T {
    get {
      precondition(column < columns, "Column \(column) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))")
      precondition(row < rows, "Row \(row) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))")
      return array[row * columns + column]
    }
    set {
      precondition(column < columns, "Column \(column) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))")
      precondition(row < rows, "Row \(row) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))")
      array[row * columns + column] = newValue
    }
  }
}

class Array2DTestFunctionality {

  func test() {
    // Initialization
    var matrix = Array2D(columns: 3, rows: 5, initialValue: 0)

    // Makes an array of rows * columns elements all filled with zero
    debugPrint(matrix.array)

    /* Let's create an 2D Array like below setting numbers using subscript [x, y]:
     "[""1 ""7 ""0""]"
     "[""3 ""8 ""0""]"
     "[""2 ""6 ""0""]"
     "[""21 ""8 ""9""]"
     "[""0 ""10 ""0""]"
     */

    matrix[0, 0] = 1
    matrix[1, 0] = 7
    matrix[0, 1] = 3
    matrix[1, 1] = 8
    matrix[0, 2] = 2
    matrix[1, 2] = 6
    matrix[0, 3] = 21
    matrix[1, 3] = 8
    matrix[2, 3] = 9
    matrix[1, 4] = 10

    // Now the numbers are set in the array
    debugPrint(matrix.array)

    // debugPrint out the 2D array with a reference around the grid
    for row in .zero..<matrix.rows {
      debugPrint("[", terminator: "")
      for column in .zero..<matrix.columns {
        if column == matrix.columns - 1 {
          debugPrint("\(matrix[column, row])", terminator: "")
        } else {
          debugPrint("\(matrix[column, row]) ", terminator: "")
        }
      }
      debugPrint("]")
    }
  }
}

class Array2DTest: XCTestCase {

  func testArray2DTestFunctionality() {
    let functionalityClass = Array2DTestFunctionality()
    functionalityClass.test()
  }

  func testIntegerArrayWithPositiveRowsAndColumns() {
    let array = Array2D<Int>(columns: 3, rows: 2, initialValue: 0)

    XCTAssertEqual(array.columns, 3, "Column count setup failed")
    XCTAssertEqual(array.rows, 2, "Rows count setup failed")
    XCTAssertEqual(array[2, 1], 0, "Integer array: Initialization value is wrong")
  }

  func testStringArrayWithPositiveRowsAndColumns() {
    let array = Array2D<String>(columns: 3, rows: 2, initialValue: "empty")

    XCTAssertEqual(array.columns, 3, "Column count setup failed")
    XCTAssertEqual(array.rows, 2, "Rows count setup failed")
    XCTAssertEqual(array[2, 1], "empty", "String array: Initialization value is wrong")
  }

  func testCustomClassArrayWithPositiveRowsAndColumns() {
    let array = Array2D<TestElement>(columns: 3, rows: 2, initialValue: TestElement(identifier: "RR"))

    XCTAssertEqual(array.columns, 3, "Column count setup failed")
    XCTAssertEqual(array.rows, 2, "Rows count setup failed")
    XCTAssertEqual(array[2, 1], TestElement(identifier: "RR"), "Custom Class array: Initialization value is wrong")
  }
}

class TestElement {
  let identifier: String

  init(identifier: String) {
    self.identifier = identifier
  }
}

extension TestElement : Equatable {
  static func == (lhs: TestElement, rhs: TestElement) -> Bool { lhs.identifier == rhs.identifier }
}
