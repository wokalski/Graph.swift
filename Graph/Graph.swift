
public protocol Node: Hashable {
    var children: [Self] { get }
}

public protocol Graph {
    associatedtype T : Node
    var nodes: [T] { get }
}

public extension Graph {
    
    /**
     Returns true if a graph doesn't contain a cycle.
     
     A cycle means that there is a parent-child relation where child is also a predecessor of the parent.
     */
    func isAcyclic() -> Bool {
        var result = true
        
        depthSearch(SearchHandler(newEdgeFound: SearchHandler.isAcyclicHandler(&result)))
        return result
    }
    
    /**
     Topological sort is an ordering of graph's nodes such that for every directed edge u->v, u comes before v in the ordering.
     
     - returns: Ordered array of nodes or nil if it cannot be done (i.e. the graph contains cycles)
     */
    func topologicalSort() -> [T]? {
        var orderedVertices = [T]()
        var isAcyclic = true
        
        depthSearch(SearchHandler<T>(nodeChangedStatus: { nodeInfo in
            if nodeInfo.status == .Processed {
                orderedVertices.append(nodeInfo.node)
            }
            return true
            }, newEdgeFound: SearchHandler.isAcyclicHandler(&isAcyclic)))
        
        return isAcyclic ? orderedVertices : nil
    }
    
    /**
     Breadth First Search
     */
    func breadthSearch(handler: SearchHandler<T>?) {
        var queue = Queue<T>()
        var searchInfo = SearchInfo<T>()
        
        for node in nodes {
             if searchInfo.status(node) == .New {
                queue.enqueue(node)
                searchInfo.set(node, status: .Discovered)
                handler?.nodeChangedStatus?(searchInfo.nodeInfo(node))
                
                while queue.isEmpty() == false {
                    let parent = queue.dequeue()
                    
                    for child in parent.children {
                        if searchInfo.status(child) == .New {
                            queue.enqueue(child)
                            searchInfo.set(child, status: .Discovered)
                            handler?.newEdgeFound?(Edge(from: searchInfo.nodeInfo(parent), to: searchInfo.nodeInfo(child)))
                        }
                    }
                    searchInfo.set(parent, status: .Processed)
                    handler?.nodeChangedStatus?(searchInfo.nodeInfo(parent))
                }
            }
        }
    }
    
    /**
     Depth First Search
     */
    func depthSearch(handler: SearchHandler<T>?) {
        var searchInfo = SearchInfo<T>()
        
        for node in nodes {
            if searchInfo.status(node) == .New {
                dfsVisit(node, searchInfo: &searchInfo, handler: handler)
            }
        }
    }
    
    private func dfsVisit(node: T, inout searchInfo: SearchInfo<T>, handler: SearchHandler<T>?) {
        
        searchInfo.set(node, status: .Discovered)
        handler?.nodeChangedStatus?(NodeInfo(node: node, status: .Discovered))
        
        for child in node.children {
            handler?.newEdgeFound?(Edge(from: searchInfo.nodeInfo(node), to: searchInfo.nodeInfo(child)))
            if searchInfo.status(child) == .New {
                dfsVisit(child, searchInfo: &searchInfo, handler: handler)
            }
        }
        
        searchInfo.nodeStatus[node] = .Processed
        handler?.nodeChangedStatus?(NodeInfo(node: node, status: .Processed))
    }
}
