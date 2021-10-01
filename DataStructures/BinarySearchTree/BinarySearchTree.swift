//
//  BinarySearchTree.swift
//  BinarySearchTree
//
//  Created by Dmitry Polurezov on 26.09.2021.
//

import XCTest

/*
  A binary search tree.

  Each node stores a value and two children.
  The left child contains a smaller value.
  The right a larger (or equal) value.

  This tree allows duplicate elements.
*/
public class BinarySearchTree<T: Comparable> {
  private(set) public var value: T
  private(set) public var parent: BinarySearchTree?
  private(set) public var left: BinarySearchTree?
  private(set) public var right: BinarySearchTree?

  public init(value: T) {
    self.value = value
  }

  public convenience init(array: [T]) {
    precondition(!array.isEmpty)

    self.init(value: array.first!)
    for value in array.dropFirst() {
      insert(value: value)
    }
  }

  public var isRoot: Bool { parent == nil }
  public var isLeaf: Bool { left == nil && right == nil }
  public var isLeftChild: Bool { parent?.left === self }
  public var isRightChild: Bool { parent?.right === self }
  public var hasLeftChild: Bool { left != nil }
  public var hasRightChild: Bool { right != nil }
  public var hasAnyChild: Bool { hasLeftChild || hasRightChild }
  public var hasBothChildren: Bool { hasLeftChild && hasRightChild }

  // How many nodes are in this subtree. Performance: O(n).
  public var count: Int { (left?.count ?? .zero) + 1 + (right?.count ?? .zero) }
}

// MARK: - Adding items

extension BinarySearchTree {
  /*
    Inserts a new element into the tree. You should only insert elements
    at the root, to make to sure this remains a valid binary tree!
    Performance: runs in O(h) time, where h is the height of the tree.
  */
  public func insert(value: T) {
    if value < self.value {
      if let left = left {
        left.insert(value: value)
      } else {
        left = BinarySearchTree(value: value)
        left?.parent = self
      }
    } else {
      if let right = right {
        right.insert(value: value)
      } else {
        right = BinarySearchTree(value: value)
        right?.parent = self
      }
    }
  }
}

// MARK: - Deleting items

extension BinarySearchTree {
  /*
    Deletes a node from the tree.

    Returns the node that has replaced this removed one (or nil if this was a
    leaf node). That is primarily useful for when you delete the root node, in
    which case the tree gets a new root.

    Performance: runs in O(h) time, where h is the height of the tree.
  */
  @discardableResult
  public func remove() -> BinarySearchTree? {
    let replacement: BinarySearchTree?

    // Replacement for current node can be either biggest one on the left or
    // smallest one on the right, whichever is not nil
    if let right = right {
      replacement = right.minimum()
    } else if let left = left {
      replacement = left.maximum()
    } else {
      replacement = nil
    }

    replacement?.remove()

    // Place the replacement on current node's position
    replacement?.right = right
    replacement?.left = left
    right?.parent = replacement
    left?.parent = replacement
    reconnectParentTo(node: replacement)

    // The current node is no longer part of the tree, so clean it up.
    parent = nil
    left = nil
    right = nil

    return replacement
  }

  private func reconnectParentTo(node: BinarySearchTree?) {
    if let parent = parent {
      if isLeftChild {
        parent.left = node
      } else {
        parent.right = node
      }
    }
    node?.parent = parent
  }
}

// MARK: - Searching

extension BinarySearchTree {
  /*
    Finds the "highest" node with the specified value.
    Performance: runs in O(h) time, where h is the height of the tree.
  */
  public func search(value: T) -> BinarySearchTree? {
    var node: BinarySearchTree? = self
    while let n = node {
      if value < n.value {
        node = n.left
      } else if value > n.value {
        node = n.right
      } else {
        return node
      }
    }
    return nil
  }

  /*
  // Recursive version of search
  public func search(value: T) -> BinarySearchTree? {
    if value < self.value {
      return left?.search(value)
    } else if value > self.value {
      return right?.search(value)
    } else {
      return self  // found it!
    }
  }
  */

  public func contains(value: T) -> Bool {
    search(value: value) != nil
  }

  // Returns the leftmost descendent. O(h) time.
  public func minimum() -> BinarySearchTree {
    var node = self
    while let next = node.left {
      node = next
    }
    return node
  }

  // Returns the rightmost descendent. O(h) time.
  public func maximum() -> BinarySearchTree {
    var node = self
    while let next = node.right {
      node = next
    }
    return node
  }

