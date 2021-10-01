//
//  Heap.swift
//  Heap
//
//  Created by Dmitry Polurezov on 26.09.2021.
//

import XCTest

public struct Heap<T> {

  // The array that stores the heap's nodes.
  var nodes: [T] = []

  /*
   Determines how to compare two nodes in the heap.
   Use '>' for a max-heap or '<' for a min-heap,
   or provide a comparing method if the heap is made
   of custom elements, for example tuples.
   */
  private var orderCriteria: (T, T) -> Bool

  /**
   Creates an empty heap.
   The sort function determines whether this is a min-heap or max-heap.
   For comparable data types, > makes a max-heap, < makes a min-heap.
   */
  public init(sort: @escaping (T, T) -> Bool) {
    self.orderCriteria = sort
  }

  /**
   Creates a heap from an array. The order of the array does not matter;
   the elements are inserted into the heap in the order determined by the
   sort function. For comparable data types, '>' makes a max-heap,
   '<' makes a min-heap.
   */
  public init(array: [T], sort: @escaping (T, T) -> Bool) {
    self.orderCriteria = sort
    configureHeap(from: array)
  }

  /**
   Configures the max-heap or min-heap from an array, in a bottom-up manner.
   Performance: This runs pretty much in O(n).
   */
  private mutating func configureHeap(from array: [T]) {
    nodes = array
    for index in stride(from: (nodes.count / 2 - 1), through: .zero, by: -1) {
      shiftDown(index)
    }
  }

  public var isEmpty: Bool { nodes.isEmpty }
  public var count: Int { nodes.count }

  /**
   Returns the index of the parent of the element at index i.
   The element at index 0 is the root of the tree and has no parent.
   */
  func parentIndex(ofIndex i: Int) -> Int {
    (i - 1) / 2
  }

  /**
   Returns the index of the left child of the element at index i.
   Note that this index can be greater than the heap size, in which case
   there is no left child.
   */
  func leftChildIndex(ofIndex i: Int) -> Int {
    2 * i + 1
  }

  /**
   Returns the index of the right child of the element at index i.
   Note that this index can be greater than the heap size, in which case
   there is no right child.
   */
  func rightChildIndex(ofIndex i: Int) -> Int {
    2 * i + 2
  }

  /**
   Returns the maximum value in the heap (for a max-heap) or the minimum
   value (for a min-heap).
   */
  public func peek() -> T? {
    nodes.first
  }

  /**
   Adds a new value to the heap. This reorders the heap so that the max-heap
   or min-heap property still holds. Performance: O(log n).
   */
  public mutating func insert(_ value: T) {
    nodes.append(value)
    shiftUp(nodes.count - 1)
  }

  /**
   Adds a sequence of values to the heap. This reorders the heap so that
   the max-heap or min-heap property still holds. Performance: O(log n).
   */
  public mutating func insert<S: Sequence>(_ sequence: S) where S.Iterator.Element == T {
    sequence.forEach { insert($0) }
  }

  /**
   Allows you to change an element. This reorders the heap so that
   the max-heap or min-heap property still holds.
   */
  public mutating func replace(index i: Int, value: T) {
    guard i < nodes.count else { return }

    remove(at: i)
    insert(value)
  }

  /**
   Removes the root node from the heap. For a max-heap, this is the maximum
   value; for a min-heap it is the minimum value. Performance: O(log n).
   */
  @discardableResult
  public mutating func remove() -> T? {
    guard !nodes.isEmpty else { return nil }

    if nodes.count == 1 {
      return nodes.removeLast()
    } else {
      // Use the last node to replace the first one, then fix the heap by
      // shifting this new first node into its proper position.
      let value = nodes[.zero]
      nodes[.zero] = nodes.removeLast()
      shiftDown(.zero)
      return value
    }
  }

  /**
   Removes an arbitrary node from the heap. Performance: O(log n).
   Note that you need to know the node's index.
   */
  @discardableResult
  public mutating func remove(at index: Int) -> T? {
    guard index < nodes.count else { return nil }

    let size = nodes.count - 1
    if index != size {
      nodes.swapAt(index, size)
      shiftDown(from: index, until: size)
      shiftUp(index)
    }
    return nodes.removeLast()
  }

