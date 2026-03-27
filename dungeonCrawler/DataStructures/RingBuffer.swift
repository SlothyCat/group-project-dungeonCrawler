//
//  RingBuffer.swift
//  dungeonCrawler
//
//  Created by Letian on 27/3/26.
//

import Foundation

/// This is used in CommandQueue

struct RingBuffer<T> {
    private var storage: [T?]
    private var head: Int = 0
    private var tail: Int = 0
    private(set) var count: Int = 0

    init(capacity: Int) {
        storage = Array(repeating: nil, count: capacity)
    }

    var isEmpty: Bool {
        count == 0
    }
    var isFull:  Bool {
        count == storage.count
    }

    mutating func push(_ element: T) -> Bool {
        guard !isFull else { return false }
        storage[tail] = element
        tail = (tail + 1) % storage.count
        count += 1
        return true
    }

    mutating func pop() -> T? {
        guard !isEmpty else { return nil }
        let element = storage[head]
        storage[head] = nil
        head = (head + 1) % storage.count
        count -= 1
        return element
    }
}