  /*
    Calculates the depth of this node, i.e. the distance to the root.
    Takes O(h) time.
  */
  public func depth() -> Int {
    var node = self
    var edges: Int = .zero
    while let parent = node.parent {
      node = parent
      edges += 1
    }
    return edges
  }

  /*
    Calculates the height of this node, i.e. the distance to the lowest leaf.
    Since this looks at all children of this node, performance is O(n).
  */
  public func height() -> Int {
    return isLeaf ? .zero : 1 + max(left?.height() ?? .zero, right?.height() ?? .zero)
  }

  // Finds the node whose value precedes our value in sorted order.
  public func predecessor() -> BinarySearchTree? {
    if let left = left {
      return left
    } else {
      var node = self
      while let parent = node.parent {
        if parent.value < value { return parent }
        node = parent
      }
    }

    return nil
  }

  // Finds the node whose value succeeds our value in sorted order.
  public func successor() -> BinarySearchTree? {
      if let right = right {
        return right.minimum()
      } else {
        var node = self
        while let parent = node.parent {
          if parent.value > value { return parent }
          node = parent
        }
        return nil
      }
    }
}

// MARK: - Traversal

extension BinarySearchTree {
  public func traverseInOrder(process: (T) -> Void) {
    left?.traverseInOrder(process: process)
    process(value)
    right?.traverseInOrder(process: process)
  }

  public func traversePreOrder(process: (T) -> Void) {
    process(value)
    left?.traversePreOrder(process: process)
    right?.traversePreOrder(process: process)
  }

  public func traversePostOrder(process: (T) -> Void) {
    left?.traversePostOrder(process: process)
    right?.traversePostOrder(process: process)
    process(value)
  }

  // Performs an in-order traversal and collects the results in an array.
  public func map(formula: (T) -> T) -> [T] {
    var a = [T]()
    if let left = left { a += left.map(formula: formula) }
    a.append(formula(value))
    if let right = right { a += right.map(formula: formula) }
    return a
  }
}

// Is this binary tree a valid binary search tree?
extension BinarySearchTree {
  public func isBST(minValue: T, maxValue: T) -> Bool {
    if value < minValue || value > maxValue { return false }
    let leftBST = left?.isBST(minValue: minValue, maxValue: value) ?? true
    let rightBST = right?.isBST(minValue: value, maxValue: maxValue) ?? true
    return leftBST && rightBST
  }
}

// MARK: - Debugging

extension BinarySearchTree: CustomStringConvertible {
  public var description: String {
    var s = ""
    if let left = left {
      s += "(\(left.description)) <- "
    }
    s += "\(value)"
    if let right = right {
      s += " -> (\(right.description))"
    }
    return s
  }

   public func toArray() -> [T] {
      return map { $0 }
   }

}

class BinarySearchTreeTest: XCTestCase {
  func testRootNode() {
    let tree = BinarySearchTree(value: 8)
    XCTAssertEqual(tree.count, 1)
    XCTAssertEqual(tree.minimum().value, 8)
    XCTAssertEqual(tree.maximum().value, 8)
    XCTAssertEqual(tree.height(), 0)
    XCTAssertEqual(tree.depth(), 0)
    XCTAssertEqual(tree.toArray(), [8])
  }

  func testCreateFromArray() {
    let tree = BinarySearchTree(array: [8, 5, 10, 3, 12, 9, 6, 16])
    XCTAssertEqual(tree.count, 8)
    XCTAssertEqual(tree.toArray(), [3, 5, 6, 8, 9, 10, 12, 16])

    XCTAssertEqual(tree.search(value: 9)!.value, 9)
    XCTAssertNil(tree.search(value: 99))

    XCTAssertEqual(tree.minimum().value, 3)
    XCTAssertEqual(tree.maximum().value, 16)

    XCTAssertEqual(tree.height(), 3)
    XCTAssertEqual(tree.depth(), 0)

    let node1 = tree.search(value: 16)
    XCTAssertNotNil(node1)
    XCTAssertEqual(node1!.height(), 0)
    XCTAssertEqual(node1!.depth(), 3)

    let node2 = tree.search(value: 12)
    XCTAssertNotNil(node2)
    XCTAssertEqual(node2!.height(), 1)
    XCTAssertEqual(node2!.depth(), 2)

    let node3 = tree.search(value: 10)
    XCTAssertNotNil(node3)
    XCTAssertEqual(node3!.height(), 2)
    XCTAssertEqual(node3!.depth(), 1)
  }

