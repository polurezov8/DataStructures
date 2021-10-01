//
//  HashTable.swift
//  HashTable
//
//  Created by Dmitry Polurezov on 22.09.2021.
//

import XCTest

/// Hash Table: A symbol table of generic key-value pairs.
public struct HashTable<Key: Hashable, Value> {
  private typealias Element = (key: Key, value: Value)
  private typealias Bucket = [Element]

  private var buckets: [Bucket]

  /// The number of key-value pairs in the hash table.
  private(set) var count: Int = .zero

  /// A Boolean value that indicates whether the hash table is empty.
  public var isEmpty: Bool { return count == .zero }

  /// Create a hash table with the given capacity.
  public init(capacity: Int) {
    assert(capacity > .zero)
    buckets = Array<Bucket>(repeatElement([], count: capacity))
  }

  /// Accesses the value associated with
  /// the given key for reading and writing.
  public subscript(key: Key) -> Value? {
    get {
      value(forKey: key)
    }
    set {
      if let value = newValue {
        updateValue(value, forKey: key)
      } else {
        removeValue(forKey: key)
      }
    }
  }

  /// Returns the value for the given key.
  public func value(forKey key: Key) -> Value? {
    let index = self.index(forKey: key)
    for element in buckets[index] {
      if element.key == key {
        return element.value
      }
    }
    return nil  // key not in hash table
  }

  /// Updates the value stored in the hash table for the given key,
  /// or adds a new key-value pair if the key does not exist.
  @discardableResult
  public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
    let index = self.index(forKey: key)

    // Do we already have this key in the bucket?
    for (i, element) in buckets[index].enumerated() {
      if element.key == key {
        let oldValue = element.value
        buckets[index][i].value = value
        return oldValue
      }
    }

    // This key isn't in the bucket yet; add it to the chain.
    buckets[index].append((key: key, value: value))
    count += 1
    return nil
  }


  /// Removes the given key and its associated value from the hash table.
  @discardableResult
  public mutating func removeValue(forKey key: Key) -> Value? {
    let index = self.index(forKey: key)

    // Find the element in the bucket's chain and remove it.
    for (i, element) in buckets[index].enumerated() {
      if element.key == key {
        buckets[index].remove(at: i)
        count -= 1
        return element.value
      }
    }
    return nil  // key not in hash table
  }

  /// Removes all key-value pairs from the hash table.
  public mutating func removeAll() {
    buckets = Array<Bucket>(repeatElement([], count: buckets.count))
    count = .zero
  }

  /// Returns the given key's array index.
  private func index(forKey key: Key) -> Int {
    abs(key.hashValue % buckets.count)
  }
}

extension HashTable: CustomStringConvertible {
  /// A string that represents the contents of the hash table.
  public var description: String {
    let pairs = buckets.flatMap { b in b.map { e in "\(e.key) = \(e.value)" } }
    return pairs.joined(separator: ", ")
  }

  /// A string that represents the contents of
  /// the hash table, suitable for debugging.
  public var debugDescription: String {
    var string = ""
    for (index, bucket) in buckets.enumerated() {
      let pairs = bucket.map { e in "\(e.key) = \(e.value)" }
      string += "bucket \(index): " + pairs.joined(separator: ", ") + "\n"
    }
    return string
  }
}

class HashTableTests: XCTestCase {

  func testIsEmpty() {
    var hashTable = HashTable<Int, String>(capacity: 3)
    hashTable[1] = "First element"

    XCTAssertFalse(hashTable.isEmpty)

    hashTable.removeValue(forKey: 1)
    XCTAssertTrue(hashTable.isEmpty)
  }

  func testValueForKey() {
    let element = "First element"
    var hashTable = HashTable<Int, String>(capacity: 3)
    hashTable[1] = element

    let value = hashTable.value(forKey: 1)
    XCTAssertEqual(value, element)
  }

  func testUpdateValue() {
    let element = "First element"
    var hashTable = HashTable<Int, String>(capacity: 3)
    hashTable[1] = element

    XCTAssertEqual(hashTable.value(forKey: 1), element)

    let newValue = "New first value"
    hashTable[1] = newValue
    XCTAssertEqual(hashTable.value(forKey: 1), newValue)
  }

  func testRemoveValue() {
    let element = "First element"
    var hashTable = HashTable<Int, String>(capacity: 3)
    hashTable[1] = element

    XCTAssertFalse(hashTable.isEmpty)

    let removedValue = hashTable.removeValue(forKey: 1)
    XCTAssertNotNil(removedValue)
    XCTAssertEqual(removedValue, element)
    XCTAssertTrue(hashTable.isEmpty)
  }

  func testDebugDescription() {
    let element = "First element"
    var hashTable = HashTable<Int, String>(capacity: 3)
    hashTable[1] = element

    XCTAssertEqual("1 = First element", hashTable.description)
  }
}
