
public struct Queue<T> {
    private var elements: [T] = []
    
    public mutating func enqueue(element: T) {
        elements.append(element)
    }
    
    public mutating func enqueue(elements: [T]) {
        elements.forEach {self.elements.append($0)}
    }
    
    public mutating func dequeue() -> T {
        return elements.removeFirst()
    }
    
    public func isEmpty() -> Bool {
        return elements.count == 0
    }
    
    public init() {}
}