  func testInsert() {
    let tree = BinarySearchTree(value: 8)

    tree.insert(value: 5)
    XCTAssertEqual(tree.count, 2)
    XCTAssertEqual(tree.height(), 1)
    XCTAssertEqual(tree.depth(), 0)

    let node1 = tree.search(value: 5)
    XCTAssertNotNil(node1)
    XCTAssertEqual(node1!.height(), 0)
    XCTAssertEqual(node1!.depth(), 1)

    tree.insert(value: 10)
    XCTAssertEqual(tree.count, 3)
    XCTAssertEqual(tree.height(), 1)
    XCTAssertEqual(tree.depth(), 0)

    let node2 = tree.search(value: 10)
    XCTAssertNotNil(node2)
    XCTAssertEqual(node2!.height(), 0)
    XCTAssertEqual(node2!.depth(), 1)

    tree.insert(value: 3)
    XCTAssertEqual(tree.count, 4)
    XCTAssertEqual(tree.height(), 2)
    XCTAssertEqual(tree.depth(), 0)

    let node3 = tree.search(value: 3)
    XCTAssertNotNil(node3)
    XCTAssertEqual(node3!.height(), 0)
    XCTAssertEqual(node3!.depth(), 2)
    XCTAssertEqual(node1!.height(), 1)
    XCTAssertEqual(node1!.depth(), 1)

    XCTAssertEqual(tree.minimum().value, 3)
    XCTAssertEqual(tree.maximum().value, 10)
    XCTAssertEqual(tree.toArray(), [3, 5, 8, 10])
  }

  func testInsertDuplicates() {
    let tree = BinarySearchTree(array: [8, 5, 10])
    tree.insert(value: 8)
    tree.insert(value: 5)
    tree.insert(value: 10)
    XCTAssertEqual(tree.count, 6)
    XCTAssertEqual(tree.toArray(), [5, 5, 8, 8, 10, 10])
  }

  func testTraversing() {
    let tree = BinarySearchTree(array: [8, 5, 10, 3, 12, 9, 6, 16])

    var inOrder = [Int]()
    tree.traverseInOrder { inOrder.append($0) }
    XCTAssertEqual(inOrder, [3, 5, 6, 8, 9, 10, 12, 16])

    var preOrder = [Int]()
    tree.traversePreOrder { preOrder.append($0) }
    XCTAssertEqual(preOrder, [8, 5, 3, 6, 10, 9, 12, 16])

    var postOrder = [Int]()
    tree.traversePostOrder { postOrder.append($0) }
    XCTAssertEqual(postOrder, [3, 6, 5, 9, 16, 12, 10, 8])
  }

  func testInsertSorted() {
    let tree = BinarySearchTree(array: [8, 5, 10, 3, 12, 9, 6, 16].sorted(by: <))
    XCTAssertEqual(tree.count, 8)
    XCTAssertEqual(tree.toArray(), [3, 5, 6, 8, 9, 10, 12, 16])

    XCTAssertEqual(tree.minimum().value, 3)
    XCTAssertEqual(tree.maximum().value, 16)

    XCTAssertEqual(tree.height(), 7)
    XCTAssertEqual(tree.depth(), 0)

    let node1 = tree.search(value: 16)
    XCTAssertNotNil(node1)
    XCTAssertEqual(node1!.height(), 0)
    XCTAssertEqual(node1!.depth(), 7)
  }

  func testRemoveLeaf() {
    let tree = BinarySearchTree(array: [8, 5, 10, 4])

    let node10 = tree.search(value: 10)!
    XCTAssertNil(node10.left)
    XCTAssertNil(node10.right)
    XCTAssertTrue(tree.right === node10)

    let node5 = tree.search(value: 5)!
    XCTAssertTrue(tree.left === node5)

    let node4 = tree.search(value: 4)!
    XCTAssertTrue(node5.left === node4)
    XCTAssertNil(node5.right)

    let replacement1 = node4.remove()
    XCTAssertNil(node5.left)
    XCTAssertNil(replacement1)

    let replacement2 = node5.remove()
    XCTAssertNil(tree.left)
    XCTAssertNil(replacement2)

    let replacement3 = node10.remove()
    XCTAssertNil(tree.right)
    XCTAssertNil(replacement3)

    XCTAssertEqual(tree.count, 1)
    XCTAssertEqual(tree.toArray(), [8])
  }

