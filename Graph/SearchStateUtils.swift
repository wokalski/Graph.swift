//
//  SearchStateUtils.swift
//  Graph
//
//  Created by Wojciech Czekalski on 10.04.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

/**
 Defines all possible states for a node in a graph.
 */
public enum NodeStatus {
    ///A node which has not been discovered yet
    case New
    ///The node has been discovered. Its children have not been discovered yet.
    case Discovered
    /**
     The node has been processed. Its children were discovered.
        - In DFS it implies that all descendants are Processed too since it goes depth first.
     */
    case Processed
}

/**
 A container for `Node` and its `NodeStatus`
 */
public struct NodeInfo<T: Node> {
    let node: T
    let status: NodeStatus
}

/**
 Defines edge types
*/
public enum EdgeType {
    ///An edge to a node which has not been discovered yet.
    case Tree
    ///An edge to a node which is a predecessor of edge's source node. Implies that a graph is not acyclic.
    case Back
    ///An edge to a node which is not a direct descendant of a node or to a sybling graph.
    case CrossOrForward
}

/**
 Describes a relation between nodes.
*/
public struct Edge<T: Node> {
    let from: NodeInfo<T>
    let to: NodeInfo<T>
    
    func type() -> EdgeType {
        if to.status == .New {
            return .Tree
        } else if to.status == .Discovered {
            return .Back
        } else {
            return .CrossOrForward
        }
    }
}

struct SearchInfo<T: Node> {
    var nodeStatus = Dictionary<T, NodeStatus>()
    
    mutating func set(node: T, status: NodeStatus) {
        if nodeStatus[node] != status {
            nodeStatus[node] = status
        } else {
            abort()
        }
    }
    
    func status(node: T) -> NodeStatus {
        return nodeStatus[node] ?? .New
    }
    
    func nodeInfo(node: T) -> NodeInfo<T> {
        return NodeInfo(node: node, status: status(node))
    }
}
