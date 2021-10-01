//
//  Stack.swift
//  Stack
//
//  Created by Dmitry Polurezov on 22.09.2021.
//

import XCTest

/// Last-in first-out stack (LIFO)
/// Push and pop are O(1) operations.
public struct Stack<T> {
  private var array: [T] = []

  public var isEmpty: Bool { array.isEmpty }
  public var count: Int { array.count }
  public var top: T? { array.last }

  /// Insert an element on to the top of the stack.
  public mutating func push(_ element: T) {
    array.append(element)
  }

  /// Delete the topmost element and return it.
  public mutating func pop() -> T? {
    array.popLast()
  }
}

extension Stack: Sequence {
  public func makeIterator() -> AnyIterator<T> {
    var current = self
    return AnyIterator { return current.pop() }
  }
}

class StackTest: XCTestCase {
  func testEmpty() {
    var stack = Stack<Int>()
    XCTAssertTrue(stack.isEmpty)
    XCTAssertEqual(stack.count, .zero)
    XCTAssertEqual(stack.top, nil)
    XCTAssertNil(stack.pop())
  }

  func testOneElement() {
    var stack = Stack<Int>()

    stack.push(123)
    XCTAssertFalse(stack.isEmpty)
    XCTAssertEqual(stack.count, 1)
    XCTAssertEqual(stack.top, 123)

    let result = stack.pop()
    XCTAssertEqual(result, 123)
    XCTAssertTrue(stack.isEmpty)
    XCTAssertEqual(stack.count, .zero)
    XCTAssertEqual(stack.top, nil)
    XCTAssertNil(stack.pop())
  }

  func testTwoElements() {
    var stack = Stack<Int>()

    stack.push(123)
    stack.push(456)
    XCTAssertFalse(stack.isEmpty)
    XCTAssertEqual(stack.count, 2)
    XCTAssertEqual(stack.top, 456)

    let result1 = stack.pop()
    XCTAssertEqual(result1, 456)
    XCTAssertFalse(stack.isEmpty)
    XCTAssertEqual(stack.count, 1)
    XCTAssertEqual(stack.top, 123)

    let result2 = stack.pop()
    XCTAssertEqual(result2, 123)
    XCTAssertTrue(stack.isEmpty)
    XCTAssertEqual(stack.count, 0)
    XCTAssertEqual(stack.top, nil)
    XCTAssertNil(stack.pop())
  }

  func testMakeEmpty() {
    var stack = Stack<Int>()

    stack.push(123)
    stack.push(456)
    XCTAssertNotNil(stack.pop())
    XCTAssertNotNil(stack.pop())
    XCTAssertNil(stack.pop())

    stack.push(789)
    XCTAssertEqual(stack.count, 1)
    XCTAssertEqual(stack.top, 789)

    let result = stack.pop()
    XCTAssertEqual(result, 789)
    XCTAssertTrue(stack.isEmpty)
    XCTAssertEqual(stack.count, 0)
    XCTAssertEqual(stack.top, nil)
    XCTAssertNil(stack.pop())
  }
}
