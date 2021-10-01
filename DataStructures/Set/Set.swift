//
//  Set.swift
//  Set
//
//  Created by Dmitry Polurezov on 22.09.2021.
//

import XCTest

/// An ordered set is an ordered collection of instances of `Element` in which
/// uniqueness of the objects is guaranteed.
public struct OrderedSet<E: Hashable>: Equatable, Collection {
  public typealias Element = E
  public typealias Index = Int
  public typealias Indices = Range<Int>

  private var array: [Element]
  private var set: Set<Element>

  /// Creates an empty ordered set.
  public init() {
    array = []
    set = Set()
  }

  /// Creates an ordered set with the contents of `array`.
  ///
  /// If an element occurs more than once in `element`, only the first one
  /// will be included.
  public init(_ array: [Element]) {
    self.init()
    for element in array {
      append(element)
    }
  }

  // MARK: Working with an ordered set

  /// The number of elements the ordered set stores.
  public var count: Int { array.count }

  /// Returns `true` if the set is empty.
  public var isEmpty: Bool { array.isEmpty }

  /// Returns the contents of the set as an array.
  public var contents: [Element] { array }

  /// Returns `true` if the ordered set contains `member`.
  public func contains(_ member: Element) -> Bool {
    set.contains(member)
  }

  /// Adds an element to the ordered set.
  ///
  /// If it already contains the element, then the set is unchanged.
  ///
  /// - returns: True if the item was inserted.
  @discardableResult
  public mutating func append(_ newElement: Element) -> Bool {
    let inserted = set.insert(newElement).inserted
    if inserted {
      array.append(newElement)
    }
    return inserted
  }

  /// Remove and return the element at the beginning of the ordered set.
  public mutating func removeFirst() -> Element {
    let firstElement = array.removeFirst()
    set.remove(firstElement)
    return firstElement
  }

  /// Remove and return the element at the end of the ordered set.
  public mutating func removeLast() -> Element {
    let lastElement = array.removeLast()
    set.remove(lastElement)
    return lastElement
  }

  /// Remove all elements.
  public mutating func removeAll(keepingCapacity keepCapacity: Bool) {
    array.removeAll(keepingCapacity: keepCapacity)
    set.removeAll(keepingCapacity: keepCapacity)
  }

  /// Inserts new unique contents of `Array` into the `OrderedSet`
  /// - Parameter array: `Array` of contents to insert
  public mutating func insert(_ array: [Element]) {
    array.forEach { self.append($0) }
  }
}

extension OrderedSet: ExpressibleByArrayLiteral {
  /// Create an instance initialized with `elements`.
  ///
  /// If an element occurs more than once in `element`, only the first one
  /// will be included.
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}

extension OrderedSet: RandomAccessCollection {
  public var startIndex: Int { contents.startIndex }
  public var endIndex: Int { contents.endIndex }
  public subscript(index: Int) -> Element {
    contents[index]
  }
}

public func == <T>(lhs: OrderedSet<T>, rhs: OrderedSet<T>) -> Bool {
  lhs.contents == rhs.contents
}

extension OrderedSet: Hashable where Element: Hashable {}

public extension OrderedSet {
  mutating func remove(_ element: Element) {
    array.remove(element)
    set.remove(element)
  }

  mutating func remove(at index: Int) {
    let element = array[index]
    array.remove(at: index)
    set.remove(element)
  }
}

public extension Array where Element: Equatable {
  mutating func remove(_ element: Element) {
    if let index = firstIndex(of: element) {
      remove(at: index)
    }
  }
}

class OrderedSetTests: XCTestCase {

  func testSetUnique() {
    let orderedSet = OrderedSet([1, 2, 3, 1, 2, 3])

    XCTAssertEqual(orderedSet.count, 3)
  }

  func testSetOrder() {
    let orderedSet = OrderedSet([1, 2, 3, 1])

    let elementByIndex = orderedSet[1]
    XCTAssertEqual(elementByIndex, 2)
  }
}
