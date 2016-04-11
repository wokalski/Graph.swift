//
//  GraphTests.swift
//  GraphTests
//
//  Created by Wojciech Czekalski on 10.04.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

import XCTest
@testable import Graph

class DepthSearchTests: XCTestCase {
    let searchFunction = Graphy.depthSearch
    let testElementCount = 50
    
    func testDepthFirstSearchTraverseAllElements() {
        let graph = Graphy.generateRandomTree(testElementCount).0
        let (discovered, processed) = traversedElements(graph, searchFunction: searchFunction)
        
        XCTAssertEqual(testElementCount, discovered.count)
        XCTAssertEqual(testElementCount, processed.count)
    }
    
    func testDepthFirstNodeVisitedTwice() {
        let (graph, _) = Graphy.generateRandomTree(testElementCount)
        let visits = numberOfVisits(graph, searchFunction: searchFunction)
        
        XCTAssertEqual(testElementCount, visits.discoveredVisits)
        XCTAssertEqual(testElementCount, visits.processedVisits)
    }

    
    func testDepthFirstDiscoverAllEdges() {
        let (graph, numberOfEdges) = Graphy.generateRandomTree(testElementCount)
        var discoveredEdges = 0
        
        searchFunction(graph)(edgeFound: { edge in
            discoveredEdges += 1
            return true
        }, nodeStatusChanged: nil)
        XCTAssertEqual(numberOfEdges, discoveredEdges)
    }
    
    func testDepthSearchGoesDepthFirst() {
        let testTree = TestTree(acyclic: true)
        let graph = Graphy(nodes: [testTree.root])
        let (discovered, processed) = traversalOrder(graph, searchFunction: searchFunction)
        let discoveredBefore: (Nodey<Int>, Nodey<Int>) -> Bool = { a, b in
            return discovered.indexOf(a) < discovered.indexOf(b)
        }
        let processedAfter: (Nodey<Int>, Nodey<Int>) -> Bool = { a, b in
            return processed.indexOf(a) > processed.indexOf(b)
        }
        
        XCTAssertTrue(discoveredBefore(testTree.root, testTree.node1))
        XCTAssertTrue(discoveredBefore(testTree.root, testTree.node2))
        XCTAssertTrue(discoveredBefore(testTree.node1, testTree.leaf1))
        XCTAssertTrue(discoveredBefore(testTree.node2, testTree.leaf2))
        XCTAssertTrue(processedAfter(testTree.root, testTree.node1))
        XCTAssertTrue(processedAfter(testTree.root, testTree.node2))
        XCTAssertTrue(processedAfter(testTree.node1, testTree.leaf1))
        XCTAssertTrue(processedAfter(testTree.node2, testTree.leaf2))
    }
    
    func testTopologicalSort() {
        let testTree = TestTree(acyclic: true)
        if let sorted = Graphy(nodes: [testTree.root]).topologicalSort() {
            let sorted: (Nodey<Int>, Nodey<Int>) -> Bool = { a, b in
                return sorted.indexOf(a) > sorted.indexOf(b)
            }
            XCTAssertTrue(sorted(testTree.root, testTree.node1))
            XCTAssertTrue(sorted(testTree.root, testTree.node2))
            XCTAssertTrue(sorted(testTree.node1, testTree.leaf1))
            XCTAssertTrue(sorted(testTree.node2, testTree.leaf2))
        } else {
            XCTFail("Topological sort not found")
        }
    }
    
    func testSearchIsStopped() {
        let (graph, _) = Graphy.generateRandomTree(testElementCount)
        let stopAfter = 5
        var nodeProcessedCounter = 0
        var edgeProcessedCounter = 0
        let nodeProcessed = { (nodeInfo: NodeInfo<Nodey<Int>>) -> Bool in
            nodeProcessedCounter += 1
            if nodeProcessedCounter == stopAfter {
                return false
            }
            return true
        }
        let edgeProcessed = { (edge: Edge<Nodey<Int>>) -> Bool in
            edgeProcessedCounter += 1
            if edgeProcessedCounter == stopAfter {
                return false
            }
            return true
        }
        
        graph.depthSearch(edgeFound: nil, nodeStatusChanged: nodeProcessed)
        graph.depthSearch(edgeFound: edgeProcessed, nodeStatusChanged: nil)
        
        XCTAssertEqual(nodeProcessedCounter, stopAfter)
        XCTAssertEqual(edgeProcessedCounter, stopAfter)
    }
    
