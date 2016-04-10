//
//  SearchStateUtils.swift
//  Graph
//
//  Created by Wojciech Czekalski on 10.04.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

public enum NodeStatus {
    case New
    case Discovered
    case Processed
}

public struct NodeInfo<T: Node> {
    let node: T
    let status: NodeStatus
}

public enum EdgeType {
    case CrossOrForward
    case Back
    case Tree
}

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

public struct SearchHandler<T: Node> {
    let nodeChangedStatus: (NodeInfo<T> -> Bool)?
    let newEdgeFound: (Edge<T> -> Bool)?
    
    init(nodeChangedStatus: (NodeInfo<T> -> Bool)? = nil, newEdgeFound: (Edge<T> -> Bool)? = nil) {
        self.nodeChangedStatus = nodeChangedStatus
        self.newEdgeFound = newEdgeFound
    }
}

struct SearchInfo<T: Node> {
    var nodeStatus = Dictionary<T, NodeStatus>()
    
    mutating func set(node: T, status: NodeStatus) {
        nodeStatus[node] = status
    }
    
    func status(node: T) -> NodeStatus {
        return nodeStatus[node] ?? .New
    }
    
    func nodeInfo(node: T) -> NodeInfo<T> {
        return NodeInfo(node: node, status: status(node))
    }
}

extension SearchHandler {
    static func isAcyclicHandler(inout result: Bool) -> (Edge<T> -> Bool)? {
        return { edge in
            if edge.to.status == .Discovered {
                result = false
                return false
            }
            return true
        }
    }
}
