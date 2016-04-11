/**
 Node is a building block of any `Graph`.
*/
public protocol Node: Hashable {
    var children: [Self] { get }
}

/**
 Graph defines basic directed graph. Instances of conforming can leverage basic Graph algorithms defined in the extension.
 */

public protocol Graph {
    associatedtype T : Node
    var nodes: [T] { get }
}

public extension Graph {
    
    /**
     Checks whether a graph contains a cycle. A cycle means that there is a parent-child relation where child is also a predecessor of the parent.
     
     - Complexity: O(N + E) where N is the number of all nodes, and E is the number of connections between them
     - returns: `true` if doesn't contain a cycle
     */
    func isAcyclic() -> Bool {
        var isAcyclic = true
        
        depthSearch(edgeFound: { edge in
            isAcyclic = (edge.type() != .Back)
            return isAcyclic
            }, nodeStatusChanged: nil)
        
        return isAcyclic
    }
    
    /**
     Topological sort ([Wikipedia link](https://en.wikipedia.org/wiki/Topological_sorting)) is an ordering of graph's nodes such that for every directed edge u->v, u comes before v in the ordering.
     
     - Complexity: O(N + E) where N is the number of all nodes, and E is the number of connections between them
     - returns: Ordered array of nodes or nil if it cannot be done (i.e. the graph contains cycles)
     */
    func topologicalSort() -> [T]? {
        var orderedVertices = [T]()
        var isAcyclic = true
        let nodeProcessed = { (nodeInfo: NodeInfo<T>) -> Bool in
            if nodeInfo.status == .Processed {
                orderedVertices.append(nodeInfo.node)
            }
            return true
        }
        
        depthSearch(edgeFound: { edge in
                isAcyclic = (edge.type() != .Back)
                return isAcyclic
            }
            , nodeStatusChanged: nodeProcessed)
        
        return isAcyclic ? orderedVertices : nil
    }
    
    /**
     Breadth First Search ([Wikipedia link](https://en.wikipedia.org/wiki/Breadth-first_search))
     
     - Complexity: O(N + E) where N is the number of all nodes, and E is the number of connections between them
     - Parameter edgeFound: Called whenever a new connection between nodes is discovered
     - Parameter nodeStatusChanged: Called when a node changes its status. It is called twice for every node
     - Note: Search will stop if `false` is returned from any closure.
     - Warning: It will only call `nodeStatusChanged:` on tree edges because we don't maintain entry and exit times of nodes. More information about entry and exit times [here](https://courses.csail.mit.edu/6.006/fall11/rec/rec14.pdf). It is very easy to implement them, but might have big influence on memory use.
     */
    
    func breadthSearch(edgeFound edgeFound: (Edge<T> -> Bool)?, nodeStatusChanged: (NodeInfo<T> -> Bool)?) {
        var queue = Queue<T>()
        var searchInfo = SearchInfo<T>()
        
        for graphRoot in nodes {
             if searchInfo.status(graphRoot) == .New {
                queue.enqueue(graphRoot)
                if updateNodeStatus(&searchInfo, node: graphRoot, status: .Discovered, nodeStatusChanged: nodeStatusChanged) == false { return }
                
                while queue.isEmpty() == false {
                    let parent = queue.dequeue()
                    
                    for child in parent.children {
                        if searchInfo.status(child) == .New {
                            queue.enqueue(child)
                            if updateNodeStatus(&searchInfo, node: child, status: .Discovered, nodeStatusChanged: nodeStatusChanged) == false { return }
                            if let c = edgeFound?(Edge(from: searchInfo.nodeInfo(parent), to: searchInfo.nodeInfo(child))) where c == false { return } // Since we don't maintain entry and exit times, we can only rely on tree edges type.
                        }
                    }
                    if updateNodeStatus(&searchInfo, node: parent, status: .Processed, nodeStatusChanged: nodeStatusChanged) == false { return }
                }
            }
        }
    }
    
    /**
     Depth First Search ([Wikipedia link](https://en.wikipedia.org/wiki/Depth-first_search))
     
     - Complexity: O(N + E) where N is the number of all nodes, and E is the number of connections between them
     - Parameter edgeFound: Called whenever a new connection between nodes is discovered
     - Parameter nodeStatusChanged: Called when a node changes its status. It is called twice for every node
     - Note: Search will stop if `false` is returned from any closure.
     - Warning: This function makes recursive calls. Keep it in mind when operating on big data sets.
     */
    func depthSearch(edgeFound edgeFound: (Edge<T> -> Bool)?, nodeStatusChanged: (NodeInfo<T> -> Bool)?) {
        var searchInfo = SearchInfo<T>()
        
        for node in nodes {
            if searchInfo.status(node) == .New {
                if dfsVisit(node, searchInfo: &searchInfo, edgeFound: edgeFound, nodeStatusChanged: nodeStatusChanged) == false {
                    return
                }
            }
        }
    }
    
    private func updateNodeStatus(inout searchInfo: SearchInfo<T>, node: T, status: NodeStatus, nodeStatusChanged: (NodeInfo<T> -> Bool)?) -> Bool {
        searchInfo.set(node, status: status)
        guard let shouldContinue = nodeStatusChanged?(searchInfo.nodeInfo(node)) else {
            return true
        }
        return shouldContinue
    }

    private func dfsVisit(node: T, inout searchInfo: SearchInfo<T>, edgeFound: (Edge<T> -> Bool)?, nodeStatusChanged: (NodeInfo<T> -> Bool)?) -> Bool {
        
        if updateNodeStatus(&searchInfo, node: node, status: .Discovered, nodeStatusChanged: nodeStatusChanged) == false { return false }
        
        for child in node.children {
            if let c = edgeFound?(Edge(from: searchInfo.nodeInfo(node), to: searchInfo.nodeInfo(child))) where c == false { return false }
            if searchInfo.status(child) == .New {
                if dfsVisit(child, searchInfo: &searchInfo, edgeFound: edgeFound, nodeStatusChanged: nodeStatusChanged) == false {
                    return false
                }
            }
        }
        
        if updateNodeStatus(&searchInfo, node: node, status: .Processed, nodeStatusChanged: nodeStatusChanged) == false { return false }
        return true
    }
}
