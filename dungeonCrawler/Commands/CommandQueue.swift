//
//  CommandQueue.swift
//  dungeonCrawler
//
//  Created by Letian on 27/3/26.
//

import Foundation

struct CommandQueue {
    private var buffer = RingBuffer<any Command>(capacity: 128)
    
    mutating func enqueue(_ command: any Command) -> Bool {
        return buffer.push(command)
    }
    
    mutating func dequeue() -> (any Command)? {
        return buffer.pop()
    }
}