  /**
   Takes a child node and looks at its parents; if a parent is not larger
   (max-heap) or not smaller (min-heap) than the child, we exchange them.
   */
  mutating func shiftUp(_ index: Int) {
    var childIndex = index
    let child = nodes[childIndex]
    var parentIndex = self.parentIndex(ofIndex: childIndex)

    while childIndex > .zero && orderCriteria(child, nodes[parentIndex]) {
      nodes[childIndex] = nodes[parentIndex]
      childIndex = parentIndex
      parentIndex = self.parentIndex(ofIndex: childIndex)
    }

    nodes[childIndex] = child
  }

  /**
   Looks at a parent node and makes sure it is still larger (max-heap) or
   smaller (min-heap) than its children.
   */
  mutating func shiftDown(from index: Int, until endIndex: Int) {
    let leftChildIndex = self.leftChildIndex(ofIndex: index)
    let rightChildIndex = leftChildIndex + 1

    // Figure out which comes first if we order them by the sort function:
    // the parent, the left child, or the right child. If the parent comes
    // first, we're done. If not, that element is out-of-place and we make
    // it "float down" the tree until the heap property is restored.
    var first = index
    if leftChildIndex < endIndex && orderCriteria(nodes[leftChildIndex], nodes[first]) {
      first = leftChildIndex
    }

    if rightChildIndex < endIndex && orderCriteria(nodes[rightChildIndex], nodes[first]) {
      first = rightChildIndex
    }

    if first == index { return }

    nodes.swapAt(index, first)
    shiftDown(from: first, until: endIndex)
  }

  mutating func shiftDown(_ index: Int) {
    shiftDown(from: index, until: nodes.count)
  }

}

// MARK: - Searching

extension Heap where T: Equatable {

  /** Get the index of a node in the heap. Performance: O(n). */
  public func index(of node: T) -> Int? {
    nodes.firstIndex(where: { $0 == node })
  }

  /** Removes the first occurrence of a node from the heap. Performance: O(n). */
  @discardableResult
  public mutating func remove(node: T) -> T? {
    if let index = index(of: node) {
      return remove(at: index)
    }
    return nil
  }
}

import XCTest

class HeapTests: XCTestCase {

  private func verifyMaxHeap(_ h: Heap<Int>) -> Bool {
    for i in 0..<h.count {
      let left = h.leftChildIndex(ofIndex: i)
      let right = h.rightChildIndex(ofIndex: i)
      let parent = h.parentIndex(ofIndex: i)
      if left < h.count && h.nodes[i] < h.nodes[left] { return false }
      if right < h.count && h.nodes[i] < h.nodes[right] { return false }
      if i > 0 && h.nodes[parent] < h.nodes[i] { return false }
    }
    return true
  }

  private func verifyMinHeap(_ h: Heap<Int>) -> Bool {
    for i in 0..<h.count {
      let left = h.leftChildIndex(ofIndex: i)
      let right = h.rightChildIndex(ofIndex: i)
      let parent = h.parentIndex(ofIndex: i)
      if left < h.count && h.nodes[i] > h.nodes[left] { return false }
      if right < h.count && h.nodes[i] > h.nodes[right] { return false }
      if i > 0 && h.nodes[parent] > h.nodes[i] { return false }
    }
    return true
  }

  private func isPermutation(_ array1: [Int], _ array2: [Int]) -> Bool {
    var a1 = array1
    var a2 = array2
    if a1.count != a2.count { return false }
    while a1.count > 0 {
      if let i = a2.firstIndex(of: a1[0]) {
        a1.remove(at: 0)
        a2.remove(at: i)
      } else {
        return false
      }
    }
    return a2.count == 0
  }

  func testEmptyHeap() {
    var heap = Heap<Int>(sort: <)
    XCTAssertTrue(heap.isEmpty)
    XCTAssertEqual(heap.count, 0)
    XCTAssertNil(heap.peek())
    XCTAssertNil(heap.remove())
  }