    func testTopologicalSortCircularGraph() {
        let testTree = TestTree(acyclic: false)
        XCTAssertNil(Graphy(nodes: [testTree.root]).topologicalSort())
    }
    
    func testNotAcyclic() {
        let testTree = TestTree(acyclic: false)
        XCTAssertFalse(Graphy(nodes: [testTree.root]).isAcyclic())
    }
    
    func testAcyclic() {
        let testTree = TestTree(acyclic: true)
        XCTAssertTrue(Graphy(nodes: [testTree.root]).isAcyclic())
    }
}

class BreadthSearchTests: XCTestCase {
    let searchFunction = Graphy.breadthSearch
    let testElementCount = 50
    
    func testBreadthFirstSearchTraverseAllElements() {
        let graph = Graphy.generateRandomTree(testElementCount).0
        let (discovered, processed) = traversedElements(graph, searchFunction: searchFunction)
        
        XCTAssertEqual(testElementCount, discovered.count)
        XCTAssertEqual(testElementCount, processed.count)
    }
    
    func testBreadthEachNodeVisitedTwice() {
        let (graph, _) = Graphy.generateRandomTree(testElementCount)
        let visits = numberOfVisits(graph, searchFunction: Graphy.breadthSearch)
        
        XCTAssertEqual(testElementCount, visits.discoveredVisits)
        XCTAssertEqual(testElementCount, visits.processedVisits)
    }
    
    func testBreadthSearchGoesBreadthFirst() {
        let testTree = TestTree(acyclic: true)
        let graph = Graphy(nodes: [testTree.root])
        let (discovered, processed) = traversalOrder(graph, searchFunction: searchFunction)
        let discoveredAndProcessedBefore: (Nodey<Int>, Nodey<Int>) -> Bool = { a, b in
            return discovered.indexOf(a) < discovered.indexOf(b) && processed.indexOf(a) < processed.indexOf(b)
        }
        
        XCTAssertTrue(discoveredAndProcessedBefore(testTree.root, testTree.node1))
        XCTAssertTrue(discoveredAndProcessedBefore(testTree.root, testTree.node2))
        XCTAssertTrue(discoveredAndProcessedBefore(testTree.node1, testTree.leaf1))
        XCTAssertTrue(discoveredAndProcessedBefore(testTree.node2, testTree.leaf2))
    }
}

// MARK: Test helpers

func numberOfVisits<G: Graph, T>(graph: G, searchFunction: (G -> ((Edge<T> -> Bool)?, (NodeInfo<T> -> Bool)?) -> Void)) -> (discoveredVisits: Int, processedVisits: Int) {
    var discoveredCalls = 0
    var processedCalls = 0
    
    searchFunction(graph)(nil, { info in
        if info.status == .Discovered {
            discoveredCalls += 1
        } else if info.status == .Processed {
            processedCalls += 1
        }
        return true
    })
    
    return (discoveredCalls, processedCalls)
}

func traversedElements<G: Graph, T>(graph: G, searchFunction: (G -> ((Edge<T> -> Bool)?, (NodeInfo<T> -> Bool)?) -> Void)) -> (discovered: Set<T>, processed: Set<T>) {
    var discovered = Set<T>()
    var processed = Set<T>()
    
    searchFunction(graph)(nil, { info in
        if info.status == .Discovered {
            discovered.insert(info.node)
        } else if info.status == .Processed {
            processed.insert(info.node)
        }
        return true
    })
    return (discovered, processed)
}

func traversalOrder<G: Graph, T>(graph: G, searchFunction: (G -> ((Edge<T> -> Bool)?, (NodeInfo<T> -> Bool)?) -> Void)) -> (discovered: Array<T>, processed: Array<T>) {
    var discovered = Array<T>()
    var processed = Array<T>()
    
    searchFunction(graph)(nil, { info in
        if info.status == .Discovered {
            discovered.append(info.node)
        } else if info.status == .Processed {
            processed.append(info.node)
        }
        return true
    })
    return (discovered, processed)
}

