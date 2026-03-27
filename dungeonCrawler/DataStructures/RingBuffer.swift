//
//  RingBuffer.swift
//  dungeonCrawler
//
//  Created by Letian on 27/3/26.
//

import Foundation

/// This is used in CommandQueue

final class RingBuffer<T> {
    private var storage: [T?]
    private var head: Int = 0
    private var tail: Int = 0
    private(set) var count: Int = 0

    var isEmpty: Bool {
        count == 0
    }
    var isFull:  Bool {
        count == storage.count
    }

    init(capacity: Int) {
        storage = Array(repeating: nil, count: capacity)
    }

    @discardableResult
    func push(_ element: T) -> Bool {
        guard !isFull else { return false }
        storage[tail] = element
        tail = (tail + 1) % storage.count
        count += 1
        return true
    }

    func pop() -> T? {
        while !isEmpty {
            defer {
                storage[head] = nil
                head = (head + 1) % storage.count
                count -= 1
            }
            if let val = storage[head] {
                return val
            }
         }
        return nil
    }
    
    func modifyFirst(where predicate: (T?) -> Bool, _ body: (inout T?) -> Void) {
        for i in 0..<count {
            let index = (head + i) % storage.count
            if predicate(storage[index]) {
                body(&storage[index])
                return
            }
        }
    }
}