  func testIsEmpty() {
    var heap = Heap<Int>(sort: >)
    XCTAssertTrue(heap.isEmpty)
    heap.insert(1)
    XCTAssertFalse(heap.isEmpty)
    heap.remove()
    XCTAssertTrue(heap.isEmpty)
  }

  func testCount() {
    var heap = Heap<Int>(sort: >)
    XCTAssertEqual(0, heap.count)
    heap.insert(1)
    XCTAssertEqual(1, heap.count)
  }

  func testMaxHeapOneElement() {
    let heap = Heap<Int>(array: [10], sort: >)
    XCTAssertTrue(verifyMaxHeap(heap))
    XCTAssertTrue(verifyMinHeap(heap))
    XCTAssertFalse(heap.isEmpty)
    XCTAssertEqual(heap.count, 1)
    XCTAssertEqual(heap.peek()!, 10)
  }

  func testCreateMaxHeap() {
    let h1 = Heap(array: [1, 2, 3, 4, 5, 6, 7], sort: >)
    XCTAssertTrue(verifyMaxHeap(h1))
    XCTAssertFalse(verifyMinHeap(h1))
    XCTAssertEqual(h1.nodes, [7, 5, 6, 4, 2, 1, 3])
    XCTAssertFalse(h1.isEmpty)
    XCTAssertEqual(h1.count, 7)
    XCTAssertEqual(h1.peek()!, 7)

    let h2 = Heap(array: [7, 6, 5, 4, 3, 2, 1], sort: >)
    XCTAssertTrue(verifyMaxHeap(h2))
    XCTAssertFalse(verifyMinHeap(h2))
    XCTAssertEqual(h2.nodes, [7, 6, 5, 4, 3, 2, 1])
    XCTAssertFalse(h2.isEmpty)
    XCTAssertEqual(h2.count, 7)
    XCTAssertEqual(h2.peek()!, 7)

    let h3 = Heap(array: [4, 1, 3, 2, 16, 9, 10, 14, 8, 7], sort: >)
    XCTAssertTrue(verifyMaxHeap(h3))
    XCTAssertFalse(verifyMinHeap(h3))
    XCTAssertEqual(h3.nodes, [16, 14, 10, 8, 7, 9, 3, 2, 4, 1])
    XCTAssertFalse(h3.isEmpty)
    XCTAssertEqual(h3.count, 10)
    XCTAssertEqual(h3.peek()!, 16)

    let h4 = Heap(array: [27, 17, 3, 16, 13, 10, 1, 5, 7, 12, 4, 8, 9, 0], sort: >)
    XCTAssertTrue(verifyMaxHeap(h4))
    XCTAssertFalse(verifyMinHeap(h4))
    XCTAssertEqual(h4.nodes, [27, 17, 10, 16, 13, 9, 1, 5, 7, 12, 4, 8, 3, 0])
    XCTAssertFalse(h4.isEmpty)
    XCTAssertEqual(h4.count, 14)
    XCTAssertEqual(h4.peek()!, 27)
  }

  func testCreateMinHeap() {
    let h1 = Heap(array: [1, 2, 3, 4, 5, 6, 7], sort: <)
    XCTAssertTrue(verifyMinHeap(h1))
    XCTAssertFalse(verifyMaxHeap(h1))
    XCTAssertEqual(h1.nodes, [1, 2, 3, 4, 5, 6, 7])
    XCTAssertFalse(h1.isEmpty)
    XCTAssertEqual(h1.count, 7)
    XCTAssertEqual(h1.peek()!, 1)

    let h2 = Heap(array: [7, 6, 5, 4, 3, 2, 1], sort: <)
    XCTAssertTrue(verifyMinHeap(h2))
    XCTAssertFalse(verifyMaxHeap(h2))
    XCTAssertEqual(h2.nodes, [1, 3, 2, 4, 6, 7, 5])
    XCTAssertFalse(h2.isEmpty)
    XCTAssertEqual(h2.count, 7)
    XCTAssertEqual(h2.peek()!, 1)

    let h3 = Heap(array: [4, 1, 3, 2, 16, 9, 10, 14, 8, 7], sort: <)
    XCTAssertTrue(verifyMinHeap(h3))
    XCTAssertFalse(verifyMaxHeap(h3))
    XCTAssertEqual(h3.nodes, [1, 2, 3, 4, 7, 9, 10, 14, 8, 16])
    XCTAssertFalse(h3.isEmpty)
    XCTAssertEqual(h3.count, 10)
    XCTAssertEqual(h3.peek()!, 1)

    let h4 = Heap(array: [27, 17, 3, 16, 13, 10, 1, 5, 7, 12, 4, 8, 9, 0], sort: <)
    XCTAssertTrue(verifyMinHeap(h4))
    XCTAssertFalse(verifyMaxHeap(h4))
    XCTAssertEqual(h4.nodes, [0, 4, 1, 5, 12, 8, 3, 16, 7, 17, 13, 10, 9, 27])
    XCTAssertFalse(h4.isEmpty)
    XCTAssertEqual(h4.count, 14)
    XCTAssertEqual(h4.peek()!, 0)
  }