  func testRemoveOneChildLeft() {
    let tree = BinarySearchTree(array: [8, 5, 10, 4, 9])

    let node4 = tree.search(value: 4)!
    let node5 = tree.search(value: 5)!
    XCTAssertTrue(node5.left === node4)
    XCTAssertTrue(node5 === node4.parent)

    node5.remove()
    XCTAssertTrue(tree.left === node4)
    XCTAssertTrue(tree === node4.parent)
    XCTAssertNil(node4.left)
    XCTAssertNil(node4.right)
    XCTAssertEqual(tree.count, 4)
    XCTAssertEqual(tree.toArray(), [4, 8, 9, 10])

    let node9 = tree.search(value: 9)!
    let node10 = tree.search(value: 10)!
    XCTAssertTrue(node10.left === node9)
    XCTAssertTrue(node10 === node9.parent)

    node10.remove()
    XCTAssertTrue(tree.right === node9)
    XCTAssertTrue(tree === node9.parent)
    XCTAssertNil(node9.left)
    XCTAssertNil(node9.right)
    XCTAssertEqual(tree.count, 3)
    XCTAssertEqual(tree.toArray(), [4, 8, 9])
  }

  func testRemoveOneChildRight() {
    let tree = BinarySearchTree(array: [8, 5, 10, 6, 11])

    let node6 = tree.search(value: 6)!
    let node5 = tree.search(value: 5)!
    XCTAssertTrue(node5.right === node6)
    XCTAssertTrue(node5 === node6.parent)

    node5.remove()
    XCTAssertTrue(tree.left === node6)
    XCTAssertTrue(tree === node6.parent)
    XCTAssertNil(node6.left)
    XCTAssertNil(node6.right)
    XCTAssertEqual(tree.count, 4)
    XCTAssertEqual(tree.toArray(), [6, 8, 10, 11])

    let node11 = tree.search(value: 11)!
    let node10 = tree.search(value: 10)!
    XCTAssertTrue(node10.right === node11)
    XCTAssertTrue(node10 === node11.parent)

    node10.remove()
    XCTAssertTrue(tree.right === node11)
    XCTAssertTrue(tree === node11.parent)
    XCTAssertNil(node11.left)
    XCTAssertNil(node11.right)
    XCTAssertEqual(tree.count, 3)
    XCTAssertEqual(tree.toArray(), [6, 8, 11])
  }

  func testRemoveTwoChildrenSimple() {
    let tree = BinarySearchTree(array: [8, 5, 10, 4, 6, 9, 11])

    let node4 = tree.search(value: 4)!
    let node5 = tree.search(value: 5)!
    let node6 = tree.search(value: 6)!
    XCTAssertTrue(node5.left === node4)
    XCTAssertTrue(node5.right === node6)
    XCTAssertTrue(node5 === node4.parent)
    XCTAssertTrue(node5 === node6.parent)

    let replacement1 = node5.remove()
    XCTAssertTrue(replacement1 === node6)
    XCTAssertTrue(tree.left === node6)
    XCTAssertTrue(tree === node6.parent)
    XCTAssertTrue(node6.left === node4)
    XCTAssertTrue(node6 === node4.parent)
    XCTAssertNil(node5.left)
    XCTAssertNil(node5.right)
    XCTAssertNil(node5.parent)
    XCTAssertNil(node4.left)
    XCTAssertNil(node4.right)
    XCTAssertNotNil(node4.parent)
    XCTAssertEqual(tree.count, 6)
    XCTAssertEqual(tree.toArray(), [4, 6, 8, 9, 10, 11])

    let node9 = tree.search(value: 9)!
    let node10 = tree.search(value: 10)!
    let node11 = tree.search(value: 11)!
    XCTAssertTrue(node10.left === node9)
    XCTAssertTrue(node10.right === node11)
    XCTAssertTrue(node10 === node9.parent)
    XCTAssertTrue(node10 === node11.parent)

    let replacement2 = node10.remove()
    XCTAssertTrue(replacement2 === node11)
    XCTAssertTrue(tree.right === node11)
    XCTAssertTrue(tree === node11.parent)
    XCTAssertTrue(node11.left === node9)
    XCTAssertTrue(node11 === node9.parent)
    XCTAssertNil(node10.left)
    XCTAssertNil(node10.right)
    XCTAssertNil(node10.parent)
    XCTAssertNil(node9.left)
    XCTAssertNil(node9.right)
    XCTAssertNotNil(node9.parent)
    XCTAssertEqual(tree.count, 5)
    XCTAssertEqual(tree.toArray(), [4, 6, 8, 9, 11])
  }

