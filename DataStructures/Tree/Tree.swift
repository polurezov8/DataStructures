//
//  Tree.swift
//  Tree
//
//  Created by Dmitry Polurezov on 26.09.2021.
//

import XCTest

final class TreeNode<T> {
  var value: T
  var count: Int { 1 + children.reduce(.zero) { $0 + $1.count } }
  private(set) var children: [TreeNode] = []

  init(_ value: T) {
    self.value = value
  }

  init(_ value: T, children: [TreeNode]) {
    self.value = value
    self.children = children
  }

  func add(child: TreeNode) {
    children.append(child)
  }
}

extension TreeNode: Equatable where T: Equatable {
  static func ==(lhs: TreeNode, rhs: TreeNode) -> Bool {
    lhs.value == rhs.value && lhs.children == rhs.children
  }
}

extension TreeNode: Hashable where T: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(value)
    hasher.combine(children)
  }
}

extension TreeNode: Codable where T: Codable { }

extension TreeNode where T: Equatable {
  func find(_ value: T) -> TreeNode? {
    guard self.value != value else { return self }

    for child in children {
      if let match = child.find(value) {
        return match
      }
    }

    return nil
  }
}

class TreeTests: XCTestCase {
  func testValue() {
    let treeNode = TreeNode(1)
    XCTAssertEqual(treeNode.value, 1)
  }

  func testCount() {
    let treeNode = TreeNode(1)
    XCTAssertEqual(treeNode.count, 1)

    treeNode.add(child: .init(2))
    XCTAssertEqual(treeNode.count, 2)
  }

  func testInitWithChildren() {
    let treeNode = TreeNode(1, children: [.init(2), .init(3), .init(4)])
    XCTAssertNotEqual(treeNode.count, .zero)
    XCTAssertEqual(treeNode.count, 4)
  }

  func testFind() {
    let nodeToFind: TreeNode = .init(4)
    let treeNode = TreeNode(1, children: [.init(2), .init(3), nodeToFind])
    XCTAssertEqual(treeNode.find(4), nodeToFind)
    XCTAssertNotNil(treeNode.find(4))
    XCTAssertNil(treeNode.find(5))
  }
}