  func testCreateMaxHeapEqualnodes() {
    let heap = Heap(array: [1, 1, 1, 1, 1], sort: >)
    XCTAssertTrue(verifyMaxHeap(heap))
    XCTAssertTrue(verifyMinHeap(heap))
    XCTAssertEqual(heap.nodes, [1, 1, 1, 1, 1])
  }

  func testCreateMinHeapEqualnodes() {
    let heap = Heap(array: [1, 1, 1, 1, 1], sort: <)
    XCTAssertTrue(verifyMinHeap(heap))
    XCTAssertTrue(verifyMaxHeap(heap))
    XCTAssertEqual(heap.nodes, [1, 1, 1, 1, 1])
  }

  private func randomArray(_ n: Int) -> [Int] {
    var a = [Int]()
    for _ in 0..<n {
      a.append(Int(arc4random()))
    }
    return a
  }

  func testCreateRandomMaxHeap() {
    for n in 1...40 {
      let a = randomArray(n)
      let h = Heap(array: a, sort: >)
      XCTAssertTrue(verifyMaxHeap(h))
      XCTAssertFalse(h.isEmpty)
      XCTAssertEqual(h.count, n)
      XCTAssertTrue(isPermutation(a, h.nodes))
    }
  }

  func testCreateRandomMinHeap() {
    for n in 1...40 {
      let a = randomArray(n)
      let h = Heap(array: a, sort: <)
      XCTAssertTrue(verifyMinHeap(h))
      XCTAssertFalse(h.isEmpty)
      XCTAssertEqual(h.count, n)
      XCTAssertTrue(isPermutation(a, h.nodes))
    }
  }

  func testRemoving() {
    var h = Heap(array: [100, 50, 70, 10, 20, 60, 65], sort: >)
    XCTAssertTrue(verifyMaxHeap(h))
    XCTAssertEqual(h.nodes, [100, 50, 70, 10, 20, 60, 65])

    //test index out of bounds
    let v = h.remove(at: 10)
    XCTAssertEqual(v, nil)
    XCTAssertTrue(verifyMaxHeap(h))
    XCTAssertEqual(h.nodes, [100, 50, 70, 10, 20, 60, 65])

    let v1 = h.remove(at: 5)
    XCTAssertEqual(v1, 60)
    XCTAssertTrue(verifyMaxHeap(h))
    XCTAssertEqual(h.nodes, [100, 50, 70, 10, 20, 65])

    let v2 = h.remove(at: 4)
    XCTAssertEqual(v2, 20)
    XCTAssertTrue(verifyMaxHeap(h))
    XCTAssertEqual(h.nodes, [100, 65, 70, 10, 50])

    let v3 = h.remove(at: 4)
    XCTAssertEqual(v3, 50)
    XCTAssertTrue(verifyMaxHeap(h))
    XCTAssertEqual(h.nodes, [100, 65, 70, 10])

    let v4 = h.remove(at: 0)
    XCTAssertEqual(v4, 100)
    XCTAssertTrue(verifyMaxHeap(h))
    XCTAssertEqual(h.nodes, [70, 65, 10])

    XCTAssertEqual(h.peek()!, 70)
    let v5 = h.remove()
    XCTAssertEqual(v5, 70)
    XCTAssertTrue(verifyMaxHeap(h))
    XCTAssertEqual(h.nodes, [65, 10])

    XCTAssertEqual(h.peek()!, 65)
    let v6 = h.remove()
    XCTAssertEqual(v6, 65)
    XCTAssertTrue(verifyMaxHeap(h))
    XCTAssertEqual(h.nodes, [10])

    XCTAssertEqual(h.peek()!, 10)
    let v7 = h.remove()
    XCTAssertEqual(v7, 10)
    XCTAssertTrue(verifyMaxHeap(h))
    XCTAssertEqual(h.nodes, [])

    XCTAssertNil(h.peek())
  }

