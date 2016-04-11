
internal struct Queue<T> {
    private var elements: [T] = []
    
    mutating func enqueue(element: T) {
        elements.append(element)
    }
    
    mutating func enqueue(elements: [T]) {
        elements.forEach {self.elements.append($0)}
    }
    
    mutating func dequeue() -> T {
        return elements.removeFirst()
    }
    
    func isEmpty() -> Bool {
        return elements.count == 0
    }
    
    init() {}
}