  func testRemoveTwoChildrenComplex() {
    let tree = BinarySearchTree(array: [8, 5, 10, 4, 9, 20, 11, 15, 13])

    let node9 = tree.search(value: 9)!
    let node10 = tree.search(value: 10)!
    let node11 = tree.search(value: 11)!
    let node13 = tree.search(value: 13)!
    let node15 = tree.search(value: 15)!
    let node20 = tree.search(value: 20)!
    XCTAssertTrue(node10.left === node9)
    XCTAssertTrue(node10 === node9.parent)
    XCTAssertTrue(node10.right === node20)
    XCTAssertTrue(node10 === node20.parent)
    XCTAssertTrue(node20.left === node11)
    XCTAssertTrue(node20 === node11.parent)
    XCTAssertTrue(node11.right === node15)
    XCTAssertTrue(node11 === node15.parent)

    let replacement = node10.remove()
    XCTAssertTrue(replacement === node11)
    XCTAssertTrue(tree.right === node11)
    XCTAssertTrue(tree === node11.parent)
    XCTAssertTrue(node11.left === node9)
    XCTAssertTrue(node11 === node9.parent)
    XCTAssertTrue(node11.right === node20)
    XCTAssertTrue(node11 === node20.parent)
    XCTAssertTrue(node20.left === node13)
    XCTAssertTrue(node20 === node13.parent)
    XCTAssertNil(node20.right)
    XCTAssertNil(node10.left)
    XCTAssertNil(node10.right)
    XCTAssertNil(node10.parent)
    XCTAssertEqual(tree.count, 8)
    XCTAssertEqual(tree.toArray(), [4, 5, 8, 9, 11, 13, 15, 20])
  }

  func testRemoveRoot() {
    let tree = BinarySearchTree(array: [8, 5, 10, 4, 9, 20, 11, 15, 13])

    let node9 = tree.search(value: 9)!

    let newRoot = tree.remove()
    XCTAssertTrue(newRoot === node9)
    XCTAssertEqual(newRoot!.value, 9)
    XCTAssertEqual(newRoot!.count, 8)
    XCTAssertEqual(newRoot!.toArray(), [4, 5, 9, 10, 11, 13, 15, 20])

    // The old root is a subtree of a single element.
    XCTAssertEqual(tree.value, 8)
    XCTAssertEqual(tree.count, 1)
    XCTAssertEqual(tree.toArray(), [8])
  }

  func testPredecessor() {
    let tree = BinarySearchTree(array: [3, 11, 16, 22, 30, 40, 56, 60, 63, 65, 67, 70, 95])
    let node = tree.search(value: 40)

    XCTAssertEqual(node!.value, 40)
    XCTAssertEqual(node!.predecessor()!.value, 30)
    XCTAssertEqual(node!.predecessor()!.predecessor()!.value, 22)
    XCTAssertEqual(node!.predecessor()!.predecessor()!.predecessor()!.value, 16)
    XCTAssertEqual(node!.predecessor()!.predecessor()!.predecessor()!.predecessor()!.value, 11)
    XCTAssertEqual(node!.predecessor()!.predecessor()!.predecessor()!.predecessor()!.predecessor()!.value, 3)
    XCTAssertNil(node!.predecessor()!.predecessor()!.predecessor()!.predecessor()!.predecessor()!.predecessor())
  }

  func testSuccessor() {
    let tree = BinarySearchTree(array: [3, 11, 16, 22, 30, 40, 56, 60, 63, 65, 67, 70, 95])
    let node = tree.search(value: 40)

    XCTAssertEqual(node!.value, 40)
    XCTAssertEqual(node!.successor()!.value, 56)
    XCTAssertEqual(node!.successor()!.successor()!.value, 60)
    XCTAssertEqual(node!.successor()!.successor()!.successor()!.value, 63)
    XCTAssertEqual(node!.successor()!.successor()!.successor()!.successor()!.value, 65)
    XCTAssertEqual(node!.successor()!.successor()!.successor()!.successor()!.successor()!.value, 67)
    XCTAssertEqual(node!.successor()!.successor()!.successor()!.successor()!.successor()!.successor()!.value, 70)
    XCTAssertEqual(node!.successor()!.successor()!.successor()!.successor()!.successor()!.successor()!.successor()!.value, 95)
    XCTAssertNil(node!.successor()!.successor()!.successor()!.successor()!.successor()!.successor()!.successor()!.successor())
  }
}
