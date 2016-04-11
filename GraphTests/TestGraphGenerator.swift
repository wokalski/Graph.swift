import Darwin
import Graph

// Dummy Graph and Node implementation

public func ==<T>(l: Nodey<T>, r: Nodey<T>) -> Bool {
    return l.value == r.value
}

public final class Nodey<T: Hashable> : CustomStringConvertible, Node {
    let value: T
    var c: [Nodey<T>] = []
    public var hashValue: Int { return value.hashValue }
    public var children: [Nodey<T>] { return c }
    public var description: String { return "\(value)" }

    public init(value: T, c: [Nodey<T>]) {
        self.value = value
        self.c = c
    }
}

public struct Graphy: Graph {
    public let nodes: [Nodey<Int>]
}

public extension Graphy {
    static func generateRandomTree(count: Int) -> (Graphy, numberOfEdges: Int) {
        var nodes = Set<Nodey<Int>>()
        var numberOfEdges = 0;
        
        for i in 0..<count {
            nodes.insert(Nodey<Int>(value: i, c: []))
        }
        
        guard let first = nodes.popFirst() else {
            return (Graphy(nodes: []), numberOfEdges)
        }
        
        var queue = Queue<Nodey<Int>>()
        queue.enqueue(first)
        var discoveredNodes = Set<Nodey<Int>>()
        
        while nodes.isEmpty == false {
            let element = queue.dequeue()
            nodes.remove(element)
            let nodesToAdd = Array(nodes.chooseRandom(1))
            numberOfEdges += nodesToAdd.count
            
            element.c = nodesToAdd
            nodesToAdd.forEach {
                if discoveredNodes.contains($0) == false {
                    queue.enqueue($0)
                }
            }
            nodesToAdd.forEach({discoveredNodes.insert($0)})
        }
        
        return (Graphy(nodes: [first]), numberOfEdges)
    }
}

extension Set {
    func chooseRandom(maxCount: UInt32) -> Set {
        guard self.isEmpty == false else {
            return Set()
        }
        
        var set = Set()
        let maxCount = maxCount > UInt32(count) ? UInt32(count) : maxCount
        let iterations = maxCount
        
        for _ in 0...iterations {
            let n = Int(arc4random_uniform(UInt32(count)))
            let i = startIndex.advancedBy(n)
            set.insert(self[i])
        }
        
        return set
    }
}

public struct TestTree {
    private var generatedNodes = generateNodes(5)
    
    var leaf1: Nodey<Int> { return generatedNodes[0] }
    var leaf2: Nodey<Int> { return generatedNodes[1] }
    var node1: Nodey<Int> { return generatedNodes[2] }
    var node2: Nodey<Int> { return generatedNodes[3] }
    var root: Nodey<Int> { return generatedNodes[4] }
    
    init(acyclic: Bool) {
        let leaf1 = generatedNodes[0]
        let leaf2 = generatedNodes[1]
        let node1 = generatedNodes[2]
        let node2 = generatedNodes[3]
        let root = generatedNodes[4]
        
        if acyclic == false {
            leaf1.c.append(root)
            generatedNodes[0] = leaf1
        }
        
        node1.c.append(leaf1)
        node2.c.append(leaf2)
        root.c.appendContentsOf([node1, node2])
        
        generatedNodes[2] = node1
        generatedNodes[3] = node2
        generatedNodes[4] = root
    }
}

func generateNodes(count: Int) -> [Nodey<Int>] {
    var nodes = [Nodey<Int>]()
    for i in 1...count {
        nodes.append(Nodey<Int>(value: i, c: []))
    }
    
    return nodes
}
