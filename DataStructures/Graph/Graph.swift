//
//  AdjacencyListGraph.swift
//  Graph
//
//  Created by Dmitry Polurezov on 27.09.2021.
//

import XCTest
import Foundation

// MARK: - Edge

/*
 Each edge of a graph has an associated numerical value, called a weight.
 Usually, the edge weights are non- negative integers.
 Weighted graphs may be either directed or undirected.
 The weight of an edge is often referred to as the "cost" of the edge.
 */
public struct Edge<T>: Equatable where T: Hashable {
  public let from: Vertex<T>
  public let to: Vertex<T>
  public let weight: Double?
}

extension Edge: CustomStringConvertible {
  public var description: String {
    guard let unwrappedWeight = weight else { return "\(from.description) -> \(to.description)" }
    return "\(from.description) -(\(unwrappedWeight))-> \(to.description)"
  }
}

extension Edge: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(from)
    hasher.combine(to)
    hasher.combine(weight)
  }
}

public func == <T>(lhs: Edge<T>, rhs: Edge<T>) -> Bool {
  lhs.from == rhs.from && lhs.to == rhs.to && lhs.weight == rhs.weight
}

// MARK: - Vertex

public struct Vertex<T>: Equatable where T: Hashable {
  public var data: T
  public let index: Int
}

extension Vertex: CustomStringConvertible {
  public var description: String { "\(index): \(data)" }
}

extension Vertex: Hashable {
  public func hasher(into hasher: inout Hasher) {
    hasher.combine(data)
    hasher.combine(index)
  }
}

public func ==<T>(lhs: Vertex<T>, rhs: Vertex<T>) -> Bool {
  lhs.index == rhs.index && lhs.data == rhs.data
}

// MARK: - EdgeList

private class EdgeList<T> where T: Hashable {
  var vertex: Vertex<T>
  var edges: [Edge<T>]?

  init(vertex: Vertex<T>) {
    self.vertex = vertex
  }

  func addEdge(_ edge: Edge<T>) {
    edges?.append(edge)
  }
}

// MARK: - AdjacencyListGraph

class AdjacencyListGraph<T: Hashable> {
  private var adjacencyList: [EdgeList<T>] = []

  var vertices: [Vertex<T>] {
    adjacencyList.map(\.vertex)
  }

  var edges: [Edge<T>] {
    var allEdges: Set<Edge<T>> = []
    for edgeList in adjacencyList {
      guard let edges = edgeList.edges else { continue }

      for edge in edges {
        allEdges.insert(edge)
      }
    }

    return Array(allEdges)
  }

   func createVertex(_ data: T) -> Vertex<T> {
    // Check if the vertex already exists
    let matchingVertices = vertices.filter { vertex in vertex.data == data }

    if !matchingVertices.isEmpty {
      return matchingVertices.last!
    }

    // If the vertex doesn't exist, create a new one
    let vertex = Vertex(data: data, index: adjacencyList.count)
    adjacencyList.append(EdgeList(vertex: vertex))
    return vertex
  }

   func addDirectedEdge(_ from: Vertex<T>, to: Vertex<T>, withWeight weight: Double?) {
    let edge = Edge(from: from, to: to, weight: weight)
    let edgeList = adjacencyList[from.index]
    if edgeList.edges != nil {
      edgeList.addEdge(edge)
    } else {
      edgeList.edges = [edge]
    }
  }

   func addUndirectedEdge(_ vertices: (Vertex<T>, Vertex<T>), withWeight weight: Double?) {
    // TODO
  }

   func weightFrom(_ sourceVertex: Vertex<T>, to destinationVertex: Vertex<T>) -> Double? {
    guard let edges = adjacencyList[sourceVertex.index].edges else { return nil }

    for edge: Edge<T> in edges where edge.to == destinationVertex {
      return edge.weight
    }

    return nil
  }

   func edgesFrom(_ sourceVertex: Vertex<T>) -> [Edge<T>] {
    adjacencyList[sourceVertex.index].edges ?? []
  }

   var description: String {
    var rows: [String] = []
    for edgeList in adjacencyList {
      guard let edges = edgeList.edges else { continue }

      var row: [String] = []
      for edge in edges {
        var value = "\(edge.to.data)"
        if edge.weight != nil {
          value = "(\(value): \(edge.weight!))"
        }
        row.append(value)
      }

      rows.append("\(edgeList.vertex.data) -> [\(row.joined(separator: ", "))]")
    }

    return rows.joined(separator: "\n")
  }
}

class AdjacencyListGraphTests: XCTestCase {

  func testDirectedEdge() {
    let graph = AdjacencyListGraph<Int>()
    let firstVertex = graph.createVertex(1)
    let secondVertex = graph.createVertex(2)
    graph.addDirectedEdge(firstVertex, to: secondVertex, withWeight: 1)

    XCTAssertEqual(graph.vertices.count, 2)
    XCTAssertEqual(graph.vertices[0], firstVertex)
    XCTAssertEqual(graph.vertices[1], secondVertex)
    XCTAssertEqual(graph.edges.count, 1)
  }

  func testAddUndirectedEdge() {
    let graph = AdjacencyListGraph<Int>()
    let firstVertex = graph.createVertex(1)
    let secondVertex = graph.createVertex(2)
    graph.addUndirectedEdge((firstVertex, secondVertex), withWeight: 1)

    XCTAssertEqual(graph.vertices.count, 2)
    XCTAssertEqual(graph.vertices[0], firstVertex)
    XCTAssertEqual(graph.vertices[1], secondVertex)
    XCTAssertEqual(graph.edges.count, 2)
  }
}