  func testRemoveEmpty() {
    var heap = Heap<Int>(sort: >)
    let removed = heap.remove()
    XCTAssertNil(removed)
  }

  func testRemoveRoot() {
    var h = Heap(array: [15, 13, 9, 5, 12, 8, 7, 4, 0, 6, 2, 1], sort: >)
    XCTAssertTrue(verifyMaxHeap(h))
    XCTAssertEqual(h.nodes, [15, 13, 9, 5, 12, 8, 7, 4, 0, 6, 2, 1])
    XCTAssertEqual(h.peek()!, 15)
    let v = h.remove()
    XCTAssertEqual(v, 15)
    XCTAssertTrue(verifyMaxHeap(h))
    XCTAssertEqual(h.nodes, [13, 12, 9, 5, 6, 8, 7, 4, 0, 1, 2])
  }

  func testRemoveRandomItems() {
    for n in 1...40 {
      var a = randomArray(n)
      var h = Heap(array: a, sort: >)
      XCTAssertTrue(verifyMaxHeap(h))
      XCTAssertTrue(isPermutation(a, h.nodes))

      let m = (n + 1)/2
      for k in 1...m {
        let i = Int(arc4random_uniform(UInt32(n - k + 1)))
        let v = h.remove(at: i)!
        let j = a.firstIndex(of: v)!
        a.remove(at: j)

        XCTAssertTrue(verifyMaxHeap(h))
        XCTAssertEqual(h.count, a.count)
        XCTAssertEqual(h.count, n - k)
        XCTAssertTrue(isPermutation(a, h.nodes))
      }
    }
  }

  func testInsert() {
    var h = Heap(array: [15, 13, 9, 5, 12, 8, 7, 4, 0, 6, 2, 1], sort: >)
    XCTAssertTrue(verifyMaxHeap(h))
    XCTAssertEqual(h.nodes, [15, 13, 9, 5, 12, 8, 7, 4, 0, 6, 2, 1])

    h.insert(10)
    XCTAssertTrue(verifyMaxHeap(h))
    XCTAssertEqual(h.nodes, [15, 13, 10, 5, 12, 9, 7, 4, 0, 6, 2, 1, 8])
  }

  func testInsertArrayAndRemove() {
    var heap = Heap<Int>(sort: >)
    heap.insert([1, 3, 2, 7, 5, 9])
    XCTAssertEqual(heap.nodes, [9, 5, 7, 1, 3, 2])

    XCTAssertEqual(9, heap.remove())
    XCTAssertEqual(7, heap.remove())
    XCTAssertEqual(5, heap.remove())
    XCTAssertEqual(3, heap.remove())
    XCTAssertEqual(2, heap.remove())
    XCTAssertEqual(1, heap.remove())
    XCTAssertNil(heap.remove())
  }

  func testReplace() {
    var h = Heap(array: [16, 14, 10, 8, 7, 9, 3, 2, 4, 1], sort: >)
    XCTAssertTrue(verifyMaxHeap(h))

    h.replace(index: 5, value: 13)
    XCTAssertTrue(verifyMaxHeap(h))

    //test index out of bounds
    h.replace(index: 20, value: 2)
    XCTAssertTrue(verifyMaxHeap(h))
  }
}
