//
//  VS.swift
//  VS
//
//  Created by Dmitry Polurezov on 29.09.2021.
//

import XCTest

struct CollectionResult {
  let name: String
  let time: Double
}

struct Result {
  let name: String
  let trial: Int
  let arrayResult: CollectionResult
  let setResult: CollectionResult
  let orderedSet: CollectionResult
  let linkedListResult: CollectionResult

  var results: [CollectionResult] { [arrayResult, setResult, orderedSet, linkedListResult] }
  var best: CollectionResult { results.sorted(by: { $0.time < $1.time }).first! }
  var worst: CollectionResult { results.sorted(by: { $0.time > $1.time }).first! }
}

extension Result: CustomStringConvertible {
  var description: String {
    """
    \n
    ________________________________________________________
    Operation            - \(name)
    Array Time           - \(arrayResult.time)
    Set Time             - \(setResult.time)
    Ordered Set Time     - \(orderedSet.time)
    Linked List Time     - \(linkedListResult.time)
    Diff (Worst - Best)  - \(best.time - worst.time)
    Winner is            - \(best.name)
    ________________________________________________________
    \n
    """
  }
}

extension Array where Element == Result {
  func printResults() {
    self.forEach { print($0.description) }
  }
}

// 16 operations * (10000 repeats * 4 types of data structure) = 640 000 operations
class VS: XCTestCase {
  func testCollections() {
    let repeats = 10_000
    var comparisonRecords: [Result] = []

    let trials = 1
    func compareOperations(
      name: String,
      arrayOperation: () -> (),
      setOperation: () -> (),
      orderedSetOperation: () -> (),
      linkedListOperation: () -> ()
    ) {
      for trial in 1...trials {
        // Array time calculating
        let arrayStartTime = CFAbsoluteTimeGetCurrent()
        for _ in 1...repeats { arrayOperation() }
        let arrayTimeInterval = (CFAbsoluteTimeGetCurrent() - arrayStartTime)

        // Set time calculating
        let setStartTime = CFAbsoluteTimeGetCurrent()
        for _ in 1...repeats { setOperation() }
        let setTimeInterval = (CFAbsoluteTimeGetCurrent() - setStartTime)

        // Ordered Set time calculating
        let orderedSetStartTime = CFAbsoluteTimeGetCurrent()
        for _ in 1...repeats { orderedSetOperation() }
        let orderedSetTimeInterval = (CFAbsoluteTimeGetCurrent() - orderedSetStartTime)

        // Linked List time calculating
        let linkedListStartTime = CFAbsoluteTimeGetCurrent()
        for _ in 1...repeats { linkedListOperation() }
        let linkedListTimeInterval = (CFAbsoluteTimeGetCurrent() - linkedListStartTime)

        comparisonRecords.append(.init(
          name: name,
          trial: trial,
          arrayResult: .init(name: "Array", time: arrayTimeInterval),
          setResult: .init(name: "Set", time: setTimeInterval),
          orderedSet: .init(name: "Ordered Set", time: orderedSetTimeInterval),
          linkedListResult: .init(name: "Linked List", time: linkedListTimeInterval)
        ))
      }
    }

    compareOperations(
      name: "Initialization Without Elements",
      arrayOperation: {
        let _ : [Int] = []
      },
      setOperation: {
        let _ : Set<Int> = []
      },
      orderedSetOperation: {
        let _ : OrderedSet<Int> = []
      },
      linkedListOperation: {
        let _ : LinkedList<Int> = []
      }
    )

    compareOperations(
      name: "Initialization With Elements",
      arrayOperation: {
        let _ : [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
      },
      setOperation: {
        let _ : Set<Int> = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
      },
      orderedSetOperation: {
        let _ : OrderedSet<Int> = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
      },
      linkedListOperation: {
        let _ : LinkedList<Int> = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
      }
    )

    let arrayToCheck: [Int] = Array(Range(1...100))
    let setToCheck: Set<Int> = Set(Range(1...100))
    let orderedSetToCheck: OrderedSet<Int> = OrderedSet(.init(repeating: 10, count: 100))
    let linkedListToCheck: LinkedList<Int> = LinkedList(array: .init(repeating: 10, count: 100))

    compareOperations(
      name: "Initialization With Elements",
      arrayOperation: {
        for _ in arrayToCheck { }
      },
      setOperation: {
        for _ in setToCheck { }
      },
      orderedSetOperation: {
        for _ in orderedSetToCheck { }
      },
      linkedListOperation: {
        for _ in linkedListToCheck { }
      }
    )

    compareOperations(
      name: "Count Elements",
      arrayOperation: {
        let _ = arrayToCheck.count
      },
      setOperation: {
        let _ = setToCheck.count
      },
      orderedSetOperation: {
        let _ = orderedSetToCheck.count
      },
      linkedListOperation: {
        let _ = linkedListToCheck.count
      }
    )

    compareOperations(
      name: "Check If Empty",
      arrayOperation: {
        let _ = arrayToCheck.isEmpty
      },
      setOperation: {
        let _ = setToCheck.isEmpty
      },
      orderedSetOperation: {
        let _ = orderedSetToCheck.isEmpty
      },
      linkedListOperation: {
        let _ = linkedListToCheck.isEmpty
      }
    )

    compareOperations(
      name: "Check If Element Exists (When True)",
      arrayOperation: {
        let _ = arrayToCheck.contains(10)
      },
      setOperation: {
        let _ = setToCheck.contains(10)
      },
      orderedSetOperation: {
        let _ = orderedSetToCheck.contains(10)
      },
      linkedListOperation: {
        let _ = linkedListToCheck.contains(10)
      }
    )

    compareOperations(
      name: "Check If Element Exists (When False)",
      arrayOperation: {
        let _ = arrayToCheck.contains(104)
      },
      setOperation: {
        let _ = setToCheck.contains(104)
      },
      orderedSetOperation: {
        let _ = orderedSetToCheck.contains(104)
      },
      linkedListOperation: {
        let _ = linkedListToCheck.contains(104)
      }
    )

    compareOperations(
      name: "Find Element Index (When Found)",
      arrayOperation: {
        let _ = arrayToCheck.firstIndex(of: 10)
      },
      setOperation: {
        let _ = setToCheck.firstIndex(of: 10)
      },
      orderedSetOperation: {
        let _ = orderedSetToCheck.firstIndex(of: 10)
      },
      linkedListOperation: {
        let _ = linkedListToCheck.firstIndex(of: 10)
      }
    )

    compareOperations(
      name: "Find Element Index (When nil)",
      arrayOperation: {
        let _ = arrayToCheck.firstIndex(of: 104)
      },
      setOperation: {
        let _ = setToCheck.firstIndex(of: 104)
      },
      orderedSetOperation: {
        let _ = orderedSetToCheck.firstIndex(of: 104)
      },
      linkedListOperation: {
        let _ = linkedListToCheck.firstIndex(of: 104)
      }
    )

    compareOperations(
      name: "Find min",
      arrayOperation: {
        let _ = arrayToCheck.min()
      },
      setOperation: {
        let _ = setToCheck.min()
      },
      orderedSetOperation: {
        let _ = orderedSetToCheck.min()
      },
      linkedListOperation: {
        let _ = linkedListToCheck.min()
      }
    )

    compareOperations(
      name: "Find max",
      arrayOperation: {
        let _ = arrayToCheck.max()
      },
      setOperation: {
        let _ = setToCheck.max()
      },
      orderedSetOperation: {
        let _ = orderedSetToCheck.max()
      },
      linkedListOperation: {
        let _ = linkedListToCheck.max()
      }
    )

    compareOperations(
      name: "Sort Elements",
      arrayOperation: {
        let arrayToCheck: [Int] = [3, 15, 4, 5, 1, 12, 11, 2, 7, 9, 10, 14, 6, 8, 13]
        let _ = arrayToCheck.sorted()
      },
      setOperation: {
        let setToCheck: Set<Int> = [3, 15, 4, 5, 1, 12, 11, 2, 7, 9, 10, 14, 6, 8, 13]
        let _ = setToCheck.sorted()
      },
      orderedSetOperation: {
        let orderedSetToCheck: OrderedSet<Int> = [3, 15, 4, 5, 1, 12, 11, 2, 7, 9, 10, 14, 6, 8, 13]
        let _ = orderedSetToCheck.sorted()
      },
      linkedListOperation: {
        let linkedListToCheck: LinkedList<Int> = [3, 15, 4, 5, 1, 12, 11, 2, 7, 9, 10, 14, 6, 8, 13]
        let _ = linkedListToCheck.sorted()
      }
    )

    compareOperations(
      name: "Add Element",
      arrayOperation: {
        var arrayToManipulate: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
        let _ = arrayToManipulate.append(101)
      },
      setOperation: {
        var setToManipulate: Set<Int> = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
        let _ = setToManipulate.insert(101)
      },
      orderedSetOperation: {
        var orderedSetToCheck: OrderedSet<Int> = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
        let _ = orderedSetToCheck.insert([1])
      },
      linkedListOperation: {
        let linkedListToCheck: LinkedList<Int> = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
        let _ = linkedListToCheck.insert(101, at: 10)
      }
    )

    compareOperations(
      name: "Remove First Element",
      arrayOperation: {
        var arrayToManipulate: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
        let _ = arrayToManipulate.removeFirst()
      },
      setOperation: {
        var setToManipulate: Set<Int> = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
        let _ = setToManipulate.removeFirst()
      },
      orderedSetOperation: {
        var orderedSetToManipulate: OrderedSet<Int> = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
        let _ = orderedSetToManipulate.removeFirst()
      },
      linkedListOperation: {
        let linkedListToCheck: LinkedList<Int> = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
        let _ = linkedListToCheck.remove(at: .zero)
      }
    )

    compareOperations(
      name: "Remove Element By Index",
      arrayOperation: {
        var arrayToManipulate: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
        if let index = arrayToManipulate.firstIndex(of: 10) {
          arrayToManipulate.remove(at: index)
        }
      },
      setOperation: {
        var setToManipulate: Set<Int> = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
        if let index = setToManipulate.firstIndex(of: 10) {
          setToManipulate.remove(at: index)
        }
      },
      orderedSetOperation: {
        var orderedSetToManipulate: OrderedSet<Int> = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
        if let index = orderedSetToManipulate.firstIndex(of: 10) {
          orderedSetToManipulate.remove(at: index)
        }
      },
      linkedListOperation: {
        let linkedListToCheck: LinkedList<Int> = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
        if let index = linkedListToCheck.first(where: { $0 == 10 }) {
          linkedListToCheck.remove(at: index)
        }
      }
    )

    compareOperations(
      name: "Remove All Elements",
      arrayOperation: {
        var arrayToManipulate: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
        arrayToManipulate.removeAll()
      },
      setOperation: {
        var setToManipulate: Set<Int> = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
        setToManipulate.removeAll()
      },
      orderedSetOperation: {
        var orderedSetToManipulate: OrderedSet<Int> = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
        orderedSetToManipulate.removeAll(keepingCapacity: false)
      },
      linkedListOperation: {
        let linkedListToCheck: LinkedList<Int> = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
        linkedListToCheck.removeAll()
      }
    )

    comparisonRecords.printResults()
  }
}
