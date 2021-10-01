//
//  Queue.swift
//  Queue
//
//  Created by Dmitry Polurezov on 26.09.2021.
//

import XCTest

/// First-in first-out queue (FIFO)
/// New elements are added to the end of the queue. Dequeuing pulls elements from the front of the queue.
/// Enqueuing and dequeuing are O(1) operations.
public struct Queue<T> {

  // MARK: - Private properties

  private var elements: [T] = []

  // MARK: - Public properties

  var isEmpty: Bool { elements.isEmpty }
  var count: Int { elements.count }
  var first: T? { elements.first }
  var last: T? { elements.last }

  // MARK: - Public methods

  public mutating func enqueue(_ element: T) {
    elements.append(element)
  }

  public mutating func dequeue() -> T? {
    isEmpty ? nil : elements.removeFirst()
  }
}

class QueueTest: XCTestCase {
  func testEmpty() {
    var queue = Queue<Int>()
    XCTAssertTrue(queue.isEmpty)
    XCTAssertEqual(queue.count, .zero)
    XCTAssertEqual(queue.first, nil)
    XCTAssertNil(queue.dequeue())
  }

  func testOneElement() {
    var queue = Queue<Int>()

    queue.enqueue(123)
    XCTAssertFalse(queue.isEmpty)
    XCTAssertEqual(queue.count, 1)
    XCTAssertEqual(queue.first, 123)

    let result = queue.dequeue()
    XCTAssertEqual(result, 123)
    XCTAssertTrue(queue.isEmpty)
    XCTAssertEqual(queue.count, .zero)
    XCTAssertEqual(queue.first, nil)
  }

  func testTwoElements() {
    var queue = Queue<Int>()

    queue.enqueue(123)
    queue.enqueue(456)
    XCTAssertFalse(queue.isEmpty)
    XCTAssertEqual(queue.count, 2)
    XCTAssertEqual(queue.first, 123)
    XCTAssertEqual(queue.last, 456)

    let result1 = queue.dequeue()
    XCTAssertEqual(result1, 123)
    XCTAssertFalse(queue.isEmpty)
    XCTAssertEqual(queue.count, 1)
    XCTAssertEqual(queue.first, 456)

    let result2 = queue.dequeue()
    XCTAssertEqual(result2, 456)
    XCTAssertTrue(queue.isEmpty)
    XCTAssertEqual(queue.count, .zero)
    XCTAssertEqual(queue.first, nil)
  }

  func testMakeEmpty() {
    var queue = Queue<Int>()

    queue.enqueue(123)
    queue.enqueue(456)
    XCTAssertNotNil(queue.dequeue())
    XCTAssertNotNil(queue.dequeue())
    XCTAssertNil(queue.dequeue())

    queue.enqueue(789)
    XCTAssertEqual(queue.count, 1)
    XCTAssertEqual(queue.first, 789)

    let result = queue.dequeue()
    XCTAssertEqual(result, 789)
    XCTAssertTrue(queue.isEmpty)
    XCTAssertEqual(queue.count, .zero)
    XCTAssertEqual(queue.first, nil)
  }
}
